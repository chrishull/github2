/**
 *  OC Standard Tiny Library
 * 
 *  A simple buffer object.  No load balancing, but allocates in chunks so
 *  as to not be completely inefficent.
 *
 *  Christopher Hull   
 *  www.opencountry.com
**/
#include <iostream>
#include <string>
#include <exception>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <pwd.h>
#include <netdb.h>
#include <stddef.h>
#include <dirent.h>

using namespace std;

#include "buffer.h"
#include "utils.h"

/**
    Constuct an empty Buffer with default load balancing params.
*/
Buffer::Buffer()
{
    this->Init();
}

/**
    Construct a Buffer given a pointer to mem and a size.
    The data is copied into the new Buffer.
    @param void* Pointer to some data
    @param int Size of data
*/
Buffer::Buffer(void* pPointer, int size)
{
   //  cout << "Buffer::Buffer(void* pPointer, int size) \n"; 
    this->Init();
    this->Add(pPointer, size);
}

/**
    Init for all constructors
*/
void    Buffer::Init() {
    
    m_pBuffer = 0;      // Pointer to buffer's data
    m_BufferSize = 0;   // The Real size of the buffer
    m_Used = 0;         // Size used by actual data
    m_Chunk = 256;      // Allocation chunk size
    m_Detach = false;   // Detach on destruct flag
    
    m_Debug = false;
}

/**
    If we have not detached the buffer, then free it.
*/
Buffer::~Buffer() { 
    
    // cout << "Buffer::~Buffer\n"; 
    
    if (m_Detach == false)
        if (m_pBuffer != 0)
            free (m_pBuffer);
}

/**
    If we have not detached the buffer, then dispose of any
    data within and reinit all data.
    @return Error condition.  If Detach has been called, else zero.
*/
int Buffer::Delete() { 
    
    if (m_Detach == true)
        return kErrorPointerDetached;
    
    if (m_pBuffer != 0)
        free (m_pBuffer);
    this->Init();
    
    return 0;
}

/**
    Activate basic debugging
*/
void    Buffer::Debug() {
    m_Debug = true;
}


/**
   Add the given block of memory to this Buffer
   @param void* Pointer to memory
   @param int Size of the incomming data
   @return int Error condition.
*/
int Buffer::Add(void* pPointer, int size){
     
    if (pPointer == NULL)
        return 0;

    // Check to see if new data will overrun our buffer.  If so
    // reallocate.
    if ( size + m_Used >= m_BufferSize ) {
        
        
        // Allocate a new block of mem in multiples of m_Chunk
        int     additionalMem = ((size / m_Chunk) * m_Chunk) + m_Chunk;
        int     newSize = m_BufferSize + additionalMem;
        int success = this->Reallocate(newSize);
        
        // Oops, bail
        if (success != 0) {
             return success;
        }
    }
    
    // Copy new data into buffer
    for(int i = 0; i < size; i++) {
        ((char *)m_pBuffer)[m_Used + i] = ((char *)pPointer)[i];
    }
    m_Used += size;
    return 0;
    
}

/**
   Buffer::Reallocate
   Allocate a new block of memory and copy the old buffer into it.  Free the old buffer
   if it existed.
   @param int size.  The total size of the new block of memory to allocate.
   @return int Success = 0, else failed to allocate.
*/
int Buffer::Reallocate(int newSize){
     
    // cout << "Buffer::Reallocate(int size)\n"; 
	if(newSize == 0) {
		return 0;
	}
    
    // Allocate a new block of mem
    void*   pNewBuffer = malloc(newSize);
    if ( pNewBuffer == 0 ) {
        return -1;
    }
    
    // If this is not our first allocation, copy the Used portion of
    // the existing m_pBuffer to the new buffer.
    // Free m_pBuffer
    if ( m_pBuffer != 0 ) {
        memcpy(pNewBuffer, m_pBuffer, m_Used);
        free (m_pBuffer);
    }
    
    // Set New buffer pointer and new total buffer size
    m_pBuffer = pNewBuffer;
    m_BufferSize = newSize;
   
    return 0;
}

/**
    Get a pointer to this Buffer's memory.
    @return void* Ptr to buffer
*/
void* Buffer::GetPointer() {
    return m_pBuffer;
}

/**
    Detach the pointer so that it won't be freed when the Buffer object is deleted.
    The block of memory is you're to keep and you're to free.
    Return a pointer to this Buffer's memory.
    @return void* Ptr to buffer
*/
void* Buffer::DetachPointer() {
    m_Detach = true;
    return m_pBuffer;
}

/**
    Attach the pointer.  Allow the memory to be freed when the Buffer object
    goes away.  This is the default case.
    Return a pointer to this Buffer's memory.
    @return void* Ptr to buffer
*/
void* Buffer::AttachPointer() {
    m_Detach = false;
    return m_pBuffer;
}

/**
    Get the size of mem for this buffer.
    @return void* Ptr to buffer
*/
int  Buffer::GetSize() {
    return m_Used;
}

/**
    Set the chunk size for this buffer.
*/
void    Buffer::SetChunkSize(int size) {
    m_Chunk = size;
}

/**
    Trim the buffer to fit the size of it's used portion.
    This will cause the creation of new buffer data, so this function
    returns a ptr to it as a convenience.
    @return void* Ptr to data
*/
void*   Buffer::Trim() {
    this->Reallocate(m_Used);
    return m_pBuffer;
}

/**
    Debugging: Dump Buffer data.  Treat buffer contents as Chars
*/
void    Buffer::Dump(void) {
    
    printf ("Buffer::Dump              m_Used %i\n", m_Used);
    printf ("Buffer::Dump             m_Chunk %i\n", m_Chunk);
    printf ("Buffer::Dump        m_BufferSize %i\n", m_BufferSize);
    
    printf ("Buffer::Dump (treated as chars)  buffer begin...\n\n");
    
    for (int i = 0; i < m_Used; i++) {
        bool    b = false;
        if ( ((char *)m_pBuffer)[i] == '\0' ) {
            printf("[NULL]");
            b = true;
        }
        if ( ((char *)m_pBuffer)[i] == '\t' ) {
            printf("[TAB]");
            b = true;
        }
        if ( ((char *)m_pBuffer)[i] == '\r' ) {
            printf("[R]");
            b = true;
        }
        if ( ((char *)m_pBuffer)[i] == '\n' ) {
            printf("[N]\n");
            b = true;
        }        
        if (b == false)
            printf ("%c", ((char *)m_pBuffer)[i] );
    }
    
    printf ("\n\nBuffer::Dump   buffer end  \n");
}




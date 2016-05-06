/**
 *  OC Standard Tiny Library
 * 
 *  Buffer extension that reads a file into a variable length buffer.  
 *  May be used to append several files together.
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

#include "filebuffer.h"

FileBuffer::FileBuffer(){}
FileBuffer::~FileBuffer(){}

/**
    Read a file into a FileBuffer.  Trim the data to size.
    @param char* Filename
    @return int Error condition.  0 if ok.
*/
int FileBuffer::Add(char* pFileName)
{
    FILE*        pFile;
    char*        pData[1000];
    size_t       dataRead;
    size_t      totalDataRead = 0;
    
    pFile = fopen( pFileName, "r" );
    if ( pFile == (FILE*) 0 ) {
        return -1;
    }
    for (;;) {
        dataRead = fread( pData, 1, sizeof(pData) - 1, pFile );
        if ( dataRead == 0 )
            break;
        int err = ((Buffer *)this)->Add(pData, dataRead);
        if ( err != 0 ) {
             fclose( pFile );
             return err;
        }   
	}
    
    fclose( pFile );
    this->Trim();
    return 0;
}

/**
    Return the file as a null terminated string.
    This method modified the buffer contents if there is not currently a NULL
    at the end.
*/
char*   FileBuffer::GetString() {
    char    c = '\0';
    if ( ((char*)m_pBuffer)[m_Used] != 0 )
        ((Buffer*)this)->Add(&c, 1);

    return (char*)m_pBuffer;    
}

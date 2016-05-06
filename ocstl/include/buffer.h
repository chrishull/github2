// Buffer.h
#ifndef BUFFER_H_
#define BUFFER_H_

#include <iostream>
#include <string>
#include <exception>
using namespace std;


class Buffer {

public:
    Buffer(void);    
    Buffer(void* pPointer, int size);
    void Init(void);
    int Delete();
    int Add(void* pPointer, int size);
    void* GetPointer();
    void* DetachPointer();
    void* AttachPointer();
    int GetSize();
    void SetChunkSize(int size);
    void* Trim();
    void Debug();
    void Dump(void);
    ~Buffer();    
    
    enum error {
        kErrorPointerDetached = -1,      // Pointer can not be freed, Detach called.
        kErrorOutOfSpace = -2,           // malloc failed, can not get more space
        kErrorLimitReached = -3          // Buffer size limit reached
    };

private:

    int     m_BufferSize;   // The Real size of the buffer
    int     m_Chunk;        // Allocation chunk size
    bool    m_Detach;       // Detach on destruct flag
    bool    m_Debug;
    
    int Reallocate(int size);
    
protected:

    void*   m_pBuffer;      // Pointer to buffer's data
    int     m_Used;         // Size used by actual data
    
};
#endif // BUFFER_H_

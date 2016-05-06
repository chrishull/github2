// FileBuffer.h
#ifndef FILEBUFFER_H_
#define FILEBUFFER_H_

#include <iostream>
#include <string>
#include <exception>
using namespace std;
#include "buffer.h"


class FileBuffer : public Buffer {

public:
    FileBuffer(void);    
    ~FileBuffer();    
    char* GetString();
    int Add(char* pFileName);

private:
    
};
#endif // FILEBUFFER_H_

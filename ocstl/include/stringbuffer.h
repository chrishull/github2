// StringBuffer.h
#ifndef STRINGBUFFER_H_
#define STRINGBUFFER_H_

#include <iostream>
#include <string>
#include <exception>
using namespace std;
#include "buffer.h"


class StringBuffer : public Buffer {

public:
    StringBuffer(void);    
    StringBuffer(char* pString);    
    ~StringBuffer();    
    int Add(char* pString);
    int AddEOL();
    int Delete();
    char*   DetachString();
    char*   GetString();
	bool operator==(StringBuffer &SB);
	StringBuffer& operator=(char* pszString);

private:
	StringBuffer(const StringBuffer &SB);
	StringBuffer& operator=(const StringBuffer &SB);
};
#endif // STRINGBUFFER_H_

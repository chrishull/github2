// HTTPPROPERTIES.h
#ifndef HTTPPROPERTIES_H_
#define HTTPPROPERTIES_H_

#include <iostream>
#include <string>
#include <exception>
using namespace std;
#include "properties.h"

class HttpProperties: public Properties		 {

public:  
    HttpProperties(char* pContent, int size);
    int Size();
    char* Get(char* pKey);
    char* GetNextName();
    bool IsPostData();
    void Dump();
    int Skip(char* pSkip);
    ~HttpProperties();    
private:
    void StrDecode( char* pTo, char* pFrom);
    int HexcodeToInt(char c);
    bool m_IsPOSTData;
};
#endif // HTTPPROPERTIES_H_


// Properties.h
#ifndef Properties_H_
#define Properties_H_

#include <iostream>
#include <string>
#include <exception>
using namespace std;

#include "stringarray.h"

class Properties {

public:
    // XXX this really shouldn't be here.  This is application specific
    static Properties *GetSharedInstance();

    Properties(void);    
    Properties(char* pFileName);
    Properties(Properties *pInProps);
    int Size();
    char* Get(char* pName);
    char* GetNextName();
    int Add(char* pName, char* pValue);
    int AddFile(char* pFileName);
    int AddString(char*  pTextLine);
    int AddProperties(Properties *pInProps);
    void AllowDuplicates();
    void Dump();
    void Debug();
    int Skip(char* pSkip);
    ~Properties();    
    
    bool    m_Debug;

private:
    
    // Some bit twiddling functions
    char*    Getline(char* content, int* pCurrentIndex, int contentSize );
    
    void Init();
    bool Exclude();
    
    // I really should use a hashtable.    
    // Name value pairs are stored as linked lists of char* pairs.
    struct Property {
        char*   name;
        char*   value;
        Property*   next;
    };
    
    Property*   m_pProperties;
    Property*   m_pNextProperty;
   
    Property* Properties::GetLast(void);
    
    bool    m_AllowDuplicates;
    
    StringArray     m_StringArray;

};
#endif // Properties_H_

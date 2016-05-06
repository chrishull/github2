/**
 *   OC Standard Tiny Library
 * 
 *   StringBuffer is an extension of Buffer that handles strings.
 *   Add strings to a variable length Buffer and manage them.
 * 
 *   Christopher Hull
 *   www.opencountry.com
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
#include "stringbuffer.h"

StringBuffer::StringBuffer(){}
StringBuffer::StringBuffer(char* pString)
{
	this->Add(pString);
}
StringBuffer::~StringBuffer(){}

/**
    Add a String to the given buffer.  Trim off the null terminator
    of the given string, but null term the entire Buffer.
    @param char* Pointer to null terminated string.
    @return int Error condition.  0 if ok.
*/
int StringBuffer::Add(char* pString) {

    if (pString == NULL)
        return 0;
    
    // If the last character is a zero, then back 
    // the Used index up one so that it is overwritten
    if ( (m_Used > 0) && (m_pBuffer != NULL) ) {
        if ( ((char*)m_pBuffer)[m_Used - 1] == 0)
            m_Used--;
    }
    
    // Add the given string, including it's NULL terminating.
    return ((Buffer *)this)->Add(pString, strlen(pString) + 1);
}

/**
    Add (Unix) End Of Line to the end of the StringBuffer
    XXX Support OS-X and Win someday when we make OC Agent for them
    @return int Error condition.  0 if ok.
*/
int StringBuffer::AddEOL() {

    // If the last character is a zero, then back 
    // the Used index up one so that it is overwritten
    if ( (m_Used > 0) && (m_pBuffer != NULL) ) {
        if ( ((char*)m_pBuffer)[m_Used - 1] == 0)
            m_Used--;
    }
    
    return ((Buffer *)this)->Add((char*)"\r\n", 3);
}

/**
    A convenient get.
    Trim the buffer and return a pointer to the string
    @return char* A zterm string
*/
char*   StringBuffer::GetString() {
    ((Buffer *)this)->Trim();
    return (char *)((Buffer *)this)->GetPointer();
}

/** 
    Callthru to Buffer function.
    Delete the String being managed by this StringBuffer.
    @return Error condition.  Just in case Detach had been called,
    I return an error for safety.
*/
int StringBuffer::Delete() {
    return ((Buffer*)this)->Delete();
}

/**
    Works like Buffer::DetatchPointer, except we trim and return a null term String
*/
char*   StringBuffer::DetachString() {
    ((Buffer *)this)->Trim();
    return (char *)((Buffer *)this)->DetachPointer();
}

/**
    Compare to another StringBuffer.
    @param StringBuffer reference.
    @return boolean indication of string equality.
*/
bool StringBuffer::operator==(StringBuffer &SB) {
	if(!SB.GetString() || !(this->GetString())) {
		return false;
	}
	if(&SB == this) {
		return true;
	}
	if(strcmp(SB.GetString(), this->GetString()) == 0) {
		return true;
	}
	else {
		return false;
	}
}

/**
    Assignment operator for assigning character string to StringBuffer.
    @param char* Pointer to null terminated string.
*/
StringBuffer& StringBuffer::operator=(char* pszString) {
	this->Delete();
	if(pszString)
	{
		this->Add(pszString);
	}
	return *this;
}


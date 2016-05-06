/**
 *  OC Standard Tiny Library
 * 
 *  Properties.cpp
 *   Each Properties object is a wrapper for a configureation file.  
 *   A static factory is also included for use by straight C applications.  
 *   This works more or less (allright less) like Java Properties.
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

#include "properties.h"
#include "filebuffer.h"

// Shared instance of a single Properties object
static  Properties     *pSharedPropertiesObject = NULL;

/**
    Return a single shared instance of Properties
    The returned object is uninitialized (has no name value pairs in it).
    The first thing one might do is feed a file into it so it can be used
    for global Preferences data.
    XXX Set this up so that we can have any number of singleton file based prefs
    instead of just one.
*/
Properties *Properties::GetSharedInstance() {
    if ( pSharedPropertiesObject == NULL ) {
        pSharedPropertiesObject = new Properties();
    }
    return pSharedPropertiesObject;
}

/**
    Construct with no initial Properties.
*/
Properties::Properties() {
    this->Init();
}

/**
    Open a file and establish a set of NV pairs.
    @param char*path and filename
*/
Properties::Properties(char* pFileName) {   
    this->Init();
    this->AddFile(pFileName);
}

/**
    Copy constructor
    @param Properties object
*/
Properties::Properties(Properties *pInProps) {
    this->Init();
    this->AddProperties(pInProps);
}

/**
    Init used by all constructors
*/
void    Properties::Init() {
    m_AllowDuplicates = false;      // Do not allow duplicates by default
    m_pProperties = NULL;           // Start out empty
    m_Debug = false;
    m_pNextProperty = 0;            // Start GetNext at the beginning
}

/**
    Dispose of all Properties
*/
Properties::~Properties() { 
    
    Property* pPair = m_pProperties;
    Property* pNextPair = m_pProperties;
    
    while (pNextPair != 0 ) {
        pNextPair = pPair->next;
                    
        if ( pPair->name != 0 )
            free (pPair->name);
        if ( pPair->value != 0 )
            free (pPair->value);
        free (pPair);  
        
        pPair = pNextPair;
    }
}

/**
    Allow duplicate keys for all additional Add operations
*/
void    Properties::AllowDuplicates() {
    m_AllowDuplicates = true;
}

void    Properties::Debug() {
    m_Debug = true;
}

/**
    Return the number of properties stored in this object.
    @return int Number of properties.
*/
int Properties::Size() { 
     
    Property* pPair = m_pProperties;
    int     size = 0;
    while (pPair != 0 ) {
        ++size;
        pPair = pPair->next;
    }
    return size;
}

/**
    Get the value associated with a given key.  This value is NOT a copy, but
    an actual pointer to an element within this Properties object.
    @param char* Key name.
    @return char* value, or null
*/
char* Properties::Get(char* pName){

    Property* pPair = m_pProperties;
    
    while (pPair != 0 ) {
        if ( strcmp(pPair->name, pName) == 0 ) {
            return pPair->value;
        }
        pPair = pPair->next;
    }
    return 0;    
}

/**
    Get the next name in the set of names stored in this Properties object.
    If we have reached the list, Null is returned.
    @return char* value, or null
*/
char* Properties::GetNextName(){

    // Walk to next, or start over.
    if (m_pNextProperty == 0)
        m_pNextProperty = m_pProperties;
    else
        m_pNextProperty = m_pNextProperty->next;
    
    // If we have walked to the end, then return NULL
    if (m_pNextProperty == 0)
        return 0;
    
    // Now that we are definately pointing to a property,
    // wind thru until we are pointing to a Name that is Not in
    // the excluded list.
    // If we walk off the list, return NULL
    while (this->Exclude() == true)
        m_pNextProperty = m_pNextProperty->next;

    // If we have walked to the end, then return NULL
    if (m_pNextProperty == 0)
        return 0;
        
    return m_pNextProperty->name;   
}

/**
    Check to see if the name currently being pointed to by 
    m+pNextProperty is in the exclusion list in m_StringArray
    @return False if the Name is NOT in the include list.
*/
bool    Properties::Exclude() {
    
    if ( (m_pNextProperty == 0) || ( ((Buffer)m_StringArray).GetSize() == 0 ) )
        return false;
    
    m_StringArray.Reset();
    while ( m_StringArray.IsLastString() == false ) {
        // If the same, 
        if ( strcmp(m_StringArray.GetNextString(), m_pNextProperty->name) == 0) 
            return true;
    }
    return false;
    
}


/**
    Add a name to the Skip list.  This will cause 
    GetNextName to ignore the name
    @param char* Null string, name to skip.
    Compare is case sensative.
*/
int Properties::Skip(char* pSkip) {
    if ( pSkip == NULL )
        return -1;
    return m_StringArray.Add(pSkip);
}


/**
    Add a name value pair.  The strings handed to this method are duplicated and
    stored in this object.  If m_AllowDuplicates has been set, then several
    instances of the same Name may be stored in the list.  This is needed by
    HTMLProperties
    
    @param char* Name
    @param char* value
    @return Error condition.
*/
int Properties::Add(char* pName, char* pValue){
    
    Property* pPair         = m_pProperties;
    char* pNameString       = 0;
    char* pValueString      = 0;

    // make a copy of pValue.  If pValue is null, then 
    // allow null to be associated with name (flag)
    if (pValue != 0) {
        pValueString = (char *)strdup(pValue);
        if (pValueString == 0)
            return -1;
    }
    
    // Check to see if this name already exists.  If so, just replace it's data
    if (m_AllowDuplicates == false) {
        Property* pNextPair = pPair;
        
        while (pNextPair != 0 ) {
            pNextPair = pPair->next;
                        
            if ( strcmp(pPair->name, pName) == 0 ) {
                if ( pPair->value != 0 )
                    free (pPair->value);
                pPair->value = pValueString;
                return 0;
            }
            pPair = pNextPair;
        }
    }
    
    // No, the name doesn't already exist.
    // Alloc a new Name, and Pair structure to add to the list.
    // Allow value to be null, as name may just be a flag
    pNameString = (char *)strdup(pName);
    pPair = (Property*)malloc(sizeof(Property));
    
    // Check for malloc errors.  If exist, free any malloced mem and fail.
    if ( (pNameString == 0) || (pPair == 0) ) {
        if ( pNameString != 0 )
            free (pNameString);
        if ( pPair != 0 )
            free (pPair);
        if ( pValueString != 0 )
            free (pValueString);
        // XXX Define some return code constants     
        return -1;
    }

        
    // Make a name value pair
    pPair->name = pNameString;
    pPair->value = pValueString;
    pPair->next = 0;
    
    // Search for the end of the list.
    Property* pLastProperty = m_pProperties;
    // Link to end of list or
    while (pLastProperty != 0 ) {
        if ( pLastProperty->next == 0 ) {
            pLastProperty->next = pPair;
            return 0;
        }
        pLastProperty = pLastProperty->next;                 
    }
    
    // There was no list,  establish new list head
    m_pProperties = pPair;
    return 0;
    
}

/**
   Given a string of the form name=value, add the name value pair to the Property
   @param char* Line of text.
   @return zero is added, -1 if not.
*/
int Properties::AddString(char*  pTextLine) {
    
    size_t      lineLength = strlen(pTextLine);
    int         i;
    char        c;
    
    // Scan for =
    for (i = 0; i < lineLength; i++ ) {
        c = pTextLine[i];
        if ( c == '=' ) {

            // NEW  Must replace = with \0 because we can't use strndup
            pTextLine[i] = '\0';
            
            // ALLOC:  Remember to FREE in the Dispose function
            this->Add( pTextLine,  &(pTextLine[i+1]) );
            
             pTextLine[i] = '=';
             return 0;
        }
    } 
    return -1;
}

/**
    Given a text file, scan for all the name value pairs and add them to this 
    Properties object.
    @param char* Path to file
*/
int Properties::AddFile(char* pFileName) {
    FILE*        pPropertiesFile;
    char*        pData;
    size_t      totalDataRead = 0;
    FileBuffer  propBuffer;
    int         err;

    err = propBuffer.Add(pFileName);
    if ( err != 0 )
        return err;
    pData = (char *)propBuffer.GetPointer();
    totalDataRead = propBuffer.GetSize();
    
    char*   pLine;
    int     start = 0;
    
    for (;;) {
        pLine = this->Getline(pData, &start, totalDataRead );
        if (pLine == 0 )
            break;
        if (pLine[0] != '#')
            this->AddString(pLine);
    }
    
    return 0;
    
}

/**
    Copy Properties into this object
    @param Properties object
*/
int Properties::AddProperties(Properties *pInProps) {
    
    // Run thru pInProps chain and add each to this
    Property* pPair = pInProps->m_pProperties;
    
    while (pPair != 0 ) {
        if (pPair->name != NULL) {
            int err = this->Add(pPair->name, pPair->value);
            if (err != 0) {
                return err;
            }
        }
        pPair = pPair->next;
    }
    return 0;
}

/**
    Return a pointer to the next line of content in the given text buffer.  As 
    line terminators are encountered, they are converted to '\0' on the fly.
    This method does not reserve any new memory.  We simply navigate a buffer
    and return a pointer.
    
    @param char* A pointer to a text buffer
    @param int* A pointer to the current index to start looking for the next line.
    @param int The size of the buffer.
    @return A pointer to the beginning of the next line, or zero if end is reached.
*/
char*    Properties::Getline(char* content, int* pCurrentIndex, int contentSize ) {
    
    int     stringStart;
    char    c;
    
    // Scan the content buffer as long as pCurrentIndex < contentSize
    for ( stringStart = *pCurrentIndex; *pCurrentIndex < contentSize; ++*pCurrentIndex ) {
                
        c = content[*pCurrentIndex];
        
        // Check for end of line. We will convert to 0 terminated as we find them.
        if ( c == '\n' || c == '\r' || c == '\0'  ) {
            
            // Replaze wiht zero and walk past
            content[*pCurrentIndex] = '\0';
           
            // Walk past 1 or more end of lines
            for (;;) {
                 ++*pCurrentIndex;
                 c = content[*pCurrentIndex];
                 if ( c != '\n' && c != '\r' && c != '\0' )
                     break;
            }
            return &(content[stringStart]);
        }
    }
    if (stringStart != *pCurrentIndex ) {	
        return &(content[stringStart]);     
    }
    // end if buffer reached,  return zero
    return (char*) 0;
}


/**
    Debug: Spill guts to stdout
*/
void Properties::Dump() { 
    
    printf("Properties::Dump() Start \n");
    Property* pPair = m_pProperties;
    while (pPair != 0 ) {
        printf("Properties::Dump() Property name: %s  value: %s \n",  pPair->name,  pPair->value);
        pPair =  pPair->next;;
    }
    printf("Properties::Dump() Total size %i \n", this->Size() );
    printf("Properties::Dump() End \n");
}


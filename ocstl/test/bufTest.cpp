// CommandTest.cpp
//#include "../purge.h"
#include <iostream>
#include <string>
#include <stdio.h>
#include <exception>
#include <vector>
#include <map>
using namespace std;
#include "buffer.h"
#include "filebuffer.h"
#include "stringbuffer.h"
#include "stringarray.h"
#include "utils.h"


int main(int argc, char* argv[]) {

    int     ic = 0;
    cout << "Buffer unit test \n";
    
    
	Buffer* pBuffer;
    char*   pBufferData = 0;
    
    char*   pChars1 = (char*)malloc(10);
    char*   pChars2 = (char*)malloc(10);
    
    // Load up A - H
    for (int i = 0; i < 10; i++){
        pChars1[i] = i + 65;
    }
    // Load up I - P
    for (int i = 0; i < 10; i++){
        pChars2[i] = i + 75;
    }
    
    // Create a new buffer
    pBuffer = new Buffer();
    // Set the chunk size to be very lo so we can see realloc work
    printf ("Setting chunk size to 8\n");
    pBuffer->SetChunkSize(8);
   
    // Add the first char set, Dump as test
    printf ("Adding the first 10 bytes of data and dumping...\n\n");
    pBuffer->Add( pChars1, 10);
    pBuffer->Dump();
    
     // Add the next char set, Dump as test
     printf ("Adding the second 10 bytes of data and dumping...\n\n");
    pBuffer->Add( pChars2, 10);
    pBuffer->Dump();
    
     printf ("Trimming buffer to size and dumping...\n\n");
     // Trim the buffer to size, Dump
    pBuffer->Trim();
    pBuffer->Dump();
    
    // See if we get what we expected
    char*   pGetBuffer = (char* )pBuffer->GetPointer();
    int     getSize = pBuffer->GetSize();
    printf ("Extracting data from buffer to see if we get what we expect\n\n");
    printf ("Buffer size is %i \n", getSize);
    printf ("Data is... ");
    for (int i = 0; i < getSize; i++ ) {
        printf("%c", pGetBuffer[i]);
    }
    
    
    printf ("\n\n   Testing FileBuffer  \n\n");
    
    FileBuffer      fbuf;
    fbuf.Add("fbuf.txt");
    fbuf.Dump();

    printf ("\n\n   Testing StringBuffer  \n\n");
    printf ("Appending \"1234\" to \"5678\"  Total length should be 9\n\n" );
    StringBuffer      sbuf;
    sbuf.Add("1234");
    sbuf.Dump();
    sbuf.Add("5678");
    sbuf.Dump();
    
    printf ("\n\n   Testing StringBuffer Delete \n\n");
    sbuf.Delete();
    sbuf.Dump();   
    sbuf.Add("This is a new string");
    sbuf.Dump();   

    printf ("Testing formatted string output \n");
    int i = 1234;
    printf ("%s\n", Stringf("integer should be 1234: is %i \n", i)  );
    
    
    printf ("\n\n  Test StringArray  \n\n");
    
    StringArray*     pSA = new StringArray();
    
    pSA->Add("Bad boys run ");
    pSA->Add("on your grass ");
    pSA->Add("but pretty girls wont.");
    
    ((Buffer *)pSA)->Dump();
    
    
    while ( !pSA->IsLastString() ) {
        printf ("String is: %s \n", pSA->GetNextString()  );
        ic++;
        if (ic > 4) {
            printf("OOPS,  end flag never sets properly  ERROR  \n");
            break;
        }
    }
    
    printf ("\n\n  Test StringArray  END reached \n\n");
    
    
    
    
    printf ("\n\n  Test done  \n\n");
    
    
    
	delete(pBuffer);
}

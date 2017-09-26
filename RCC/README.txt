
Documentation.

Overview
----------------------------------------------
I chose to do the assignment in Java.  Java is my strongest language, and seeing as there was a threading part to the assignment, I was able to leverage the Java Concurrent package fairly easily.  Python might have been a choice, but I'm unfamiliar with Python threading, assuming it even exists.

I wrote the code using the Eclipse IDE, which I am also very familiar with.

The code follows a fairly straightforward MVC (model view controller) design pattern.  Unit tests exercise all of the internal complexities.  The only real errors that could be made are file I/O, which are tested for in the command line interface.

The code can be run from a terminal via the compiled .jar file, rs.jar.  The unit tests can be run from within Eclipse (or command line, but I do not cover that here.)


Running the code.
----------------------------------------------

First, follow the Github instructions and clone this repository.

The exercise was coded in Java. I've included a compiled .jar file which is located just inside the project directory "RackspaceCodeChallenge".   You will also find a guterberg directory containing some test books.  

Open a command line and cd into that directory to find the .jar

Orion:RackspaceCodeChallenge chris$ ls -la
drwxr-xr-x  11 chris  staff    374 Sep  6 10:47 .
drwxr-xr-x   5 chris  staff    170 Sep  4 16:23 ..
-rw-r--r--   1 chris  staff    372 Sep  1 12:26 .classpath
-rw-r--r--   1 chris  staff      6 Sep  1 12:02 .gitignore
-rw-r--r--   1 chris  staff    381 Sep  1 12:02 .project
drwxr-xr-x   3 chris  staff    102 Sep  1 12:02 .settings
drwxr-xr-x   3 chris  staff    102 Sep  4 16:17 bin
drwxr-xr-x@  6 chris  staff    204 Sep  6 10:55 gutenberg
-rw-r--r--   1 chris  staff     71 Sep  6 10:27 manifest.mf
-rw-r--r--   1 chris  staff  14235 Sep  6 10:27 rs.jar
drwxr-xr-x   3 chris  staff    102 Sep  1 12:03 src

The Java code can be run via command line in any environment.  To see what your options are just run the jar file and pass no parameters.

Orion:RackspaceCodeChallenge chris$ java -jar   rs.jar
Usage: [-t <thread count>] [-v verbose] file.txt [file2.txt file3.txt...]
Must provide full file paths.  Must be plain text files.

Here are a few sample runs agains the Java source files themselves...

A simple count of words in Main.java

Orion:RackspaceCodeChallenge chris$ java -jar rs.jar src/co/spillikin/rackspace/main/Main.java   
Top 10 words in order of occurrences... 
Number of occurrences: 16, word(s): system 
Number of occurrences: 13, word(s): static verbose 
Number of occurrences: 12, word(s): file for private 
Number of occurrences: 11, word(s): if 
Number of occurrences: 9, word(s): printerror int import s out exit 
Number of occurrences: 8, word(s): string threads list args collator i thread of java final 
Number of occurrences: 7, word(s): println executor usage 
Number of occurrences: 6, word(s): to count and new arraylist top 
Number of occurrences: 5, word(s): filebasedwordcounter path util threadname results e error 
Number of occurrences: 4, word(s): we void an filecounterlist 

Passing in two java files and running verbose
The output is truncated...

Orion:RackspaceCodeChallenge chris$ java -jar   rs.jar -v src/co/spillikin/rackspace/main/Main.java    src/co/spillikin/rackspace/worker/WordCounter.java   
Creating a pool of 10 threads
Running thread pool-1-thread-1 processing file src/co/spillikin/rackspace/main/Main.java
Running thread pool-1-thread-2 processing file src/co/spillikin/rackspace/worker/WordCounter.java
Showing detailed file results.
src/co/spillikin/rackspace/main/Main.java
  string 8 
  process 1 
  newfixedthreadpool 1 
  see 3 
  types 1 
  safe 1 
  order 1 
  println 7 
  giong 1 
  workers 1 
  default_thread_count 2 
  that 1 
....several skipped....
  return 1 
  shutdown 2 
  multi 1 
  killing 1 
  exit 9 
  only 2 

src/co/spillikin/rackspace/worker/WordCounter.java
  string 10 
  splitwords 2 
  blob 10 
  two 1 
  blobs 1 
  containing 1 
  key 5 
....several skipped....
  set 2 
  pattern 5 
  multiple 1 
  primative 1 
  z0 1 

Showing collated and top results.
  somehow 1 
  class 2 
  z0 1 
  occurrence 1 
  removed 1 
  reading 2 
  interrupted 1 
  compile 1 
  first 1 
  insensitive 1 
  top 6 
  extends 1 
  line 4 
... several skipped....
  println 7 
  paths 2 
  forces 1 
  wait 1 

 [TOP]: 18 import string 
 [TOP]: 16 system java 
 [TOP]: 15 of words a 
 [TOP]: 14 for 
 [TOP]: 13 to file if static private verbose util and 
 [TOP]: 10 blob list 
 [TOP]: 9 out exit printerror int s 
 [TOP]: 8 thread args arraylist threads final i text new collator 
 [TOP]: 7 usage count executor println 
 [TOP]: 6 top matcher return add results is in this popularity 

Top 10 words in order of occurrences... 
Number of occurrences: 18, word(s): import string 
Number of occurrences: 16, word(s): system java 
Number of occurrences: 15, word(s): of words a 
Number of occurrences: 14, word(s): for 
Number of occurrences: 13, word(s): to file if static private verbose util and 
Number of occurrences: 10, word(s): blob list 
Number of occurrences: 9, word(s): out exit printerror int s 
Number of occurrences: 8, word(s): thread args arraylist threads final i text new collator 
Number of occurrences: 7, word(s): usage count executor println 
Number of occurrences: 6, word(s): top matcher return add results is in this popularity 
Finished

Finally, the most commonly used words in these classic science fiction works

Orion:RackspaceCodeChallenge chris$ java -jar rs.jar gutenberg/julesverne.txt gutenberg/asimov.txt gutenberg/hgwells.txt   
Top 10 words in order of occurrences... 
Number of occurrences: 10000, word(s): the 
Number of occurrences: 6215, word(s): of 
Number of occurrences: 5002, word(s): and 
Number of occurrences: 3967, word(s): a 
Number of occurrences: 3949, word(s): to 
Number of occurrences: 3870, word(s): i 
Number of occurrences: 2586, word(s): in 
Number of occurrences: 2130, word(s): was 
Number of occurrences: 2120, word(s): it 
Number of occurrences: 2106, word(s): that 


Running the unit tests.
----------------------------------------------

There is a somewhat complicated way to do this from the commandline, but I will cover running the unit tests from within Eclise.  First you will need to import the project into Eclipse.  

1: Rightclick in the Package explorer and select Import.
2: Under General, go to Existing Projects into Workspace.
3: Look for the RackspaceCodeChallenge directory that you just imported and select Finish.

To run the tests, simply find AllTests in the source and run it like this.
1: Under src, find test and select AllTests.java
2: Select Run As -> Junit test.

The test should run and display a green bar indicating that all is well.


Pico Design Doc.
----------------------------------------------

This project is a simple MVC.  

The model consists of two classes.

WordCounter.java operates on a per file (or per whatever your input is, I left this UI agnostic 
for purposes and flexibility and testibaility).  It handles blob inputs and creates a basic map 
of word, occurrences.

Collator.java runs across multiple WordCounters and creates the grand totals that we need.  

The JUnit tests operate on these two objects alone as this is where the real logic lives.

AbstractWordCounter.java is common code shared by both.

The View Controller consists of two classes.

FileBasedWordCounter.java is a wrapper that passes a file into a WordCounter.  A list of these objects is run, one per thread.

Main.java is the command line interface.




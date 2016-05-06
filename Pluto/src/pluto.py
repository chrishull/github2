#!/usr/bin/python
# encoding: utf-8
'''
pluto -- Command line front end.

pluto is a configuration management and installation tool for Openstack.

@author:     Christopher Hull

@copyright:  2016 Spillikin Aerospace. All rights reserved.

@license:    Apache

@contact:    chrishull42@gmail.com
@deffield    updated: Updated
'''

import sys
import os

from osFileClass import OSConfFile, OSConfigFileGroup, OSLogger
from osBatchClass import OSBatchFileProcessor


from argparse import ArgumentParser
from argparse import RawDescriptionHelpFormatter

__all__ = []
__version__ = 0.2
__date__ = '2016-02-27'
__updated__ = '2016-03-02'

class CLIError(Exception):
    '''Generic exception to raise and log different fatal errors.'''
    def __init__(self, msg):
        super(CLIError).__init__(type(self))
        self.msg = "E: %s" % msg
    def __str__(self):
        return self.msg
    def __unicode__(self):
        return self.msg

def main(argv=None): # IGNORE:C0111
    '''Command line options.'''

    PLUTO_PATH = "CONF_FILE_PATH"
    
    if argv is None:
        argv = sys.argv
    else:
        sys.argv.extend(argv)

    program_name = os.path.basename(sys.argv[0])
    program_version = "v%s" % __version__
    program_build_date = str(__updated__)
    program_version_message = '%%(prog)s %s (%s)' % (program_version, program_build_date)
    program_shortdesc = __import__('__main__').__doc__.split("\n")[1]
    program_license = '''%s

  Created by Christopher Hull on %s.
  Copyright 2016 Spillikin Aerospace. All rights reserved.
  http://www.chrishull.com
  http://www.spillikinaerospace.com

  Licensed under the Apache License 2.0
  http://www.apache.org/licenses/LICENSE-2.0

  Distributed on an "AS IS" basis without warranties
  or conditions of any kind, either express or implied.
  
  --- Operation to perform ---
  Like all other Openstack command line front ends, the first param is a function.
  All opearations require CONF_FILE_PATH env var point to the conf files, or
  pass in --conf-file-path.  
  Example ./pluto.py --conf-file-path /etc  (where /etc is the directory just above /nova etc)
  
  pluto list 
      Shows list of known conf files and their locations.
      Run this commend first to see if you are pointing to config.
      Path passed in is typically /etc.
  pluto show (followed by one or more conf file names separated by spaces)
  pluto show-section (followed by one or more section names) shows sections for all files.
      You can use this for comparison between files to be sure that, for instance, 
      authentication schemes are identical.
  pluto set -s section -k key -d value followed by file(s)
      Sets a section, key to value within a file list.
      Adds a new section if the specified section does not exist.
  pluto set-section -k key -d value followed by section(s)
       Sets key value pairs for the given setcions in all the files thta have that section.
       WILL NOT add the section to files that do not already have it (because that would be REALLY annoying).
  pluto process (followed by a single path/file to a processing text file)  
      This will modify all .conf files in accordance with the instructions within.
      These instructions are designed to look just like those found in the various
      Openstack install guedes.   See samples like liberty-glance-install.txt
      
  When specifying a conf file name (nova.conf, etc) you may omit '.conf' if you choose.

USAGE
''' % (program_shortdesc, str(__date__))

    try:
        
        # Setup argument parser
        parser = ArgumentParser(description=program_license, formatter_class=RawDescriptionHelpFormatter)
        parser.add_argument(dest="func", help="operation to perform, see help.", metavar="func")
        parser.add_argument("-v", "--verbose", dest="verbose", action="count", help="set verbosity level [default: %(default)s]")
        parser.add_argument("-p", "--conf-file-path", dest="cpath", help="path to config file root [typically /etc]")
        parser.add_argument("-s", "--section", dest="insec", help="set command section")
        parser.add_argument("-k", "--key", dest="inkey", help="set command key")
        parser.add_argument("-d", "--data", dest="invalue", help="set command data (value, but v is taken)")
        parser.add_argument('-V', '--version', action='version', version=program_version_message)
        parser.add_argument(dest="paramlist", help="param list for operation, see help.", metavar="params", nargs='+')

        # Process arguments
        # We need to fake out the parser in the case of list, a command with no params.
        if ( len(argv) >= 2 ):
            if ( argv[1] == "list"):
                argv.append ("/not/a/path") 
            
        args = parser.parse_args()
        # Handle special case, else raise

        func = args.func
        paths = args.paramlist
        verbose = args.verbose
        
        insec = args.insec
        inkey = args.inkey
        invalue = args.invalue
        cpath = args.cpath
        
        
        # Check to see if we have a path
        if (cpath == None):
            confFilePath = os.environ.get(PLUTO_PATH)
            if ( confFilePath == None ):
                print "Error.  You must define the shell var: " + PLUTO_PATH
                print "or pass the path in via --conf-file-path."
                print "This is the path immediately above nova, neutron, glance, etc.  Typically /etc"
                return -1
        else:
            confFilePath = cpath
        
        # Check to see if we have read write access to the path.
        
        if( (os.access(confFilePath,os.R_OK) == False) | (os.access(confFilePath, os.W_OK) == False) ):
            print("You do not have read/write permission for " + confFilePath)
            print("Run as sudo, root, or a user with suitable permissions.")
            print "Exiting"
            return -1
                
        if verbose > 0:
            print("Verbose mode on")

        # Show the given conf files in Openstack style tables
        if ( func == "list"):
            print "List of all Openstack conf files found under: " + confFilePath
            ftree = OSConfigFileGroup(confFilePath)
            ftree.printFileList()
            return 0
        
        # Show the given conf files in Openstack style tables
        if ( func == "show"):
            ftree = OSConfigFileGroup(confFilePath)
            for fileName in paths:
                f = ftree.getFile(fileName)
                if ( f == None):
                    print "Configuration file not found: " + fileName
                else:
                    f.printFile()
            
        # Show giv en sections in all files
        if ( func == "show-section"):
            ftree = OSConfigFileGroup(confFilePath)
            for sectionName in paths:
                print "====== Showing all files that contain Section [" + sectionName +"]"
                print "       An empty table indicates that the section exists but has no values."
                fileNameList = ftree.getFileNames()
                for fileName in fileNameList:
                    f = ftree.getFile(fileName)
                    if ( f == None):
                        print "Configuration file not found: " + fileName
                    else:
                        f.printFileSection(sectionName)
                    
        if ( func == "process"):   
            bp = OSBatchFileProcessor(confFilePath)
            thePath = None
            for path in paths:
                thePath = path
            print "Processing using file: " + thePath
            bp.process(thePath)

            
        # Set a section, key, value in a file
                # Show the given conf files in Openstack style tables
        if ( func == "set"):
            ftree = OSConfigFileGroup(confFilePath)
            for fileName in paths:
                f = ftree.getFile(fileName)
                if ( f == None):
                    print "Configuration file not found: " + fileName
                else:
                    f.set(insec, inkey, invalue, "set by command line")
                    f.printFile()
            ftree.writeChangedFiles()
                    
                    
        # Set n v pairs across all files in a given section.
        if ( func == "set-section"):
            ftree = OSConfigFileGroup(confFilePath)
            for sectionName in paths:
                print "====== Setting values in all files that contain Section [" + sectionName +"]"
                fileNameList = ftree.getFileNames()
                for fileName in fileNameList:
                    f = ftree.getFile(fileName)
                    if ( f == None):
                        print "Configuration file not found: " + fileName
                    else:
                        # ONLY add if the section already exists.
                        if (f.hasSection(sectionName)):
                            f.set(sectionName, inkey, invalue, "set by command line")
                            f.printFileSection(sectionName)
            ftree.writeChangedFiles()            
                    
        return 0
    except KeyboardInterrupt:
        ### handle keyboard interrupt ###
        return 0
    except Exception, e:
        raise(e)
        indent = len(program_name) * " "
        sys.stderr.write(program_name + ": " + repr(e) + "\n")
        sys.stderr.write(indent + "  for help use --help")
        return 2

if __name__ == "__main__":
    sys.exit(main())
    
    
'''
Created on Feb 25, 2016

@author: chris
'''
from osFileClass import OSConfFile, OSConfigFileGroup, OSLogger
from variables import ResolveVars

# Batch Processor directives
MF_CONF_FILE = "&CONF_FILE_NAME"
MF_INSTALL_NAME = "&INSTALL_NOTE"
MF_ECHO = "&ECHO"

log = OSLogger(None, "BatchFileProcessor")

'''
Read in a batch file and modify config files and database entries accordingly.
'''

'''
This class contains an object representation of all the
OpenStack config files.  It can process given merge files
over these config files.  Once files have been processed
it can write the config files back out with their new contents.
'''
class OSBatchFileProcessor(object):

    '''
    @param Root directory where all config files can be found.
    Files are read in and prepared for processing.
    '''
    def __init__(self, confFileRoot):
        self.confFileSet = OSConfigFileGroup(confFileRoot)
        
    ''' 
    Process the given merge file and in turn 
    process relevant OpenStack config files.
    '''
    def process (self, mergeFileName):

        currentSectionName = None
        currentOSFileObject = None
        currentInstallName = "none"
        echoList = list()
        
        log.message("Processing merge file: " + mergeFileName)
        lines = [line.rstrip('\n') for line in open(mergeFileName)]
        
        for line in lines:
            if (len(line) > 0):
                # SECTION declairation
                if (line[0] == "["):
                    i = line.index("]")
                    if ( i < 1 ):
                        log.error("Syntax error.  Unclosed section " + line)
                        log.error("Exiting due to error")
                        return
                    else:
                        currentSectionName = line[1:i]
                        
                    continue
                # else Merge File Directive
                if (line[0] == "&"):
                    values = line.split()
                    # Switch to the given conf file
                    if ( values[0] == MF_CONF_FILE):
                        log.message("Updating configuration file: " + values[1])
                        currentOSFileObject = self.confFileSet.getFile(values[1])
                        if ( currentOSFileObject == None):
                            log.error("Can not fine conf file " + values[1])
                            log.error("Exiting due to error")
                            return
                    # Notes include the install name MF_INSTALL_NAME
                    if ( values[0] == MF_INSTALL_NAME):
                        line2 = line.split(' ', 1)[1]
                        log.message("Running installation for: " + line2)
                        currentInstallName = line2
                    # Echo to user
                    if ( values[0] == MF_ECHO):
                        line2 = line.split(' ', 1)[1]
                        echoList.append(line2)
                    
                    continue
                # else Process if not comment
                if (line[0] != "#"):
                    nv = line.split("=")
                    if (len(nv) == 2):
                        fn = currentOSFileObject.getFileName()
                        #assume we have nv pairs
                        log.verbose("Set: File: " + fn + " Section: " + 
                                  currentSectionName + " key: " + nv[0] + " val: " + nv[1])
                        if ( (currentSectionName != None) & (currentOSFileObject != None)):
                            value = ResolveVars(nv[1])
                            currentOSFileObject.set(currentSectionName, nv[0], value, currentInstallName)
                    
        self.confFileSet.printChangedFiles()  
        self.confFileSet.writeChangedFiles()   
        if ( len(echoList) > 0 ):
            print "-------------------------------------------------"
            for line in echoList:
                print line            




# bp = OSBatchFileProcessor("/Users/chris/git-projects/Pluto/conf-test/")
# bp.process("/Users/chris/git-projects/Pluto/batch-files/liberty-glance-install.txt")





        
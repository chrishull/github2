'''
Created on Feb 23, 2016
Part of project Pluto.  The Openstack Configuraton management tool.

@author: chris
'''
from variables import OPENSTACK_CONF_DIRS
import time
import datetime
from collections import OrderedDict
import json
import os
from prettytable import PrettyTable

# Tag to recognize ourselves
TAG_TEXT = "# [pluto] "
# Actions automatically noted in JSON comments
ACTION_REPLACE = "replace"
ACTION_NEW = "new"
ACTION_DELETE = "delete"
ACTION_ADD_SECTION = "add-section"
ACTION_DELETE_SECTION = "section-commented-out"
ACTION_NONE = "no-action-values-same"

'''
A simple logging container
'''
class OSLogger():
    def __init__(self, logFileName, prefix):
        self.logFileName = logFileName
        self.prefix = prefix
        self.m = True
        self.d = False
        self.v = False
        
    def message(self, message):
        if ( self.m ):
            print self.prefix + " " + message
        
    def debug(self, message):
        if ( self.d ):
            print self.prefix + " " + message
            
    def verbose(self, message):
        if ( self.v ):
            print self.prefix + " " + message    
 
    def error(self, message):
        print self.prefix + " ERROR: " + message  


log = OSLogger("", "OSFileProcessor")

'''
Add change information to the config files.
'''
class OSTracker():
    
    def __init__(self, json = False):
        self.json = json
            
    '''
        Convert some data to JSON for recording in file comments for 
        history tracking.  Might implement rollback, etc.
        @param Action,  add replace delete
        @param key such as notification_driver
        @param old value
        @param new value
        @param install  Such as installing Cinder
        @return JSON comment for config files to keep track of changes
    '''
    def makeJSONText (self, action, key, oldVal, newVal, install):
        ts = time.time()
        st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
        if json == True:
            ss = TAG_TEXT + json.dumps(OrderedDict([("action", action), 
                ("key", key), ("oldval", oldVal), ("newval", newVal), 
                 ("install", install), ("timestamp", st) ] ))
        else:
            ss = TAG_TEXT
            if ( action == ACTION_NEW):
                ss = ss + "added on " + st + " for " + install
            if ( action == ACTION_REPLACE):
                ss = ss + key + " = " + oldVal + " changed on " + st + " for " + install
            if ( action == ACTION_DELETE):
                ss = ss + key + " = " + oldVal + " deleted on " + st + " for " + install
            if ( action == ACTION_ADD_SECTION):
                ss = ss + "section [" + newVal + "] added on " + st + " for " + install
            if ( action == ACTION_DELETE_SECTION):
                ss = ss + "section [" + newVal + "] commented out on " + st + " for " + install
        return ss
         
    def addJSON (self, textList, action, key, oldVal, newVal, install):
        ss = self.makeJSONText (action, key, oldVal, newVal, install)
        # Insert JUST After the [SECTION] text
        if ( action == ACTION_NEW):
            textList.insert(1, ss)
            return
        textList.append(ss)
    
tracker = OSTracker()

'''
This class represents a section within an Openstack configuration
file.  It contains all relevant NV pairs and mechanisms to 
add, delete, and modify them.
'''
class OSConfFileSection(object):


    def __init__(self, sectionName):
        self.lines = list()
        self.name = sectionName
        
    def addLine (self, line):
        self.lines.append(line)
        
    '''
        Given a NV pair, replace and note previous value in comment.
        If none is found then add the nv pair
        @param name of the nv pair
        @param Value to set
        @param Installation being set up, like Nova or Cinder
    '''
    def set (self, name, value, install):
        name = name.strip()
        value = value.strip()
        nvAssign = name + "=" + value
        deleteKey = False
        if (len(value) == 0):
            deleteKey = True
        newLines = list()
        found = False
        for line in self.lines:
            replaced = False
            if (len(line) > 0):
                if ( line[0] != "#"):
                    nv = line.split("=")
                    if (len(nv) == 2):
                        # Did we find it?
                        n = nv[0].strip()
                        v = nv[1].strip()
                        if ( name == n):
                            if ( deleteKey == False):
                                if ( v != value):
                                    tracker.addJSON (newLines, ACTION_REPLACE, name, v, value, install)
                                    newLines.append(nvAssign)
                                    log.verbose("Replaced: " + nvAssign + " old value was " + v
                                                 + " [" + self.name + "]")
                                else:
                                    # Don't treack repeat entries, but log them is ok.
                                    # tracker.addJSON (newLines, ACTION_NONE, name, v, value, install)
                                    newLines.append(nvAssign)
                                    log.verbose("Nothing done: " + nvAssign + " old value same as new"
                                                 + " [" + self.name + "]")
                            else:
                                tracker.addJSON (newLines, ACTION_DELETE, name, nv[1], value, install)
                                log.verbose("Deleted: " + nvAssign + " new value was blank"
                                             + " [" + self.name + "]")                            
                            replaced = True
                            found = True
            if ( replaced == False ):
                newLines.append(line)
        # If we are adding a new value, i.e. never found old one
        if ( (found == False) & (deleteKey == False) ):
            # Insert JUST After the [SECTION] text
            newLines.insert(1, nvAssign)
            tracker.addJSON (newLines, ACTION_NEW, name,"NONE", value, install)      
            newLines.insert(1, "")     
            log.verbose("Added new assignment: " + nvAssign + " [" + self.name + "]")
            
        self.lines = newLines
        
    '''
        Delete this section by commenting out all NV pairs.
        Add note that section was deleted.  We will leave the opening tag.
    '''
    def delete (self, install):
        newLines = list()
        for line in self.lines:
            needsComment = True
            if (len(line) > 0):
                if ( line[0] == "#"):
                    needsComment = False
                # DO NOT comment out the section name
                if ( line[0] == "["):
                    needsComment = False
            if ( needsComment ):
                newLines.append ("# " + line)
            else:
                newLines.append (line)
        s = tracker.makeJSONText (ACTION_DELETE_SECTION, "section-name","NONE", self.name, install)
        newLines.append(s)
        self.lines = newLines
        log.verbose("Section contents commented out: [" + self.name + "]")
    
    '''
        Return a string of name value pairs only.
    '''
    def getInfo (self):
        ret = ""
        for line in self.lines:
            if (len(line) > 0):
                if ( line[0] != "#"):
                    nv = line.split("=")
                    if (len(nv) == 2):
                        ret = ret + line + "\n"
        return ret
    
    '''
        Return an array of name value pairs in List form.
        NV pairs could possible repeat between sections so no Dict.
        A list of pairs.
    '''
    def getNVPairs(self):
        pairList = list()
        for line in self.lines:
            if (len(line) > 0):
                if ( line[0] != "#"):
                    nv = line.split("=")
                    if (len(nv) == 2):
                        nvPair = [nv[0], nv[1]]
                        pairList.append(nvPair)
        return pairList
        
    '''
        Return a string of this section as it would appear in a file.
    '''
    def __str__(self):
        ret = ""
        for line in self.lines:
            ret = ret + line + "\n"
        return ret
            
'''
This class represents an Openstack Configuration File.
It contains several OSConfFileSection objects.
'''
class OSConfFile(object):

    def __init__(self, filePath, fileName):
        self.filePath = filePath
        self.fileName = fileName
        self.fullPath = filePath + fileName
        # Files have two lists
        self.top = list()
        self.sections = list()
        self.processed = False
        self.process()
        
    '''
    Parse file into comments, sections and NV pairs.
    '''
    def process(self):
        # Should only ever need to be processed once, but just in case.
        if ( self.processed == True):
            return
        
        # Set the changed flag to FALSE
        self.changed = False
        
        # States
        currentSection = None
        self.top = list()
        
        lines = [line.rstrip('\n') for line in open(self.fullPath)]
        
        for line in lines:
            if (len(line) > 0):
                if (line[0] == "["):
                    i = line.index("]")
                    if ( i < 1 ):
                        log.error("Syntax error.  Unclosed section " + line)
                        log.error("Exiting due to error")
                        return
                    else:
                        s = line[1:i]
                        currentSection = OSConfFileSection(s)
                        self.sections.append(currentSection)
                        
            # Add whateve the line is to the current section
            if (currentSection == None):
                self.top.append(line)
            else:
                currentSection.addLine(line)
        # Unless we bailed early, consider the file processed.        
        self.processed = True
        
    '''
        Replace a value given a section and a name / v pair
        If section doesn't exist it will be created.
    ''' 
    def set (self, sectionName, name, value, install):
        
        # Being conservative, we'll assume thsi will result in a change.
        self.changed = True
        
        sectionFound = False
        for section in self.sections:
            if ( section.name == sectionName):
                section.set(name, value, install)
                sectionFound = True
        if ( sectionFound == False):
            newSection = OSConfFileSection(sectionName)  
            newSection.addLine("[" + sectionName + "]")
            s = tracker.makeJSONText (ACTION_ADD_SECTION, "section-name", "NONE", sectionName, install) 
            newSection.addLine(s)
            newSection.set(name, value, install)
            self.sections.append(newSection)
            log.verbose("New section added: [" + sectionName + "]")
        
    '''
        Comment out the contents of an entire Section, leaving the
        section intact.
    ''' 
    def delete (self, sectionName, install):
        self.changed = True
        for section in self.sections:
            if ( section.name == sectionName):
                section.delete(install)
                
    '''
    Did file change
    '''      
    def hasFileChanged(self):
        return self.changed
    
    '''
        Return a string of sections with name value pairs only.
    '''
    def getInfo(self):
        ret = ""
        for section in self.sections:
            ret = ret +  "[" + section.name + "]\n"
            ret = ret + section.getInfo()
        return ret
    
    def getFileName(self):
        return self.fileName
    
    '''
    Check to see if a section exists
    '''
    def hasSection (self, sectName):
        for section in self.sections:
            if (section.name == sectName):
                return True
        return False
                    
    
    '''
    Print a pretty table of this file's nv pairs and sections
        Thank you PrettyTable.py
        Copyright (c) 2009-2013, Luke Maurits <luke@maurits.id.au>
        All rights reserved.
        With contributions from:
        Chris Clark
        Klein Stephane
    '''
    def printFile (self):
        fn = self.getFileName()
        fns = fn.split(".")
        t = PrettyTable([fns[0] + ': Section', 'Key', 'Value'])
        for section in self.sections:
            nvPairs = section.getNVPairs()
            for pair in nvPairs:
                t.add_row([ section.name, pair[0], pair[1]  ])
        t.align = "l"
        print t

    
    '''
    Print a pretty table of ONE SECTION in this file.
        Thank you PrettyTable.py
        Copyright (c) 2009-2013, Luke Maurits <luke@maurits.id.au>
        All rights reserved.
        With contributions from:
        Chris Clark
        Klein Stephane
    '''
    def printFileSection (self, sectionName):
        fn = self.getFileName()
        fns = fn.split(".")
        t = PrettyTable([fns[0] + ': Section', 'Key', 'Value'])
        found = False
        for section in self.sections:
            if (section.name == sectionName):
                found = True
                nvPairs = section.getNVPairs()
                for pair in nvPairs:
                    t.add_row([ section.name, pair[0], pair[1]  ])
        if found:
            t.align = "l"
            print t
        
    '''
    Write out this file
    '''
    def writeFile (self):
        log.verbose("Writing Openstack config file: " + self.fullPath)
        f = open(self.fullPath, "w")
        f.write( str(self) )
        f.close
        self.changed = False
        
    '''
        Return a string of this file object as it would 
        appear in an actual file.
    '''
    def __str__(self):
        ret = ""
        for line in self.top:
            ret = ret + line + "\n"
        for section in self.sections:
            ret = ret + str(section)
        return ret

        
'''
This class represents the entire group of OS config files
It serves as a simple container.  Given a file name you can 
extract an OSConfFile object.
XXX Check for duplicates.  Someday nova-compute.conf may exist in two dirs.
'''
class OSConfigFileGroup ():
    
    '''
    @param The root file path to search for all files ending in 
    .conf
    '''
    def __init__(self, rootPath):
        self.rootPath = rootPath
        self.confFileDict = {}
        confFileDict = {}
        for osDir in OPENSTACK_CONF_DIRS:
            rootPath2 = rootPath + osDir
            for root, dirs, files in os.walk(rootPath2):
                root = root + "/"
                for f in files:
                    if f.endswith(".conf"):
                        o = OSConfFile( root, f )
                        confFileDict[f] = o
                        log.verbose("Read in file: " + f)
                    if f.endswith(".ini"):
                        o = OSConfFile( root, f )
                        confFileDict[f] = o
                        log.verbose("Read in file: " + f)
        self.confFileDict = confFileDict     
             
    '''
    Given a file name get the object.
    '''
    def getFile (self, fileName):   
        if ( len(fileName.split(".")) < 2):
            fileName = fileName + ".conf"
        f = self.confFileDict.get(fileName)
        if ( f == None ):
            log.error("No such Openstack config file: " + fileName)
        return f
    
    '''
    Return str of all file names
    '''
    def getFileNames (self):
        ret = list()
        for key in self.confFileDict:
            ret.append(key)
        return ret
    
    def printFileList (self):
        t = PrettyTable(['Name', 'Full Path'])
        for key in self.confFileDict:
            # print key, self.confFileDict[key]
            t.align = "l"
            fileObj = self.confFileDict[key]
            t.add_row( [key, fileObj.filePath +  fileObj.fileName ] )
        print t
    
    '''
    Print a nice table of all changed files
    '''
    def printChangedFiles(self):
        fileObjList = self.confFileDict.values()
        for fileObj in  fileObjList:
            if fileObj.hasFileChanged() == True:
                fileObj.printFile()
                
    '''
    Write out all the config files that have changed
    '''
    def writeChangedFiles(self):
        fileObjList = self.confFileDict.values()
        for fileObj in  fileObjList:
            if fileObj.hasFileChanged() == True:
                fileObj.writeFile()
        
'''
Test a specific file object
'''
def UnitTest1(f):
    # f = OSConfFile("/Users/chris/git-projects/Pluto/glance-sample/", "test.conf") 
    
    print "---- showing"
    print (f)
    print "---- get info"
    s = f.getInfo()
    print s
    f.set("DEFAULT", "test-replace", "new-value", "Test to see if first-val became new val DEF 1")
    f.set("DEFAULT", "test-new-val", "completely new entry", "Test to see if we can enter a new val. DEF 2")    
    f.delete("TEST_DELETE_SECTION", "Section should be commented out  TEST_DEL_SEC 3")
    f.set("TEST_DELETE_SECTION", "post-delete", "new-value", "Adding a new value to TEST_DEL_SEC 4")
    f.set("TEST_DELETE_SECTION", "post-delete", "replaced-value", "Replacing the new value TEST_DEL_SEC 5")
    f.set("TEST_ADD_SECTION", "new-sec", "new-value", "Adding a new section TEST_ADD_SEC 6")
    f.set("TEST_ADD_SECTION", "test-replace", "first-value", "Checking to be sure sec addressing works TEST_ADD_SEC 7")
    f.set("TEST_ADD_SECTION", "test-replace", "replaced-value", "Checking to be sure sec addressing works TEST_ADD_SEC 8")
    f.set("DEFAULT", "test-replace", "new-value", "Repeat value, should do nothing 9")

    f.printFile()

    print "---- showing whole file"
    print (f)
    
'''
Test file container
'''
def UnitTest2():
    
    ftree = OSConfigFileGroup("/Users/chris/git-projects/Pluto/conf-test/")
    f = ftree.getFile("test.conf")
    UnitTest1(f)
    
    keyList = ftree.getFileNames("/Users/chris/git-projects/Pluto//")
    for k in keyList:
        print k
        
        
# f = OSConfFile("/Users/chris/git-projects/Pluto/test-conf-files/", "test-conf1.conf")
# UnitTest1(f)


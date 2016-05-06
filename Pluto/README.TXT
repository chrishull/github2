Pluto for Openstack - Readme
Feb 28 2016 - Christopher Hull
chrishull42@gmail.com

--------------------------------------------
What is this
--------------------------------------------

Pluto is a command line tool for managing Openstack .conf files.  It allows you to view and edit these files in a familiar Openstack command line like way. Pluto keeps an audit trail of your changes within the files.  The tool was designed to allow you to easily install new versions of Openstack based on the instructions provided for each release.  Batch files are created straight out of the Openstack install guide.  These files arerun and as a result update values in the various .conf files.   

Database support coming soon.

--------------------------------------------
Contents
--------------------------------------------

README.TXT  this text.
src   
    Source code containing pluto.py and supporting files.
    About variables.py
    A user editable file exists here as well, containing password and other variables which are
    used in install (batch) files.   See below.

    To run, just type  ./pluto.py -h for instructions.

batch-files	
    This contains a single change file which can be used to set up Glance for Liberty.
    Read the contents of the file for details.   It is designed to be a more or less cut and paste
    of the instructions from the Openstack Liberty install guide.   A lot better than searching and
    replacing values in .conf files.  It will configure for Glance all in one run.   More files
    are needed to complete a basic Liberty suite, but they follow the same pattern as the Glance file.
    liberty-glance-install.txt

conf-orig	
    A set of "original" config files.  Actually they have some junk in them, but can be used
    to reset the test files.

conf-test	
    A set of .conf files to play with.

notes	
    Notes.	

--------------------------------------------	
Setup
--------------------------------------------

Pluto is dependent upon one shell variable, CONF_FILE_PATH.   Like it says, it's the path to your Openstack 
conf files.  Set it to point just above nova/  neutron/ glance/ etc.   So you won't do any harm to a real 
system, you can play around with the files in conf-test.


---- Help

./pluto.py -h
usage: pluto.py [-h] [-v] [-s INSEC] [-k INKEY] [-d INVALUE] [-V]
                func path [path ...]

pluto -- shortdesc

  Created by Christopher Hull on 2016-02-27.
  Copyright 2016 Spillikin Aerospace. All rights reserved.
  http://www.spillikinaerospace.com

  Licensed under the Apache License 2.0
  http://www.apache.org/licenses/LICENSE-2.0

  Distributed on an "AS IS" basis without warranties
  or conditions of any kind, either express or implied.
  
  --- Operation to perform ---
  Like all other Openstack command line front ends, the first param is a function.
  pluto show (followed by one or more conf file names separated by spaces)
  pluto show-section (followed by one or more section names) shows sections for all files.
      You can use this for comparison between files to be sure that, for instance, 
      authentication schemes are identical.
  pluto list (no param)  shows list of known conf files.
  pluto set -s section -k key -d value file(s)
      Sets a section, key to value within a file list.
      Adds a new section if the specified section does not exist.
  pluto set-section -k key -d value section(s)
       Sets key value pairs for the given setcions in all the files thta have that section.
       WILL NOT add the section to files that do not already have it (because that would be REALLY annoying).
  pluto process (followed by a single path/file to a processing text file)  
      This will modify all .conf files in accordance with the instructions within.
      These instructions are designed to look just like those found in the various
      Openstack install guedes.   See samples like liberty-glance-install.txt
      
  When specifying a conf file name (nova.conf, etc) you may omit '.conf' if you choose.

USAGE

positional arguments:
  func                  operation to perform, see above.
  path                  param list for operation, see above.

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         set verbosity level [default: None]
  -s INSEC, --section INSEC
                        set command section
  -k INKEY, --key INKEY
                        set command key
  -d INVALUE, --data INVALUE
                        set command data (value, but v is taken)
  -V, --version         show program's version number and exit


--------------------------------------------
Sample Sessions
--------------------------------------------

-----------------------------
List existing conf files.
-----------------------------

./pluto.py list
List of all Openstack conf files found under: /Users/chris/git-projects/Pluto/conf-test/
     glance-scrubber.conf
     neutron.conf
     glance-registry.conf
     keystone.conf
     cinder.conf
     nova.conf
     glance-cache.conf
     rootwrap.conf
     glance-api.conf
     logging.conf

-----------------------------
Show the contents of a file(s)
-----------------------------

./pluto.py show cinder  keystone
+-----------------------+--------------------+-------------------------------------------------+
| cinder: Section       | Key                | Value                                           |
+-----------------------+--------------------+-------------------------------------------------+
| DEFAULT               | logdir             |  /var/log/cinder                                |
| DEFAULT               | state_path         |  /var/lib/cinder                                |
| DEFAULT               | lock_path          |  /var/lib/cinder/tmp                            |
| DEFAULT               | volumes_dir        |  /etc/cinder/volumes                            |
| DEFAULT               | iscsi_helper       |  lioadm                                         |
| DEFAULT               | rootwrap_config    |  /etc/cinder/rootwrap.conf                      |
| DEFAULT               | auth_strategy      |  keystone                                       |
| DEFAULT               | rpc_backend        |  rabbit                                         |
| DEFAULT               | my_ip              |  172.22.10.5                                    |
| DEFAULT               | verbose            |  True                                           |
| DEFAULT               | enabled_backends   |  lvm                                            |
| DEFAULT               | glance_host        |  controller                                     |
| database              | connection         |  mysql://cinder:openg00dle232@controller/cinder |
| oslo_messaging_rabbit | rabbit_host        |  controller                                     |
| oslo_messaging_rabbit | rabbit_userid      |  openstack                                      |
| oslo_messaging_rabbit | rabbit_password    |  openg00dle232                                  |
| keystone_authtoken    | auth_uri           | URI____URI                                      |
| keystone_authtoken    | auth_url           |  http://controller:35357                        |
| keystone_authtoken    | auth_plugin        |  password                                       |
| keystone_authtoken    | project_domain_id  |  default                                        |
| keystone_authtoken    | user_domain_id     |  default                                        |
| keystone_authtoken    | project_name       |  service                                        |
| keystone_authtoken    | username           |  cinder                                         |
| keystone_authtoken    | password           |  sleestack                                      |
| oslo_concurrency      | lock_path          |  /var/lock/cinder                               |
| lvm                   | volume_driver      |  cinder.volume.drivers.lvm.LVMVolumeDriver      |
| lvm                   | volume_group       |  cinder-volumes                                 |
| lvm                   | iscsi_protocol     |  iscsi                                          |
| lvm                   | iscsi_helper       |  lioadm                                         |
+-----------------------+--------------------+-------------------------------------------------+
+-------------------+--------------+-------------------------------------------------------+
| keystone: Section | Key          | Value                                                 |
+-------------------+--------------+-------------------------------------------------------+
| DEFAULT           | admin_token  |  97096da40e2475e71708                                 |
| DEFAULT           | verbose      |  True                                                 |
| database          | connection   |  mysql://keystone:KEYSTONE_DBPASS@controller/keystone |
| memcache          | servers      |  localhost:11211                                      |
| revoke            | driver       |  keystone.contrib.revoke.backends.sql.Revoke          |
| token             | provider     |  keystone.token.providers.uuid.Provider               |
| token             | driver       |  keystone.token.persistence.backends.memcache.Token   |
+-------------------+--------------+-------------------------------------------------------+

Now That's worth the price of admission.  :-)

-----------------------------
Show a given Section in All 
files that have it.
-----------------------------

./pluto.py show-section  keystone_authtoken
====== Showing all files that contain Section [keystone_authtoken]
       An empty table indicates that the section exists but has no values.
+--------------------+--------------------+--------------------------+
| neutron: Section   | Key                | Value                    |
+--------------------+--------------------+--------------------------+
| keystone_authtoken | auth_uri           | URI____URI               |
| keystone_authtoken | auth_url           |  http://controller:35357 |
| keystone_authtoken | auth_plugin        |  password                |
| keystone_authtoken | project_domain_id  |  default                 |
| keystone_authtoken | user_domain_id     |  default                 |
| keystone_authtoken | project_name       |  service                 |
| keystone_authtoken | username           |  neutron                 |
| keystone_authtoken | password           |  sleestack               |
+--------------------+--------------------+--------------------------+
+--------------------------+-------------------+-------------------------+
| glance-registry: Section | Key               | Value                   |
+--------------------------+-------------------+-------------------------+
| keystone_authtoken       | auth_uri          | URI____URI              |
| keystone_authtoken       | auth_url          | http://controller:35357 |
| keystone_authtoken       | auth_plugin       | password                |
| keystone_authtoken       | project_domain_id | default                 |
| keystone_authtoken       | user_domain_id    | default                 |
| keystone_authtoken       | project_name      | service                 |
| keystone_authtoken       | username          | glance                  |
| keystone_authtoken       | password          | sleestack7              |
+--------------------------+-------------------+-------------------------+
+--------------------+--------------------+--------------------------+
| cinder: Section    | Key                | Value                    |
+--------------------+--------------------+--------------------------+
| keystone_authtoken | auth_uri           | URI____URI               |
| keystone_authtoken | auth_url           |  http://controller:35357 |
| keystone_authtoken | auth_plugin        |  password                |
| keystone_authtoken | project_domain_id  |  default                 |
| keystone_authtoken | user_domain_id     |  default                 |
| keystone_authtoken | project_name       |  service                 |
| keystone_authtoken | username           |  cinder                  |
| keystone_authtoken | password           |  sleestack               |
+--------------------+--------------------+--------------------------+


-----------------------------
Set a Section, Key, Value
in a file.
-----------------------------

./pluto.py set -s keystone_authtoken -k auth_uri -d http/a/real/URI glance-api  
+---------------------+--------------------------+------------------------------------------------+
| glance-api: Section | Key                      | Value                                          |
+---------------------+--------------------------+------------------------------------------------+
| DEFAULT             | verbose                  | True                                           |
| DEFAULT             | notification_driver      | noop                                           |
| database            | connection               | mysql://glance:openg00dle333@controller/glance |
| keystone_authtoken  | password                 | sleestack7                                     |
| keystone_authtoken  | username                 | glance                                         |
| keystone_authtoken  | project_name             | service                                        |
| keystone_authtoken  | user_domain_id           | default                                        |
| keystone_authtoken  | project_domain_id        | default                                        |
| keystone_authtoken  | auth_plugin              | password                                       |
| keystone_authtoken  | auth_url                 | http://controller:35357                        |
| keystone_authtoken  | auth_uri                 | http/a/real/URI                                |
| paste_deploy        | flavor                   | keystone                                       |
| glance_store        | default_store            | file                                           |
| glance_store        | filesystem_store_datadir | /var/lib/glance/images/                        |
+---------------------+--------------------------+------------------------------------------------+



-----------------------------
Synchronize a Section, Key, 
Value across all files.
-----------------------------

./pluto.py set-section   -k auth_uri -d http/synchronized/across/all/files  keystone_authtoken  
====== Setting values in all files that contain Section [keystone_authtoken]
+--------------------+--------------------+------------------------------------+
| neutron: Section   | Key                | Value                              |
+--------------------+--------------------+------------------------------------+
| keystone_authtoken | auth_uri           | http/synchronized/across/all/files |
| keystone_authtoken | auth_url           |  http://controller:35357           |
| keystone_authtoken | auth_plugin        |  password                          |
| keystone_authtoken | project_domain_id  |  default                           |
| keystone_authtoken | user_domain_id     |  default                           |
| keystone_authtoken | project_name       |  service                           |
| keystone_authtoken | username           |  neutron                           |
| keystone_authtoken | password           |  sleestack                         |
+--------------------+--------------------+------------------------------------+
+--------------------------+-------------------+------------------------------------+
| glance-registry: Section | Key               | Value                              |
+--------------------------+-------------------+------------------------------------+
| keystone_authtoken       | auth_uri          | http/synchronized/across/all/files |
| keystone_authtoken       | auth_url          | http://controller:35357            |
| keystone_authtoken       | auth_plugin       | password                           |
| keystone_authtoken       | project_domain_id | default                            |
| keystone_authtoken       | user_domain_id    | default                            |
| keystone_authtoken       | project_name      | service                            |
| keystone_authtoken       | username          | glance                             |
| keystone_authtoken       | password          | sleestack7                         |
+--------------------------+-------------------+------------------------------------+
+--------------------+--------------------+------------------------------------+
| cinder: Section    | Key                | Value                              |
+--------------------+--------------------+------------------------------------+
| keystone_authtoken | auth_uri           | http/synchronized/across/all/files |
| keystone_authtoken | auth_url           |  http://controller:35357           |
| keystone_authtoken | auth_plugin        |  password                          |
| keystone_authtoken | project_domain_id  |  default                           |
| keystone_authtoken | user_domain_id     |  default                           |
| keystone_authtoken | project_name       |  service                           |
| keystone_authtoken | username           |  cinder                            |
| keystone_authtoken | password           |  sleestack                         |
+--------------------+--------------------+------------------------------------+


-----------------------------
And finally
Run Openstack Installation
files.
-----------------------------

BEFORE
./pluto.py show glance-api  glance-registry  
+---------------------+---------------------------+---------------------------------------------+
| glance-api: Section | Key                       | Value                                       |
+---------------------+---------------------------+---------------------------------------------+
| glance_store        | default_store             |  file                                       |
| glance_store        | filesystem_store_datadir  |  /home/glance/images/total/nonsense/default |
+---------------------+---------------------------+---------------------------------------------+
+--------------------------+----------------------+--------------------------+
| glance-registry: Section | Key                  | Value                    |
+--------------------------+----------------------+--------------------------+
| DEFAULT                  | notification_driver  |  noop                    |
| keystone_authtoken       | auth_uri             |  http://controller:5000  |
| keystone_authtoken       | auth_url             |  http://controller:35357 |
| keystone_authtoken       | auth_plugin          |  password                |
| keystone_authtoken       | project_domain_id    |  default                 |
| keystone_authtoken       | user_domain_id       |  default                 |
| keystone_authtoken       | project_name         |  service                 |
| keystone_authtoken       | username             |  glance                  |
| keystone_authtoken       | password             |  oldsleestack123488      |
| paste_deploy             | flavor               |  keystone                |
+--------------------------+----------------------+--------------------------+

AFTER
./pluto.py process ../batch-files/liberty-glance-install.txt   
Processing using file: ../batch-files/liberty-glance-install.txt
BatchFileProcessor Processing merge file: ../batch-files/liberty-glance-install.txt
BatchFileProcessor Running installation for: Liberty Glance service initial install
BatchFileProcessor Switching to .conf file glance-api.conf
BatchFileProcessor Set: File: glance-api.conf Section: database key: connection  val:  mysql://glance:GLANCE_DBPASS@controller/glance
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: auth_uri  val:  http://controller:5000
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: auth_url  val:  http://controller:35357
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: auth_plugin  val:  password
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: project_domain_id  val:  default
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: user_domain_id  val:  default
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: project_name  val:  service
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: username  val:  glance
BatchFileProcessor Set: File: glance-api.conf Section: keystone_authtoken key: password  val:  GLANCE_PASS
BatchFileProcessor Set: File: glance-api.conf Section: paste_deploy key: flavor  val:  keystone
BatchFileProcessor Set: File: glance-api.conf Section: glance_store key: default_store  val:  file
BatchFileProcessor Set: File: glance-api.conf Section: glance_store key: filesystem_store_datadir  val:  GLANCE_IMAGE_STORE
BatchFileProcessor Set: File: glance-api.conf Section: DEFAULT key: notification_driver  val:  noop
BatchFileProcessor Set: File: glance-api.conf Section: DEFAULT key: verbose  val:  True
BatchFileProcessor Switching to .conf file glance-registry.conf
BatchFileProcessor Set: File: glance-registry.conf Section: database key: connection  val:  mysql://glance:GLANCE_DBPASS@controller/glance
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: auth_uri  val:  http://controller:5000
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: auth_url  val:  http://controller:35357
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: auth_plugin  val:  password
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: project_domain_id  val:  default
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: user_domain_id  val:  default
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: project_name  val:  service
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: username  val:  glance
BatchFileProcessor Set: File: glance-registry.conf Section: keystone_authtoken key: password  val:  GLANCE_PASS
BatchFileProcessor Set: File: glance-registry.conf Section: paste_deploy key: flavor  val:  keystone
BatchFileProcessor Set: File: glance-registry.conf Section: DEFAULT key: notification_driver  val:  noop
BatchFileProcessor Set: File: glance-registry.conf Section: DEFAULT key: verbose  val:  True
+--------------------------+---------------------+------------------------------------------------------------+
| glance-registry: Section | Key                 | Value                                                      |
+--------------------------+---------------------+------------------------------------------------------------+
| DEFAULT                  | verbose             | True                                                       |
| DEFAULT                  | notification_driver | noop                                                       |
| database                 | connection          | mysql://glance:changeThisPassword-glance@controller/glance |
| keystone_authtoken       | auth_uri            | http://controller:5000                                     |
| keystone_authtoken       | auth_url            | http://controller:35357                                    |
| keystone_authtoken       | auth_plugin         | password                                                   |
| keystone_authtoken       | project_domain_id   | default                                                    |
| keystone_authtoken       | user_domain_id      | default                                                    |
| keystone_authtoken       | project_name        | service                                                    |
| keystone_authtoken       | username            | glance                                                     |
| keystone_authtoken       | password            | sleestack7-glance                                          |
| paste_deploy             | flavor              | keystone                                                   |
+--------------------------+---------------------+------------------------------------------------------------+
+---------------------+--------------------------+------------------------------------------------------------+
| glance-api: Section | Key                      | Value                                                      |
+---------------------+--------------------------+------------------------------------------------------------+
| DEFAULT             | verbose                  | True                                                       |
| DEFAULT             | notification_driver      | noop                                                       |
| database            | connection               | mysql://glance:changeThisPassword-glance@controller/glance |
| keystone_authtoken  | password                 | sleestack7-glance                                          |
| keystone_authtoken  | username                 | glance                                                     |
| keystone_authtoken  | project_name             | service                                                    |
| keystone_authtoken  | user_domain_id           | default                                                    |
| keystone_authtoken  | project_domain_id        | default                                                    |
| keystone_authtoken  | auth_plugin              | password                                                   |
| keystone_authtoken  | auth_url                 | http://controller:35357                                    |
| keystone_authtoken  | auth_uri                 | http://controller:5000                                     |
| paste_deploy        | flavor                   | keystone                                                   |
| glance_store        | default_store            | file                                                       |
| glance_store        | filesystem_store_datadir | /var/lib/glance/images/                                    |
+---------------------+--------------------------+------------------------------------------------------------+



-----------------------------
Audit Trails
-----------------------------

These appear within the .conf files so you can keep track of changes.
All changes to key value pairs are grouped together in order of occurrence. 

# [pluto] added on 2016-02-28 19:18:31 for Liberty Glance service initial install
verbose=True

# [pluto] added on 2016-02-28 19:18:31 for Liberty Glance service initial install
connection=mysql://glance:changeThisPassword-glance@controller/glance

# [pluto] filesystem_store_datadir = /home/glance/images/total/nonsense/default changed on 2016-02-28 19:18:31 for Liberty Glance service initial install
filesystem_store_datadir=/var/lib/glance/images/

---------------------------------------------------
Sample Glance Liberty Installation file
---------------------------------------------------

liberty-glance-install.txt

# Pluto - Openstack Configuration Manager
# Batch file for Openstack Liberty Glance installation
#
# This batch file contains instructions for installing Liberty Glance as seen here.
# http://docs.openstack.org/liberty/install-guide-rdo/glance-install.html
# You can more or less cut and paste config file instructions from the above page.
# See below.

# Processor Directives
#
# There are a small number of processor directives in this file.  
# They all begin with a "&"

# Processor Directive  &INSTALL_NOTE
# This processor will automatically add comments to .conf files.
# This allows you to track changes and do some debugging if necessary.
# This note simply marks the initial installation.
&INSTALL_NOTE Liberty Glance service initial install

# Processor Directive  &CONF_FILE_NAME
# All subsequent modifications will take place for the conf file specified here.
# No need for full path.  File searches are constrained by a root spec plus list
# of known Openstack dirs ( /etc plus /nova, /glance, /neutron...)

# Variable Resolution
#
# Variables seen thruout the install guide, such as GLANCE_DBPASS are automatically resolved 
# based on dictionary settings.
# Find them in variables.py  OPENSTACK_VARIABLES and change them to your liking.
# You can cut and paste settings right out of the Openstack install instructions.
# We skip "..." and lines beginning with a '#' among others.

# ====================================================================================
# Start of instructions from Openstack Install Guide


# Edit the /etc/glance/glance-api.conf file and complete the following actions:
&CONF_FILE_NAME glance-api.conf

# In the [database] section, configure database access:
[database]
...
connection = mysql://glance:GLANCE_DBPASS@controller/glance

# In the [keystone_authtoken] and [paste_deploy] sections, configure Identity service access:
[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = glance
password = GLANCE_PASS

[paste_deploy]
...
flavor = keystone

# In the [glance_store] section, configure the local file system store and location of image files:
[glance_store]
...
default_store = file
filesystem_store_datadir = GLANCE_IMAGE_STORE

# In the [DEFAULT] section, configure the noop notification driver to disable 
# notifications because they only pertain to the optional Telemetry service:
[DEFAULT]
...
notification_driver = noop

# (Optional) To assist with troubleshooting, enable verbose logging in the [DEFAULT] section:
[DEFAULT]
...
verbose = True


#--------------------------------------------------------------------------------------
# Edit the /etc/glance/glance-registry.conf file and complete the following actions:
&CONF_FILE_NAME glance-registry.conf

# In the [database] section, configure database access:
[database]
...
connection = mysql://glance:GLANCE_DBPASS@controller/glance

# In the [keystone_authtoken] and [paste_deploy] sections, configure Identity service access:
[keystone_authtoken]
...
auth_uri = http://controller:5000
auth_url = http://controller:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = glance
password = GLANCE_PASS

[paste_deploy]
...
flavor = keystone

# In the [DEFAULT] section, configure the noop notification driver to disable 
# notifications because they only pertain to the optional Telemetry service:

[DEFAULT]
...
notification_driver = noop

# (Optional) To assist with troubleshooting, enable verbose logging in the [DEFAULT] section:

[DEFAULT]
...
verbose = True



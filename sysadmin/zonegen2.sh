#!/bin/bash

# Simple zone file and named.conf fragment generator.
# Oct 17 2013
# Christopher Hull    Spillikin Aerospace
# www.spillikin.co and org
#
# TThe zone file template used here is based on example zone
# files used under CeotOS 6.2
# Past configurations differentiated between internal and external
# DNS, but the latest CeotOS example appears to only deal with
# externally facing data.  So support for internal has been dropped.

# Default Params
# You can change these here, or via the script.
DOMAIN_NAME=chrishull.com
IP_ADDRESS=75.25.159.249
ZONE_PATH=/etc/named/zones/
# Teting
# ZONE_PATH=/Users/chris/zones
E_FILE=named_conf_fragment.txt
NS1=ns1.chrishull.com
NS2=ns1.starshine.org
NS1_IP=75.25.159.249
NS2_IP=207.192.72.106
SERIAL_NUM=2013101501

# Prompt user and read input.  If user hits cr, then passed in
# test is spit out.   $1 is prompt  $2 is assigned if CR hit.
# $REPLY is assigned as return value.
read_text () {
	printf "$1 [$2]: "
	read -p "" in
	if [ -z $in ]
		then
			REPLY=$2
			return 0
	fi
	REPLY=$in
	return 0
}

# Generate the zone file for a specific domain name.
# Requires SERIAL_NUM, IP_ADDRESS and DOMAIN_NAME
# Change this template as new knowledge is acquired.
gen_zone_file() {

cat << EOF
;; This template generated file is based on a sample zone file
;; used with CentOS 6.2
;; This file is for domain $DOMAIN_NAME
;; Template created on Oct 25 2013
;; File generated on `date`
;; SET PERMISSIONS to match this....
;; -rw-r-----. 1 root named 1051 Oct 25 18:50 /etc/named.conf
\$TTL 86400
@   IN  SOA     ns1.$DOMAIN_NAME. root.$DOMAIN_NAME. (
        $SERIAL_NUM  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
; Specify our two nameservers
		IN	NS		$NS1.
		IN	NS		$NS2.
; We have a mail server too (added by me)
		IN	MX		10       mta.$DOMAIN_NAME.

; Resolve nameserver hostnames to IP, replace with your two droplet IP addresses.
ns1		IN	A		$NS1_IP
ns2		IN	A		$NS2_IP

; Define hostname -> IP pairs which you wish to resolve (I added mta and wiki)
@		IN	A		$IP_ADDRESS
www		IN	A		$IP_ADDRESS
mta		IN	A		$IP_ADDRESS
wiki	IN	A		$IP_ADDRESS
EOF
}
#   End  gen_zone_file


# Generate named.conf fragment for a specific domain name.
# Requires ZONE_PATH and DOMAIN_NAME
gen_named_conf_frag() {
cat << EOF
      zone "$DOMAIN_NAME" IN {
        type master;
        file "$ZONE_PATH/$DOMAIN_NAME.db";
		allow-update    { none; };
      };
EOF
}
# End gen_named_conf_frag

# Gen a zone file plus fragment
# This actually writes files.  Creates entire zone file
# and appends to fragment file.
gen_all() {

	echo "Creating files...."
	if [ -a $ZONE_PATH/$DOMAIN_NAME.db ] 
	then 
		read_text "$DOMAIN_NAME.db exists, overwrite? " "y"
		if [ $REPLY != "y" ]
			then
				echo "Zone file not created and $E_FILE not appended."
				return 0
			fi
	fi
    gen_zone_file > $ZONE_PATH/$DOMAIN_NAME.db
	gen_named_conf_frag >> $ZONE_PATH/$E_FILE
	echo "Done creating files."
	echo
}


# Show and set parameters
set_params() {

	read_text "Set the IP address to use for zone file" $IP_ADDRESS
	IP_ADDRESS=$REPLY
	read_text "Set the location where zone files are to be placed (full path)" $ZONE_PATH
	ZONE_PATH=$REPLY	
	read_text "Set the name for Nameserver 1" $NS1
	NS1=$REPLY	
	read_text "Set the IP address for NS1" $NS1_IP
	NS1_IP=$REPLY	
	read_text "Set the name for Nameserver 2" $NS2
	NS2=$REPLY	
	read_text "Set the IP address for NS2" $NS2_IP
	NS2_IP=$REPLY	

}

# Create or recreate the conf fragment file.
create_ff () {
	echo "Starting new $ZONE_PATH/$E_FILE"
	echo "// List of generated zone files follows"         > $ZONE_PATH/$E_FILE
	echo "// This is to be added to the named.conf file." >> $ZONE_PATH/$E_FILE
	echo "// Generated on date `date`"  >> $ZONE_PATH/$E_FILE
	echo >> $ZONE_PATH/$E_FILE
}

# Create a zone file.  Append to conf fragment, or start a new
# one depending on what user want's to do.
create_files() {

	read_text "Input a domain name" $DOMAIN_NAME
	DOMAIN_NAME=$REPLY
	if [ ! -d $ZONE_PATH ]
	then
		read_text "$ZONE_PATH does not exist.  Create it?" "y"
		if [ $REPLY == "y" ]
		then
			echo "Creating $ZONE_PATH"
			mkdir -p $ZONE_PATH
		else
			echo "Can not continue with file creation unless $ZONE_PATH exists."
			return 0
		fi
	fi
	
	# Check to see if frag file exists.  If so, offer opportunity to 
	# recreate or append to existing
	if [ -a $ZONE_PATH/$E_FILE ]
	then
		read_text "$ZONE_PATH/$E_FILE already exists.  Type a to append or r to recreate" "a"
		if [ $REPLY != "a" ]
		then
			create_ff
		fi
	else
		create_ff
	fi
	
	read_text "Change IP address, hit CR to keep current one." $IP_ADDRESS
	IP_ADDRESS=$REPLY
	
	echo "A serial number is needed for your zone file.  This allows secondaries to"
	echo "know if they need to refersh your domain data."
	echo "It is typically date based, of the form yyyymmdd followed by a 2 digit number xx"
	read_text "Input a serial number to use based on date, ie 2013101501: " $SERIAL_NUM
	
	gen_all
}

# Cat a file in the zone dir.
show_file () {
	
	read_text "Cat the file " $DOMAIN_NAME.db
	cat $ZONE_PATH/$REPLY
}

# Display some info and exit
quit () {
	echo
	echo "==== Exiting ===="
	echo "Don't forget to set ownership and permissions for all zone files."
	echo "Permissions should look something like this..."
	echo "rw-r-----. 1 root named 1051 Oct 25 18:50 /etc/foo.conf"
	echo "Here is the current contents of your zone file folder $ZONE_PATH"
	ls -la $ZONE_PATH
	echo 
	echo "Also, add links to zone files found in $ZONE_PATH/$E_FILE to named.conf."
	echo "The fragment file looks like this..."
	cat $ZONE_PATH/$E_FILE
	echo 
	echo "Finally, be sure you restart named."
	echo 
	echo "Exiting"
	exit 0
}


# ===============================================
# main

echo "This script will help you create zone files for your Domain Name Server"
echo "It is based on example zone files provided in the CentOS 6.2 distro"
echo "You can edit this file to easily change the template to your liking."
echo
echo "Christopher Hull - Spillikin Aerospace"
echo "www.spillikin.co"
echo "October 2013"

while true; do

	echo
	echo "==== Zone File Generator ===="
	echo "Parameters are currently set to..."
	echo "IP address for zone files: " $IP_ADDRESS
	echo "  You will be given a chance to change when zone file is created."
	echo "Full path where zone files are to be created: " $ZONE_PATH
	echo "File containing named.conf fragment for zone files: " $E_FILE
	echo "  This file is placed along with the zone files at $ZONE_PATH."
	echo "Nameserver 1: " $NS1
	echo "Nameserver 1 IP address: " $NS1_IP
	echo "Nameserver 2: " $NS2
	echo "Nameserver 2 IP address: " $NS2_IP
	echo 
	echo "Zone file generator main menu"
	echo "s Set parameters"
	echo "l See contents of $ZONE_PATH"
	echo "p Cat a file in $ZONE_PATH"
	echo "c Create zone and fragment files"
	echo "q Exit"

    read -p "Choose an option: " thing
    case $thing in
        [Ss]* ) set_params;;
        [Cc]* ) create_files;;
        [Ll]* ) ls -la $ZONE_PATH;;
        [Pp]* ) show_file;;
        [Qq]* ) quit;;
        * ) echo "Please select an option";;
    esac
done




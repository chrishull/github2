'''
Global vairables as defined in the Openstack Liberty install pages.

See http://docs.openstack.org/liberty/install-guide-rdo/environment-security.html
for complete lists of DB passwords.

Created on Feb 27, 2016

@author: chris
'''

'''
Thruout the installation you will see variables mentioned such as GLANCE_DBPASS.
Change those values here.  The values will be replaces as .conf files are updated.

Add any additional name value pairs here, but be careful.  Make sure the key is
likely to be unique.  use BIG_TEXT_LIKE_THIS as values are unlikely to look like that.
Then place those replacement values wherever you like in the processing fiels.

An example I've added is NOVA_INSTANCE_STORE, as you may want to chage this.
This is only useful if the same value appears in several places.
'''


OPENSTACK_VARIABLES = {
                       
            # The admin token is generated like this
            # openssl rand -hex 10

            "ADMIN_TOKEN":"91121d2c109d7fc778e4",

            # Replace ADMIN_PASS with the password you chose for the admin user in the Identity service.
            "ADMIN_PASS":"mk4968small23buggidntpass",
            # Same for demo
            "DEMO_PASS":"mk4968small23buggidntpass",
            # (hmmm, just how many Openstack tools have subtle references to Land of the Lost?)
            
            # Password of user guest of RabbitMQ (not identity, but Rabbit itself)
            "RABBIT_PASS":"open.g00dke232",
              
            # Replace GLANCE_DBPASS with the password you chose for the Image service database.
            "GLANCE_DBPASS":"sleestack191",
            # Replace GLANCE_PASS with the password you chose for the glance user in the Identity service.
            "GLANCE_PASS":"mk4968small23buggidntpass",
              
            # Replace NEUTRON_DBPASS with the password you chose for the service database.
            "NEUTRON_DBPASS":"sleestack191",
            # Replace NEUTRON_PASS with the password you chose for the neutron user in the Identity service.
            "NEUTRON_PASS":"mk4968small23buggidntpass",
              
            # Replace CINDER_DBPASS with the password you chose... well if you havn't figured it out by now...
            "CINDER_DBPASS":"sleestack191",
            # Replace CINDER_PASS with the password....
            "CINDER_PASS":"mk4968small23buggidntpass",
            
            "HEAT_DBPASS":"sleestack191",
            # Identity service password
            "HEAT_PASS":"mk4968small23buggidntpass",
            # Password of Orchestration domain
            "HEAT_DOMAIN_PASS":"mk4968small23buggidntpass",
            
            "CEILOMETER_DBPASS":"sleestack191",
            # Identity service user password
            "CEILOMETER_PASS":"mk4968small23buggidntpass",
            
            "NOVA_DBPASS":"sleestack191",
            # Identity service user password
            "NOVA_PASS":"mk4968small23buggidntpass",
            
            "KEYSTONE_DBPASS":"sleestack191",
            
            # Identity service user password
            "SWIFT_PASS":"mk4968small23buggidntpass",
            
            # You may want to specify a different location to store images, depending on 
            # partition space.  A default CentOS install leaves little room in /var  But /home works.
            # If you change this, be sure to 1: Disable SELinux and 2: Create the directory
            "GLANCE_IMAGE_STORE":"/var/lib/glance/images/",
            # See above, instances are big too.
            "NOVA_INSTANCE_STORE":"/var/lib/nova/instances/",
            
            # This as seen in "my_ip" in nova.conf
            "CONTROLLER_IP":"172.22.10.99",
            
            # For use with neutron networking
            "METADATA_SECRET":"sekritsqsnuts",
            
            # Replace MANAGEMENT_INTERFACE_IP_ADDRESS with the IP address 
            # of the management network interface on your compute node, 
            # typically 10.0.0.31 for the first node in the example architecture.
            "MANAGEMENT_INTERFACE_IP_ADDRESS":"172.22.10.99",
            
            # Linux Bridge settings.   linuxbridge_agent.ini
            "OVERLAY_INTERFACE_IP_ADDRESS":"172.22.10.99",
            "PUBLIC_INTERFACE_NAME":"enp3s0",
            
            # Not sure how to deal with 
            # /etc/neutron/metadata_agent.ini
            # But here is an interesting case.  We will gry this
            # We will replace these which exist in the file already.
            # [DEFAULT]
            # admin_tenant_name = %SERVICE_TENANT_NAME%
            # admin_user = %SERVICE_USER%
            # admin_password = %SERVICE_PASSWORD%
            "SERVICE_TENANT_NAME":"admin",
            "SERVICE_USER":"admin",
            # Same as "mk4968small23buggidntpass"
            "SERVICE_PASSWORD":"mk4968small23buggidntpass"
            
            
            
              
            }
'''
The set of directories immediately under Root Path which are searched for .conf files.
SubDirectories are no problem, they are searched as well.  Do not keep backups here.
'''
OPENSTACK_CONF_DIRS = ["/nova", "/glance", "/neutron","/keystone", "/cinder", "/swift"
                       , "/ceilometer", "/heat"]

'''
Given a string, locate any references to Openstack Vars and replace if found
@param Input string
@return String with var refs replaced.
'''
def ResolveVars (text):
    for key in OPENSTACK_VARIABLES:
        text = text.replace(key, OPENSTACK_VARIABLES[key])
    return text





        
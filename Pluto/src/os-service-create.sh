# This appears as part of the initial keystone setup.
# http://docs.openstack.org/liberty/install-guide-rdo/keystone-services.html
#
# Source this file before calling
# openstack service create --name keystone --description "OpenStack Identity" identity

# Use the number generated earlier.
# OS_TOKEN=ADMIN_TOKEN
export OS_TOKEN=91121d2c109d7fc778e4

export OS_URL=http://controller:35357/v3

export OS_IDENTITY_API_VERSION=3


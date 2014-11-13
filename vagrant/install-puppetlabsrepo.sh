#!/bin/bash

rhelversion=$(cat /etc/redhat-release | grep release\ 7)

# For CentOS7/RHEL7 the rdo release contains puppetlabs repo, creating conflict
if [ -n "$rhelversion" ]; then
    /bin/rpm -ivh https://repos.fedorapeople.org/repos/openstack/openstack-icehouse/epel-7/rdo-release-icehouse-4.noarch.rpm
    /usr/bin/yum install -y --enablerepo=puppetlabs-products --enablerepo=puppetlabs-deps puppet facter
else
    /bin/rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
    /usr/bin/yum install -y puppet facter
fi

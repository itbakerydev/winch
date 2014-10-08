#!/bin/bash
hammer proxy create --name "manager" \
  --url "https://manager.winch.local:8443"
hammer proxy info --name "manager"

# Create a domain named vagrant.local and associate it with DNS on proxy id 1
hammer domain create --name "winch.local" --dns-id 1
hammer domain info --name "winch.local"

hammer subnet create --name "vagrant" \
  --network "172.16.33.0" \
  --mask "255.255.255.0" \
  --gateway "172.16.33.11" \
  --dns-primary "172.16.33.11"
hammer subnet update --name "vagrant" \
  --domain-ids 1 --dhcp-id 1 --tftp-id 1 --dns-id 1
hammer subnet info --name "vagrant"

hammer environment create --name "production"
hammer environment info --name "production"

hammer template create --name "Kickstart_openstack" --type provision --file /vagrant/vagrant/provision/provision_openstack.erb

hammer os create --name CentOS --major 6 --minor 5 --description "CentOS 6.5" --family Redhat --architecture-ids 1 --medium-ids 1 --ptable-ids 6
# Get ID of the created OS
os_id=$(hammer os list | grep "CentOS 6.5" | cut -d" " -f1)

hammer template update --name "Kickstart default PXELinux" --operatingsystem-ids $os_id
hammer template update --name "Kickstart_openstack" --operatingsystem-ids $os_id

# Get the provision template id
templateid=$(hammer template list --per-page 10000 | grep "Kickstart_openstack"|cut -d" " -f1)
hammer os set-default-template --id $os_id --config-template-id $templateid
# Get the PXElinux template id
pxelinuxid=$(hammer template list --per-page 10000 | grep "Kickstart default PXELinux" | cut -d" " -f1)
hammer os set-default-template --id $os_id --config-template-id $pxelinuxid
# Get the partition table id
parttableid=$(hammer partition-table list --per-page 10000 | grep "Kickstart default" | cut -d" " -f1)
hammer os update --id $os_id --ptable-ids $parttableid

# work around Puppet bug #2244 which is fixed in 3.x
sudo mkdir -p /etc/puppet/environments/common/dummy/lib

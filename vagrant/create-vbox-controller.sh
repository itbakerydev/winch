#!/bin/bash

# This script will create a VirtualBox compute node and register it in foreman.

if [ -z "$(vagrant status manager 2>&1 | grep manager | grep running)" ]; then
    echo "You must have a running manager vagrant instance and changedir to the winch directory"
else
    TPATH=`VBoxManage list systemproperties | grep -i "default machine folder:" \
        | cut -b 24- | awk '{gsub(/^ +| +$/,"")}1'`
    VMNAME="controller"
    VMPATH="$TPATH/$VMNAME"

    ## Controller
    VBoxManage createvm --name "$VMNAME" --register --ostype RedHat_64
    VBoxManage modifyvm "$VMNAME" --memory 2048 --acpi on --cpus 2 --cpuexecutioncap 100 --boot1 disk --boot2 dvd

    VBoxManage modifyvm "$VMNAME" --nic1 hostonly --hostonlyadapter1 vboxnet0 --cableconnected1 on
    VBoxManage modifyvm "$VMNAME" --macaddress1 auto --nictype2 82540EM --nicpromisc1 allow-all

    VBoxManage modifyvm "$VMNAME" --nic2 hostonly --hostonlyadapter2 vboxnet1 --cableconnected2 on
    VBoxManage modifyvm "$VMNAME" --macaddress2 auto --nictype1 82540EM

    VBoxManage modifyvm "$VMNAME" --nic3 hostonly --hostonlyadapter3 vboxnet2 --cableconnected3 on
    VBoxManage modifyvm "$VMNAME" --macaddress3 auto --nictype2 82540EM

    VBoxManage modifyvm "$VMNAME" --nic4 hostonly --hostonlyadapter4 vboxnet3 --cableconnected4 on
    VBoxManage modifyvm "$VMNAME" --macaddress4 auto --nictype2 82540EM --nicpromisc4 allow-all

    VBoxManage createhd --filename "$VMPATH/$VMNAME.vdi" --size 40960
    VBoxManage storagectl "$VMNAME" --name "SATA Controller" \
        --add sata --controller IntelAHCI --hostiocache on --bootable on
    VBoxManage storageattach "$VMNAME" --storagectl "SATA Controller" \
        --type hdd --port 0 --device 0 --medium "$VMPATH/$VMNAME.vdi"

    VBoxManage showvminfo controller | grep "MAC" | cut -d"," -f1

    # Define host in foreman
    # Find the MAC address for the primary interface
    macaddress=$(vboxmanage showvminfo controller --machinereadable | grep macaddress1 | cut -d"\"" -f 2)
    hammercommand="sudo hammer host create --architecture x86_64 --domain winch.local --environment production --hostgroup controller_vbox --mac $macaddress --medium CentOS\ mirror --name controller --ptable Kickstart\ default --provision-method build --puppet-ca-proxy-id 1 --puppet-proxy-id 1 --subnet management --ip 172.16.33.12 --root-password 'Test123!'"

    echo "Registering host in foreman"
    vagrant ssh manager -c "$hammercommand"
fi

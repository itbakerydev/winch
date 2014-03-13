#!/bin/bash
# This is the script for bringing up the standard openstack nodes without
# Swift. This is probably the up script you want to run.
vagrant up --provider vmware_fusion puppet control storage network compute
cp ../hiera.yaml ../common.yaml .

#!/bin/bash

pool_name=vm-ssds
volume_name=jumpbox.qcow2
capacity=10Gib
allocation=1Gib
backing_volume=/scratch/alpine-vm-save.qcow2

virsh vol-create-as \
          --pool $pool_name \
          --name $volume_name \
          --capacity $capacity \
          --allocation $allocation \
          --format "qcow2" 
          #--print-xml 
if [ $? -ne 0 ]; then
  echo Failed the vol-create-as!
  exit 1
fi
#--prealloc-metadata

exit 0

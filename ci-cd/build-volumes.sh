#!/bin/bash

pool_name=vm-images
volume_name=core
capacity=10Gib
allocation=1Gib
virsh vol-create-as \
          --pool $pool_name \
          --name $volume_name \
          --capacity $capacity \
          --allocation $allocation \
          --format "qcow2" \
          --print-xml 
if [ $? -ne 0 ]; then
  echo Failed the vol-create-as!
  exit 1
fi
#--backing-vol a-backing-vol
#--backing-vol-format "qcow2"
#--prealloc-metadata

exit 0

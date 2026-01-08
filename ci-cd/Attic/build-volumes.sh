#!/bin/bash

set +x

pool_name=vm-templates
volume_name=alpine-vm.qcow2
capacity=4Gib
allocation=4Gib
#backing_volume=/scratch/alpine-vm-save.qcow2
backing_volume=${HOME}/Scratch/alpine-template.qcow2

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

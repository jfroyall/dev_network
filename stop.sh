#!/bin/bash

. ./utils.sh

function usage {
  print_error  usage: $0 '{mac|papa}'
}


if [ $# -ne 1 ];then
  usage;
  exit 1;
fi



#clean up


print_warning "Check that the domain actually exits!"
virsh shutdown jenkins-agent-1
virsh undefine jenkins-agent-1

terraform state rm 'libvirt_domain.jenkins_agent[0]'
terraform plan -destroy -out t.plan -var "dev_host=$1"
terraform apply t.plan

exit 0


#!/bin/bash

. ./utils.sh

function usage {
  print_error  usage: $0 '{mac|papa}'
}


if [ $# -ne 1 ];then
  usage;
  exit 1;
fi

cat /dev/null > terraform.tfvars

printf "platform_dns_name = \"%s\"\n" `yq '.common.platform_dns_name' deployment_cfg.yaml` >> terraform.tfvars
printf "platform_ip = \"%s\"\n" `yq '.common.platform_ip' deployment_cfg.yaml` >> terraform.tfvars



#start
terraform plan -out t.plan -var "dev_host=$1"
terraform apply t.plan

#early_exit

print_info "Successful run!"
exit 0

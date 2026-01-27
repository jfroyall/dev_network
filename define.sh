#!/bin/bash

. ./utils.sh

function usage {
  cat <<EOF
  more info here
EOF
  print_info  usage: $0 '{mac|papa}'
}


while getopts "h" c
do
	case "$c"
	in
		h) usage; exit 0 ;;
		#h) inBaseName=$OPTARG ;;
		\?) echo $USAGE; exit 2;;
	esac
done
shift `expr $OPTIND - 1`

if [ $# -ne 1 ];then
  print_error "Insufficient number of arguments"
  usage;
  exit 1;
fi

print_info "host: $1"


cat /dev/null > terraform.tfvars

printf "platform_dns_name = \"%s\"\n" `yq '.common.platform_dns_name' deployment_cfg.yaml` >> terraform.tfvars
printf "platform_ip = \"%s\"\n" `yq '.common.platform_ip' deployment_cfg.yaml` >> terraform.tfvars
printf "pool_storage = \"%s\"\n" `yq '.common.pool_storage' deployment_cfg.yaml` >> terraform.tfvars



#start
terraform plan -out t.plan -var-file=vms.tfvars -var "dev_host=$1"
if [ $? -ne 0 ]; then
  print_error "Failed to create the plan"
  exit 1
fi
#terraform apply t.plan

#early_exit

print_info "Successful run!"
exit 0

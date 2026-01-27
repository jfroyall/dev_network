#!/bin/bash

. ./utils.sh

function create_backup_pool {
  local pool_name=`yq '.backup_pool.name' deployment_cfg.yaml`
  local pool_path=`yq '.backup_pool.path' deployment_cfg.yaml`
  local pool_size=`yq '.backup_pool.size' deployment_cfg.yaml`

  print_info "pool info: $pool_name $pool_path $pool_size "
  if virsh pool-info $pool_name >/dev/null 2>&1; then
    print_info "The pool named $pool_name already exists."
    return 0
  fi

  # define and start the pool
  virsh pool-create-as \
                --name $pool_name\
                --type dir\
                --source-path $pool_path\
                --target $pool_path
                #--print-xml
  if [ $? -ne 0 ]; then
    print_error "Failed the pool-create-as call for $pool_name."
    return 1
  fi

  return 0
}



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

print_info "Defining the deployment."
print_info "host: $1"

# transfer variables from the yaml to the tfvars 
cat /dev/null > terraform.tfvars

printf "platform_dns_name = \"%s\"\n" `yq '.common.platform_dns_name' deployment_cfg.yaml` >> terraform.tfvars
printf "platform_ip = \"%s\"\n" `yq '.common.platform_ip' deployment_cfg.yaml` >> terraform.tfvars
printf "pool_storage = \"%s\"\n" `yq '.common.pool_storage' deployment_cfg.yaml` >> terraform.tfvars

#create the backup pool
if !  create_backup_pool ; then
  print_error "Failed to create the backup pool.  Aborting!"
  exit 1
fi

#start
terraform plan -out t.plan -var-file=vms.tfvars -var "dev_host=$1"
if [ $? -ne 0 ]; then
  print_error "Failed to create the plan"
  exit 1
fi
terraform apply t.plan


print_info "Successful run!"
exit 0

#!/bin/bash

. ./utils.sh



tempdir=$(mktemp -d)
function cleanup {
  rm -rf "$tempdir"
}

trap cleanup EXIT
trap cleanup SIGINT



function domain_exists {
  print_info "Working on domain: $d"
  virsh dominfo $d > /dev/null
  if [ $? -ne 0 ]; then
    print_warning "The domain named $d was not found.  Skipping the save."
    return 1
  fi

  return 0
}


function backup_domain {
  local domain_name
  domain_name=$1
  print_info "Working on $domain_name"

  return 0;
}
function check_backup_pool {


  local temp_file=${tempdir}/t.out
  local name_of_backup_pool
  name_of_backup_pool=`yq '.backup_pool.name' deployment_cfg.yaml`

  print_info "Checking that a backup pool named '$name_of_backup_pool' exists!"
  #virsh pool-list

  # get the pool info
  virsh pool-info $name_of_backup_pool > ${temp_file}
  if [ $? -ne 0 ];
  then
    print_error "Failed the 'pool-info' call."
    return 1
  fi

  cp $temp_file temp.fil

  #print_info here
  # extract the 'Name'
  local name;
  name=`grep Name $temp_file | awk '{print $2;}'`
  # extract the 'State'
  local state;
  state=`grep State $temp_file | awk '{print $2;}'`

  echo "Name and State: $name and $state"

  if [ x$name != x$name_of_backup_pool ];
  then
    print_error "Inconsistent pool name for $name_of_backup_pool"
    return 1
  fi

  if [ x$state != xrunning ];
  then
    print_error "Expected that the state of the pool $name_of_backup_pool would be 'running'"
    return 1
  fi


  return 0
}

function usage {

  cat <<EOF
  -h for this message
  -n not saving
EOF
  print_error  usage: $0 [-h] [-n] '{mac|papa}'
}

save_vms=yes;

while getopts "hn" c
do
	case "$c"
	in
		h) usage; exit 0 ;;
		n) save_vms=no ;;
		#h) inBaseName=$OPTARG ;;
		\?) echo $USAGE; exit 2;;
	esac
done

shift `expr $OPTIND - 1`

echo "nof args: $#"

if [ $# -ne 1 ];then
  print_error "Insufficient number of arguments"
  usage;
  exit 1;
fi

if ! check_backup_pool ;
then
  print_error "Failed the backup_pool check."
  exit 1
fi


if [ $save_vms != "yes" ]  ;
then
  print_warning "Not backing up!."

  print_warning "Prompt the user again."
fi



for d in `yq '.precious_domains.[]' deployment_cfg.yaml`;
do
  print_info "Working on domain: $d"
#  virsh dominfo $d > /dev/null
#  if [ $? -ne 0 ]; then
#    print_warning "The domain named $d was not found.  Skipping the save."
#    continue
#  fi
  if ! domain_exists $d; then continue; fi;
  print_info "Backing up domain: $d"
  backup_domain $d
done

# check that the state is not empty
# check that the state is not empty
# check that the state is not empty
# check that the state is not empty
for d in `terraform show -json | jq '.values.root_module.resources.[]|select(.type=="libvirt_domain").values.name'`;
do
  print_info "Working on domain $d"


  if ! domain_exists $d; then continue; fi;

  virsh shutdown $d
  virsh undefine $d

  terraform state rm `terraform show -json | jq '.values.root_module.resources.[]|select(.type=="libvirt_domain").address'`;

  if [ $? -ne 0 ]; then
    print_error "Failed to remove $d from the state.  Aborting"
    exit 1
  fi

done

print_warning "Removing the backup pool from the state"
print_warning "Fix this patch"

# check that the state is not empty and the target address validity
# check that the state is not empty and the target address validity
# check that the state is not empty and the target address validity
# Better Better remove it from the state as soon as it is created
terraform state rm 'libvirt_pool.basic["office-backup"]'

terraform plan -destroy -out t.plan -var "dev_host=$1"
terraform apply t.plan


#print_warning "Check that the domain actually exits!"
#virsh shutdown jenkins-agent-1
#virsh undefine jenkins-agent-1

#terraform state rm 'libvirt_domain.jenkins_agent[0]'
#terraform plan -destroy -out t.plan -var "dev_host=$1"
#terraform apply t.plan

exit 0


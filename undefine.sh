#!/bin/bash

. ./utils.sh



##### ##### ##### ##### ##### ##### ##### ##### 
#setup traps to clean up temporary files
tempdir=$(mktemp -d)
function cleanup {
  rm -rf "$tempdir"
}
trap cleanup EXIT
trap cleanup SIGINT



##### ##### ##### ##### ##### ##### ##### ##### 
# function checks that a given domain exits
function domain_exists {
  print_info "Working on domain: $d"
  if ! virsh dominfo $d ; then
    print_warning "The domain named $d was not found."
    return 1
  fi

  return 0
}


##### ##### ##### ##### ##### ##### ##### ##### 
# function which backs up a given domain
function backup_domain {
  local domain_name=$1
  print_info "Working on $domain_name"

  return 0;
}

##### ##### ##### ##### ##### ##### ##### ##### 
# function which checks that the backup pool is ready
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

##### ##### ##### ##### ##### ##### ##### ##### 
# usage function
function usage {

  cat <<EOF
  -h for this message
  -n not saving
EOF
  print_error  usage: $0 [-h] [-n] '{mac|papa}'
}

##### ##### ##### ##### ##### ##### ##### ##### 
# default to save the VMs
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

##### ##### ##### ##### ##### ##### ##### ##### 
# Double check the option
if [ $save_vms != "yes" ]  ;
then
  print_warning "Not backing up!."

  print_warning "Prompt the user again."
  answer="neither"
  until [ $answer == "yes" -o $answer == "no" ]; do
    read -p "You have elected not to save the VMs!  Are you sure?  [yes|no](no): " answer
    if [ x$answer == "x" -o x$answer == "xno" ]; then
      answer="no" 
      save_vms="yes"
    fi
    print_info "The answer: $answer"
  done
fi


##### ##### ##### ##### ##### ##### ##### ##### 
# check that the backup pool is ready
if ! check_backup_pool ;
then
  print_error "Failed the backup_pool check."
  exit 1
fi




##### ##### ##### ##### ##### ##### ##### ##### 
# Save the precious domains
if [ $save_vms != "no" ]; then
  for d in `yq '.precious_domains.[]' deployment_cfg.yaml`; do
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
fi

##### ##### ##### ##### ##### ##### ##### ##### 
# Check state managed by Terraform
nof_lines=`terraform state list | wc -l`
if [ $nof_lines -eq 0 ];
then
  print_info "The state is empty, so exiting."
  exit 0
fi

##### ##### ##### ##### ##### ##### ##### ##### 
# Save every domain in the state
for d in `terraform show -json | jq -r '.values.root_module.resources.[]|select(.type=="libvirt_domain").values.name'`;
do
  print_info "Working on domain $d"

  if ! domain_exists $d; then continue; fi;

  virsh shutdown "$d"
  virsh undefine "$d"

  terraform state rm `terraform show -json | jq -r '.values.root_module.resources.[]|select(.type=="libvirt_domain").address'`;

  if [ $? -ne 0 ]; then
    print_error "Failed to remove $d from the state.  Aborting"
    exit 1
  fi

done


##### ##### ##### ##### ##### ##### ##### ##### 
# Set up a plan to destroy the deployment
terraform plan -destroy -out t.plan \
                -var-file=vms.tfvars \
                -var-file=images.tfvars \
                -var "dev_host=$1"

##### ##### ##### ##### ##### ##### ##### ##### 
# Destroy the deployment
terraform apply t.plan


#print_warning "Check that the domain actually exits!"
#virsh shutdown jenkins-agent-1
#virsh undefine jenkins-agent-1

#terraform state rm 'libvirt_domain.jenkins_agent[0]'
#terraform plan -destroy -out t.plan -var "dev_host=$1"
#terraform apply t.plan

print_info "Successfully destroyed the deployment."
exit 0


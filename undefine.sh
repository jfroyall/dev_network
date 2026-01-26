#!/bin/bash

. ./utils.sh



tempdir=$(mktemp -d)
function cleanup {
  rm -rf "$tempdir"
}

trap cleanup EXIT
trap cleanup SIGINT



function check_backup_pool {


  local temp_file=${tempdir}/t.out
  local name_of_backup_pool
  name_of_backup_pool=`yq '.backup_pool.name' deployment_cfg.yaml`
  print_info "Checking that a backup pool named '$name_of_backup_pool' exists!"
  virsh pool-list
  # get the pool info
  virsh pool-info $name_of_backup_pool > ${temp_file}
  if [ $? -ne 0 ];
  then
    print_error "Failed the 'pool-info' call."
    return 1
  fi
#print_info here
  # extract the 'Name'
  grep Name $temp_file
  # extract the 'State'
  grep State $temp_file

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

check_backup_pool
status=$?
echo "The status: $status"

if ! check_backup_pool ;
then
  print_error "Failed the backup_pool check."
  exit 1
fi
early_exit
if [ $save_vms != "yes" ]  ;
then
  print_warning "Not backing up!."

  print_warning "Prompt the user again."
fi



for d in `yq '.precious_domains.[]' deployment_cfg.yaml`;
do
  print_info "Backing up domain: $d"
done

early_exit

print_warning "Check that the domain actually exits!"
virsh shutdown jenkins-agent-1
virsh undefine jenkins-agent-1

terraform state rm 'libvirt_domain.jenkins_agent[0]'
terraform plan -destroy -out t.plan -var "dev_host=$1"
terraform apply t.plan

exit 0


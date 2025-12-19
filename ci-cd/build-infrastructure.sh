#!/usr/bin/bash

set -e
set +x


#Works on  pools
function stage_1_a {

  if [ $# -lt 3 ]; then
    echo "stage_1_a {plan|apply|destroy} {name_of_plan_file} {pool_target}"
    return 2
  fi

  TF_CMD=$1
  TF_PLAN=$2
  TF_TGT=$3
  TF_ARGS="-target=$TF_TGT"
  case $TF_CMD in
    plan)    echo planning...; 
             TF_ARGS="$TF_ARGS -out=$TF_PLAN"
             ;;
    apply)   echo applying $TF_PLAN to $TF_TGT...
             ;;
    destroy) echo destroying $TF_TGT...
             ;;
    *) echo ${FUNCNAME[0]}::Line ${BASH_LINENO[1]} Unknown option: $TF_CMD; return 2;
  esac
  terraform $TF_CMD $TF_ARGS 
  return 0;
}

#Works on volumes
function stage_1_b {

  if [ $# -lt 3 ]; then
    echo " ${FUNCNAME[0]} {plan|apply|destroy} {name_of_plan_file} {volume_target}"
    return 2
  fi

  TF_CMD=$1
  TF_PLAN=$2
  TF_TGT=$3
  TF_ARGS="-target=$TF_TGT"
  case $TF_CMD in
    plan)    echo planning...; 
             TF_ARGS="$TF_ARGS -out=$TF_PLAN"
             ;;
    apply)   echo applying $TF_PLAN to $TF_TGT...
             ;;
    destroy) echo destroying $TF_TGT...
             ;;
    *) echo ${FUNCNAME[0]}::Line ${BASH_LINENO[1]} Unknown option: $TF_CMD; return 2;
  esac
  terraform $TF_CMD $TF_ARGS 
  return 0;

}


#POOL=libvirt_pool.basic
#stage_1_a plan ${POOL}.tf_plan ${POOL}
#stage_1_a apply ${POOL}.tf_plan ${POOL}
#stage_1_a destroy ${POOL}.tf_plan ${POOL}

#for VOL in libvirt_volume.ISOs libvirt_volume.alpine_base ; do
#  stage_1_b plan ${VOL}.tf_plan ${VOL}
#  stage_1_b apply ${VOL}.tf_plan ${VOL}
#  #stage_1_b destroy ${VOL}.tf_plan ${VOL}
#done

for NET in libvirt_network.outer libvirt_network.inner; do
  terraform plan -out=${NET}.tf_plan -target=${NET}
  terraform apply ${NET}.tf_plan 
  #terraform destroy -target=${NET}
done



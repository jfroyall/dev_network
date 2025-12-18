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
  case $TF_CMD in
    plan)    echo planning...; 
             terraform plan -out=$TF_PLAN  -target=$TF_TGT 
             ;;
    apply)   echo applying $TF_PLAN to $TF_TGT...
             terraform apply -target=$TF_TGT 
             ;;
    destroy) echo destroying $TF_TGT...
             terraform destroy   -target=$TF_TGT 
             ;;
    *) echo ${FUNCNAME[0]}::Line ${BASH_LINENO[1]} Unknown option: $TF_CMD; return 2;
  esac
  return 0;
}

#Works on volumes
function stage_1_b {
  return 1;
}


POOL=libvirt_pool.basic
stage_1_a plan ${POOL}.tf_plan ${POOL}
stage_1_a apply ${POOL}.tf_plan ${POOL}
#stage_1_a destroy ${POOL}.tf_plan ${POOL}

stage_1_b

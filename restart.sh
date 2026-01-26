#!/bin/bash

. ./utils.sh

function usage {
  print_error  usage: $0 '{mac|papa}'
}


if [ $# -ne 1 ];then
  usage;
  exit 1;
fi

print_error "This script needs to be updated."
early_exit

./stop.sh $1

./define.sh $1

exit 0


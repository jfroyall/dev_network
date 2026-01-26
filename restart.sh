#!/bin/bash

. ./utils.sh

function usage {
  print_error  usage: $0 '{mac|papa}'
}


if [ $# -ne 1 ];then
  usage;
  exit 1;
fi


./stop.sh $1

./start.sh $1

exit 0


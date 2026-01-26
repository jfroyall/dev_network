#!/bin/bash

source colors.sh

FGcolor=$Black
FGcolor=$White

function error_exit() {
  print_error "Message--- $1"
  print_error "An error occurred in function ${FUNCNAME[1]} at line ${BASH_LINENO[0]} of file ${BASH_SOURCE[1]}"
  exit 1
}

function early_exit() {
  echo -e "${BRed}Early exit called from function ${FUNCNAME[1]} at line ${BASH_LINENO[0]} of file ${BASH_SOURCE[1]}${FGcolor}"
  exit 1
}

function print_error() {
  echo -e "${BRed}ERROR--${BASH_SOURCE[1]}-LINE: ${BASH_LINENO[0]} $* ${FGcolor}"
}

function print_warning() {
  echo -e "${BYellow}WARNING--${BASH_SOURCE[1]}-LINE: ${BASH_LINENO[0]} $* ${FGcolor}"
}

function print_info() {
  echo -e "${Green}INFO--${BASH_SOURCE[1]}-LINE: ${BASH_LINENO[0]} $* ${FGcolor}"
}

function print_step() {
  echo -e "${Cyan}INFO--${BASH_SOURCE[1]}-LINE: ${BASH_LINENO[0]} $* ${FGcolor}"
}


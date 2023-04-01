#!/bin/bash
set -e

## vars:
MAIN_REGION=$(grep main_region global.hcl 2>/dev/null|head -1| awk -F\" '{print $2}')
CUR_REGION=$(basename `find env -type d -name "*-[1-9]"|head -1`)

## functions:
function printLogs(){
  local SEVERITY=$1
  local LOGS_STR=$2
  local PRE_FIX="$(date):"

  case $SEVERITY in
    3) PRE_FIX="[ERROR] ${PRE_FIX}" ;;
    *) PRE_FIX="[INFO] ${PRE_FIX}" ;;
  esac

  echo $PRE_FIX $LOGS_STR
}

## Rename region dirs to $MAIN_REGION:
if [[ -n $MAIN_REGION ]] && [[ -n $CUR_REGION ]]; then
  if [[ $MAIN_REGION != $CUR_REGION ]]; then
    printLogs 6 "Rename the main region directory into $MAIN_REGION"
    for DIR in env common; do
      mv $DIR/$CUR_REGION $DIR/$MAIN_REGION 2>/dev/null
    done
  else
    printLogs 3 "No need to rename!"
  fi
else
  printLogs 3 "One of MAIN_REGION or CUR_REGION is empty!"
fi

exit 0

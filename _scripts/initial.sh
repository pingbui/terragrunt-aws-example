#!/bin/bash
set -e

## vars:
MAIN_REGION=${MAIN_REGION:-$(grep MAIN_REGION global.hcl 2> /dev/null | head -1 | awk -F\" '{print $4}')}
CUR_REGION=$(basename "$(find env -type d -name '*-[1-9]' | head -1)")

## functions:
function printLogs() {
  local SEVERITY=$1
  local LOGS_STR=$2
  local PREFIX=${PREFIX:-"$(date):"}

  case $SEVERITY in
    3) PREFIX="[ERROR] ${PREFIX}" ;;
    *) PREFIX="[INFO] ${PREFIX}" ;;
  esac

  echo "$PREFIX $LOGS_STR"
}

## Rename region dirs to $MAIN_REGION:
if [[ -n $MAIN_REGION ]] && [[ -n $CUR_REGION ]]; then
  if [[ $MAIN_REGION != "$CUR_REGION" ]]; then
    printLogs 6 "Rename the main region directory into $MAIN_REGION"
    for DIR in env common; do
      mv $DIR/"$CUR_REGION" $DIR/"$MAIN_REGION" 2> /dev/null
    done
  else
    printLogs 3 "No need to rename!"
  fi
else
  printLogs 3 "One of MAIN_REGION or CUR_REGION is empty!"
fi

exit 0

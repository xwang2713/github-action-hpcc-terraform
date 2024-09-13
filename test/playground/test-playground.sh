#!/bin/bash

usage()
{
  echo "Usage: test-playground.sh [options]"
  echo "    -h     Display help"
  echo "    -d     HPCC-Platform source directory path"
  echo "    -s     EclWatch ip or FQDN"
  echo "    -t     targets. Such as 'hthor roxie thor'"
  exit
}

HPCC_HOME=$1
SERVER=
OUT_DIR=log
TARGETS="hthor roxie thor"
while getopts “hd:s:t:” opt
do
  case $opt in
    d) HPCC_HOME=$OPTARG ;;
    o) OUT_DIR=$OPTARG ;;
    s) SERVER=$OPTARG ;;
    t) TARGETS=$OPTARG ;;
    h) usage   ;;
  esac
done
shift $(( $OPTIND-1 ))

[ -z "$SERVER" ] || [ -z "$HPCC_HOME" ] && usage

ECL_DIR=${HPCC_HOME}/esp/src/eclwatch/ecl


mkdir -p $OUT_DIR

total_count=0
total_succeeded=0
total_failed=0
result="OK"
echo "Playground ECL sample Tests"
echo "---------------------------------------------------------"
for target in $TARGETS
do
  count=0
  succeeded=0
  failed=0
  log_dir=${OUT_DIR}/${target}
  mkdir -p $log_dir
  echo 
  echo "$target"
  echo "============"
  for file in $(ls ${ECL_DIR}) 
  do
    ext=$(echo $file | cut -d'.' -f2)
    [ "$ext" != "ecl" ] && continue
    test_name=$(echo $file | cut -d'.' -f1)
    count=$(expr $count + 1)
    total_count=$(expr $total_count + 1)
    printf "%4s %-40s" "$count" "$test_name"
    { time ecl run $target -s $SERVER ${ECL_DIR}/${file}  > ${log_dir}/${test_name}.log 2>&1 ; } 2> /tmp/test_playground_time.out
    if [ $? -eq 0 ]
    then
       succeeded=$(expr $succeeded \+ 1)
       total_succeeded=$(expr $total_succeeded \+ 1)
       result=OK
    else
       failed=$(expr $failed \+ 1)
       total_failed=$(expr $total_failed \+ 1)
       result=Failed
    fi
    exec_time=$(cat /tmp/test_playground_time.out | grep "^real" | awk '{print $2}')
    printf "%-10s  %15s\n" "[ $result ]" "[$exec_time]"
  done 
  echo "============"
  echo "Summary ($target):"
  printf "%-15s: %3s\n" "Total tests" "$count"
  printf "%-15s: %3s\n" "Succeeded" "$succeeded"
  printf "%-15s: %3s\n\n" "Failed" "$failed"

done
echo "---------------------------------------------------------"
echo "Summary:"
printf "%-15s: %3s\n" "Total tests" "$total_count"
printf "%-15s: %3s\n" "Succeeded" "$total_succeeded"
printf "%-15s: %3s\n\n" "Failed" "$total_failed"


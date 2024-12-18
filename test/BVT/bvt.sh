#! /bin/bash

SRC_DIR=/home/hpcc/HPCC-Platform
SERVER=localhost
LOG_DIR=/home/hpcc/tmp
CLOUD=azure


print_usage(){
  echo
  echo "UsageL bvt.sh <options>"
  echo "  -d|--src-dir HPCC Platform source path. The default is /home/hpcc/HPCC-Platform"
  echo "  -h|--help: print usage."
  echo "  -l|--log-dir: log directory. The default is /home/hpcc/tmp"
  echo "  -s|--server: eclwatch server ip or DNS"
  echo

}

TEMP=`/usr/bin/getopt -o c:d:l:s:h --long help,cloud:src-dir:,log-dir:,server: -n 'bvt' -- "$@"`
if [[ $? != 0 ]] ; then echo "Failure to parse commandline." >&2 ; end 1 ; fi
eval set -- "$TEMP"
while true ; do
    case "$1" in
    -c|--cloud) CLOUD=$2
      shift 2 ;;
    -d|--src-dir) SRC_DIR=$2
      shift 2 ;;
    -l|--log-dir) LOG_DIR=$2
      shift 2 ;;
    -s|--server) SERVER=$2
      shift 2 ;;
    -h|--help) print_usage
      shift ;;
    --) shift ; break ;;
    esac
done


# Build Verification Test 
REGRESS_SETUP_CONFIG="--config  ecl-test-azure.json"
[ "${CLOUD}" = "local" ] && REGRESS_SETUP_CONFIG=""
cd ${SRC_DIR}/testing/regress
#echo "./ecl-test setup --server ${SERVER} ${REGRESS_SETUP_CONFIG} 2>&1 | tee ${LOG_DIR}/regress.out"
./ecl-test setup --server ${SERVER} ${REGRESS_SETUP_CONFIG} 2>&1 | tee ${LOG_DIR}/regress.out

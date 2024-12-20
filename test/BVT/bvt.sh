#! /bin/bash

SRC_DIR=/home/hpcc/HPCC-Platform
SERVER=localhost
LOG_DIR=/home/hpcc/tmp
CLOUD=azure
HPCC_VERSION=

print_usage(){
  echo
  echo "UsageL bvt.sh <options>"
  echo "  -d|--src-dir HPCC Platform source path. The default is /home/hpcc/HPCC-Platform"
  echo "  -h|--help: print usage."
  echo "  -l|--log-dir: log directory. The default is /home/hpcc/tmp"
  echo "  -s|--server: eclwatch server ip or DNS"
  echo

}

get_value() {
  [ -z "$1" ] && echo "0" &&  return
  grep $2 $1 | cut -d':' -f 2 |  sed -e 's/^[[:space:]]*//'
}

parse_playground_log() {
  BVT_PLAYGROUND_RESULT_PATH=${LOG_DIR}/playground.out
  tmp_result=${LOG_DIR}/tmp_result
  sed -n '/^Summary:/,/Regression Test/{
    p
  }' ${BVT_PLAYGROUND_RESULT_PATH} > ${tmp_result}
  playground_total=$(get_value ${tmp_result} "Total tests")

  sed -n '/^Summary:/,/Regression Test/{
    p
  }' ${BVT_PLAYGROUND_RESULT_PATH} > ${tmp_result}
  playground_pass=$(get_value ${tmp_result} "Succeeded")

  PLAYGROUND_RESULT="${playground_pass}/${playground_total}"
}

parse_regress_setup_log() {

  regress_hthor_pass=$(get_value ${BVT_REGRESS_RESULT_PATH}/setup_hthor.*.log "Passing:")
  regress_hthor_fail=$(get_value ${BVT_REGRESS_RESULT_PATH}/setup_hthor.*.log "Failure:")
  regress_hthor_total=$(expr $regress_hthor_pass \+ $regress_hthor_fail)
  echo "regress setup hthor rate: ${regress_hthor_pass}/${regress_hthor_total}"

  regress_roxie_pass=$(get_value ${BVT_REGRESS_RESULT_PATH}/setup_roxie-workunit.*.log "Passing:")
  regress_roxie_fail=$(get_value ${BVT_REGRESS_RESULT_PATH}/setup_roxie-workunit.*.log "Failure:")
  regress_roxie_total=$(expr $regress_roxie_pass \+ $regress_roxie_fail)
  echo "regress setup roxie-workunit rate: ${regress_roxie_pass}/${regress_roxie_total}"

  regress_thor_pass=$(get_value ${BVT_REGRESS_RESULT_PATH}/setup_thor.*.log "Passing:")
  regress_thor_fail=$(get_value ${BVT_REGRESS_RESULT_PATH}/setup_thor.*.log "Failure:")
  regress_thor_total=$(expr $regress_thor_pass \+ $regress_thor_fail)
  echo "regress setup thor rate: ${regress_thor_pass}/${regress_thor_total}"

  regress_setup_pass=$(expr $regress_hthor_pass + $regress_roxie_pass + $regress_thor_pass)
  regress_setup_total=$(expr $regress_hthor_total + $regress_roxie_total + $regress_thor_total)
  export REGRESS_SETUP_RESULT="${regress_setup_pass}/${regress_setup_total}"

}

collect_test_results() {
  echo "Build Verification Test ${HPCC_VERSION} " > ${BVT_RESULT}
  echo "Summary:" >> ${BVT_RESULT}
  #echo "  1) All playground samples. Success Rate: ${PLAYGROUND_RESULT}"  >> ${BVT_RESULT}
  echo "  2) Regress Setup. Success Rate: ${REGRESS_RESULT}"  >> ${BVT_RESULT}
  echo ""  >> ${BVT_RESULT}
  cat ${LOG_DIR}/playground.out >> ${BVT_RESULT}
  echo ""  >> ${BVT_RESULT}
  echo ""  >> ${BVT_RESULT} 
  echo "Regression Test"  >> ${BVT_RESULT}
  echo "---------------------------------------------------------"  >> ${BVT_RESULT}
  cat ${LOG_DIR}/regress.out | grep -v "URL " >> ${BVT_RESULT}
}


get_hpcc_version() {
  if [ -z "$HPCC_VERSION" ]
  then
     cur_dir=$(pwd)
     cd ${SRC_DIR}
     HPCC_VERSION=$(git branch| head -1 | sed "s/.*(HEAD detached at \(.*\))/\1/")
     cd $cur_dir
  fi
}


TEMP=`/usr/bin/getopt -o c:d:l:s:v:h --long help,cloud:src-dir:,log-dir:,server:version: -n 'bvt' -- "$@"`
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
    -v|--version) HPCC_VERSION=$2
      shift 2 ;;
    -h|--help) print_usage
      shift ;;
    --) shift ; break ;;
    esac
done

BVT_PLAYGROUND_RESULT_PATH=${LOG_DIR}/playground.out
BVT_REGRESS_RESULT_PATH=/home/hpcc/HPCCSystems-regression/log
BVT_RESULT=${LOG_DIR}/bvt.result

get_hpcc_version
# Build Verification Test 

# Playground
cd /home/hpcc/test/playground
echo "./run2 $SERVER ${SRC_DIR} ${LOG_DIR}"
./run2 $SERVER ${SRC_DIR} ${LOG_DIR}
parse_playground_log

# Regress Setup
REGRESS_SETUP_CONFIG="--config  ecl-test-azure.json"
[ "${CLOUD}" = "local" ] && REGRESS_SETUP_CONFIG=""
TIMEOUT=60
cd ${SRC_DIR}/testing/regress
echo "./ecl-test setup --server ${SERVER} ${REGRESS_SETUP_CONFIG} --timeout $TIMEOUT 2>&1 | tee ${LOG_DIR}/regress.out"
./ecl-test setup --server ${SERVER} ${REGRESS_SETUP_CONFIG} --timeout $TIMEOUT 2>&1 | tee ${LOG_DIR}/regress.out i
parse_regress_setup_log

# Generate report
collect_test_results

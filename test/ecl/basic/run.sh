#!/bin/bash

WK_DIR=$(dirname "${BASH_SOURCE[0]}")
# Test ecl code through esp


/opt/HPCCSystems/bin/ecl run  -s $1 hthor ${WK_DIR}/simple.ecl > ${WK_DIR}/simple_result 2>&1
rc=$?
if [ $rc -ne 0 ]; then
  echo "Test ecl code through esp failed! Error code: $rc"
  exit 2
fi

# Validate result
cat ${WK_DIR}/simple_result | grep "<Row><personid>2</personid><firstname>Joe[[:space:]]*</firstname><lastname>Blow[[:space:]]*</lastname></Row>"  > /dev/null
if [ $rc -ne 0 ]; then
  echo "Test result validate failed!"
  exit 3
fi

echo "ECL test through esp succeeded!"

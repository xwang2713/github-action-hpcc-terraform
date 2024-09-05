#!/usr/bin/env bash
#
# Run a test build for all images.

source functions

usage()
{
  echo ""
  echo "Usage: docker-run.sh -l <linux ariant> -r <repo> -s <eclwatch ip> -t <tag>"
  echo "   -l linux variant, comma delimited. The default is ubuntu. The other choice is centos"
  echo "   -r Docker repository. The default is hpccsystems/platform. Repo for gitlab, for example ln + plugins:"
  echo "      gitlab.ins.risk.regn.net/docker-images/hpccsystems/ln-platform-wp"
  echo "   -s eclwatch ip. "
  echo "   -t Docker image tag. default is latest. "
  echo ""
  exit 1
}


function test()
{
  echo ""
  echo "Testing $repo:$tag"
  echo "docker run --rm -v \"$PWD/test:/test\" ${repo}:${tag} -- /test/run.sh $eclwatch_ip"
  docker run --rm -v "$PWD/test:/test" ${repo}:${tag} /test/run.sh -- $eclwatch_ip
  echo ""
}

package="platform"
variants="ubuntu"
tag=latest
repo="hpccsystems/platform-core"
eclwatch_ip=

while getopts "*l:r:t:s:" arg
do
  case "$arg" in
       l) IFS=',' read -ra variants <<< "${OPTARG}"
          ;;
       r) repo=${OPTARG}
          ;;
       s) eclwatch_ip=${OPTARG}
          ;;
       t) tag=${OPTARG}
          ;;
       ?) usage
          ;;
  esac
done

test

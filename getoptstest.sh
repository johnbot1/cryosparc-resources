#!/bin/bash

usage() { echo "Usage: $0 [-g <groupdir>] [-l <license id>] -p <master port>]" 1>&2; exit 1; }

install_cryosparc_master() {
  echo $licenseid
}

while getopts "g:l:p:" opt; do
    case "${opt}" in
        g)
            groupdir=${OPTARG}
            ;;
        l)
            licenseid=${OPTARG}
            ;;
        p)
            port=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z $groupdir || -z $licenseid || -z "$port" ]]; then
  echo 'One or more variables are undefined'        
  exit 1
else
    install_cryosparc_master
    exit
fi


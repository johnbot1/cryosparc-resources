#!/bin/bash

masterhostname=vislogin2.cm.cluster


usage() { echo "Usage: $0 [-g <groupdir>] [-l <license id>] -p <master port>]" 1>&2; exit 1; }

get_group_storage_quota() {
echo "Checking Group storage quota before proceeding"
/usr/lpp/mmfs/bin/mmlsquota -j $GROUPDIR  --block-size auto central
#sleep 120
}

install_cryosparc_master() {
echo "beginning install of master"

#sleep 120
# Check if running from vislogin2. (cryoSPARC hardcodes its master hostname)

#if [ "$HOSTNAME" = vislogin2 ]; then
if [ "$HOSTNAME" = $masterhostname ]; then
    printf '%s\n' "Running install on correct login host"
else
    printf '%s\n' "Please run install on $masterhostname only. aborting install"
    exit 1
fi

# Create required directories for install.
#
mkdir -p /central/groups/$GROUPDIR/$USER/software/cryosparc
mkdir -p /central/groups/$GROUPDIR/$USER/cryosparc_database
mkdir -p /central/groups/$GROUPDIR/$USER/cryosparc_projects
mkdir -p /central/scratchio/$USER

cd /central/groups/$GROUPDIR/$USER/software/cryosparc

# Backup previous installation

#mv cryosparc2_master.tar.gz cryosparc2_master.tar.gz.bak
#mv cryosparc2_master cryosparc2_master.bak 

# Download and install
echo " "
echo "License ID is $LICENSE_ID"
echo " "
pwd

curl -L https://get.cryosparc.com/download/master-latest/$LICENSE_ID > cryosparc_master.tar.gz
tar -xf cryosparc_master.tar.gz
cd cryosparc_master

./install.sh --yes --license $LICENSE_ID --hostname $masterhostname \
--dbpath /central/groups/$GROUPDIR/$USER/cryosparc_database --port $PORT
}


while getopts "g:l:p:" opt; do
    case "${opt}" in
        g)
            GROUPDIR=${OPTARG}
            ;;
        l)
            LICENSE_ID=${OPTARG}
            ;;
        p)
            PORT=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z $GROUPDIR || -z $LICENSE_ID || -z $PORT ]]; then
  echo 'One or more variables are undefined'        
  exit 1
else
    #get_group_storage_quota
    install_cryosparc_master
    exit
fi

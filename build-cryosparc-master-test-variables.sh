#!/bin/bash

masterhostname=vislogin1.cm.cluster


usage() { echo "Usage: $0 [-g <groupdir>] [-e <email>] [-l <license id>] -p <master port>]" 1>&2; exit 1; }

install_cryosparc_master() {

# Check if running from vislogin2. (cryoSPARC hardcodes its master hostname)

if [ "$HOSTNAME" = $masterhostname ]; then
    printf '%s\n' "Running install on correct login host"
else
    printf '%s\n' "Please run install on $masterhostname only. aborting install"
    exit 1
fi

# Create required directories for install.

# Download and install
echo " "
echo "License ID is $LICENSE_ID"
echo " "
pwd

# Create User

ldap_output=$(ldapsearch -LLL -ZZ -x -b "ou=imss,o=caltech,c=us" "(uid=jflilley)")
first_name=$(echo "$ldap_output" | grep "givenName:" | awk '{print $2}')
last_name=$(echo "$ldap_output" | grep "sn:" | awk '{print $2}')
echo "First Name: $first_name"
echo "Last Name: $last_name"
echo "Email: $EMAIL"
echo " "
generated_password=$(pwgen -A -n -y 12)

echo cryosparcm createuser --email $EMAIL --password $generated_password --username $USER --firstname $first_name --lastname $last_name
echo " "
cryosparcm createuser --email $EMAIL --password $generated_password --username $USER --firstname $first_name --lastname $last_name

while getopts "g:e:l:p:" opt; do
    case "${opt}" in
        g)
            GROUPDIR=${OPTARG}
            ;;
        e)
            EMAIL=${OPTARG}
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

if [[ -z $GROUPDIR || -e $EMAIL || -z $LICENSE_ID || -z $PORT ]]; then
  echo 'One or more variables are undefined'        
  exit 1
else
    install_cryosparc_master
    exit
fi

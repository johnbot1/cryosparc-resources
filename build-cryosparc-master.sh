#!/bin/bash

masterhostname=vislogin2.cm.cluster

#Get current installer directory for template copy before
#moving into cryo directory. This should eventually pull 
#straight from github if public
installer_directory=$PWD


usage() { echo "Usage: $0 [-g <groupdir>] [-e <email>] [-l <license id>] -p <master port>]" 1>&2; exit 1; }

#get_group_storage_quota() {
#echo "Checking Group storage quota before proceeding"
#/usr/lpp/mmfs/bin/mmlsquota -j $GROUPDIR  --block-size auto central
##sleep 120
#}

#generate_user_password() {
#pwgen -A -n -y 12
#}

#obtain_first_last_name() {
#ldap_output=$(ldapsearch -LLL -ZZ -x -b "ou=imss,o=caltech,c=us" "(uid=jflilley)")
#first_name=$(echo "$ldap_output" | grep "givenName:" | awk '{print $2}')
#last_name=$(echo "$ldap_output" | grep "sn:" | awk '{print $2}')
#echo "First Name: $first_name"
#echo "Last Name: $last_name"
#}

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

# Set Bash Path

echo "export PATH=/central/groups/$GROUPDIR/$USER/software/cryosparc/cryosparc_master/bin/:\$PATH" >> ~/.bashrc
echo "Adding /central/groups/$GROUPDIR/$USER/software/cryosparc/cryosparc_master/bin to PATH in bashrc"
echo " "

# Startup cryoSPARC for first time
cd /central/groups/$GROUPDIR/$USER/software/cryosparc
/central/groups/$GROUPDIR/$USER/software/cryosparc/cryosparc_master/bin/cryosparcm start

# Create User
#ldap_output=$(ldapsearch -LLL -ZZ -x -b "ou=imss,o=caltech,c=us" "(uid=jflilley)")
ldap_output=$(ldapsearch -LLL -ZZ -x -b "ou=imss,o=caltech,c=us" "(uid=$USER)")
first_name=$(echo "$ldap_output" | grep "givenName:" | awk '{print $2}')
last_name=$(echo "$ldap_output" | grep "sn:" | awk '{print $2}')
generated_password=$(pwgen -A -n -y 12)

echo "First Name: $first_name"
echo "Last Name: $last_name"
echo "User: $USER"
echo "Groupdir: $GROUPDIR"
echo "Email: $EMAIL"
echo "Password is $generated_password"
echo " "

echo cryosparcm createuser --email $EMAIL --password $generated_password --username $USER --firstname $first_name --lastname $last_name
echo " "
/central/groups/$GROUPDIR/$USER/software/cryosparc/cryosparc_master/bin/cryosparcm createuser --email $EMAIL --password $generated_password --username $USER --firstname $first_name --lastname $last_name

# Write out cred file
#
#
rm -rf ~/.cryosparc-creds
cat <<EOF > ~/.cryosparc-creds
Username: $EMAIL
Password: $generated_password
Login URL: https://$masterhostname:$PORT
Note: You need to login to the above URL
from the Interactive webbrowser app NOT
your local web browser
interactive.hpc.caltech.edu
EOF

chmod 600 ~/.cryosparc-creds
#


# Copy the default cluster templates and modify
# to each user
echo " "
echo "Copying cryosparc templates"
echo "Current working directory is $PWD"
echo " " 
echo "cp $installer_directory/cluster_info.json /central/groups/$GROUPDIR/$USER/software/cryosparc"
cp $installer_directory/cluster_info.json /central/groups/$GROUPDIR/$USER/software/cryosparc
echo "cp $installer_directory/cluster_script.sh /central/groups/$GROUPDIR/$USER/software/cryosparc"
cp $installer_directory/cluster_script.sh /central/groups/$GROUPDIR/$USER/software/cryosparc
echo " "
#
sed -i '/"worker_bin_path"/d' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json
sed -i '/"cache_path"/d' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json

sed -i '3i\ \ \ \ "worker_bin_path" : "/central/groups/'"$GROUPDIR"'/'"$USER"'/software/cryosparc/cryosparc_worker/bin/cryosparcw",' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json
sed -i '4i\ \ \ \ "cache_path" : "/central/scratchio/'"$USER"'",' /central/groups/$GROUPDIR/$USER/software/cryosparc/cluster_info.json
}


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

#if [[ -z $GROUPDIR || -z $LICENSE_ID || -z $PORT ]]; then
if [[ -z $GROUPDIR || -e $EMAIL || -z $LICENSE_ID || -z $PORT ]]; then
  echo 'One or more variables are undefined'        
  exit 1
else
    install_cryosparc_master
    exit
fi

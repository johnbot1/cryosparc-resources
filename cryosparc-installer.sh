#!/bin/bash
# 2021 - johnbot

USERPASSWORD=$(pwgen -B -c -N 1 -1 12)
CUDAPATH=/central/software/CUDA/9.1
INSTALLERDIR=/central/software/cryosparc-installer

usage() { echo "Usage: $0 [-n <host vislogin1.cm.cluster or vislogin2.cm.cluster>] [-g <group directory name>] [-e <email>] [-p <cryoSPARC unique port>] [-l <cryoSPARC unique license id>]" 1>&2; exit 1; }

while getopts n:g:e:p:l: flag
do
    case "${flag}" in
        n) HOST=${OPTARG};;
        g) GROUP=${OPTARG};;
        e) USEREMAIL=${OPTARG};;
        p) UNIQUE_PORT=${OPTARG};;
        l) LICENSE_ID=${OPTARG};;
    esac
done

if [ ! "$HOST" ] ||  [ ! "$GROUP" ] || [ ! "$USEREMAIL" ] || [ ! "$UNIQUE_PORT" ] || [ ! "$LICENSE_ID" ]
then
    usage
    exit 1
fi

# Parameters

echo " "
echo SHELL = $SHELL
echo LICENSE_ID=$LICENSE_ID
echo GROUP=$GROUP
echo UNIQUE_PORT=$UNIQUE_PORT
echo HOST=$HOST
echo USEREMAIL=$USEREMAIL
echo CUDAPATH=$CUDAPATH
echo " "

sleep 10

# Create required directories

mkdir -p /central/groups/$GROUP/$USER/software/cryosparc
mkdir -p /central/groups/$GROUP/$USER/cryosparc_database
mkdir -p /central/groups/$GROUP/$USER/cryosparc_projects
mkdir -p /central/scratchio/$USER

# Install Master and Worker

cd /central/groups/$GROUP/$USER/software/cryosparc
curl -L https://get.cryosparc.com/download/master-latest/$LICENSE_ID > cryosparc_master.tar.gz
curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID -o cryosparc_worker.tar.gz
tar xvzf cryosparc_master.tar.gz
tar xvzf cryosparc_worker.tar.gz
cd cryosparc_master

./install.sh --yes --license $LICENSE_ID --hostname $HOST --dbpath /central/groups/$GROUP/$USER/cryosparc_database --port $UNIQUE_PORT

cat << EOF >> /central/home/$USER/.bashrc
export PATH="/central/groups/$GROUP/$USER/software/cryosparc/cryosparc_master/bin/:\$PATH"
EOF

/central/groups/$GROUP/$USER/software/cryosparc/cryosparc_master/bin/cryosparcm start

# Setup user
/central/groups/$GROUP/$USER/software/cryosparc/cryosparc_master/bin/cryosparcm createuser --email $USEREMAIL --password $USERPASSWORD --username $USER --firstname "DEFAULT" --lastname "DEFAULT"

cat << EOF > /central/home/$USER/.cryosparc-creds
user: $USEREMAIL
pass: $USERPASSWORD
website: http://$HOST:$UNIQUE_PORT
EOF

chmod 600 /central/home/$USER/.crysparc-creds


# Generate GPU slurm job to build the worker

#srun -t 00:15:00 --gres gpu:1 -N 1 cd /central/groups/$GROUP/$USER/software/cryosparc/cryosparc_worker && /usr/bin/nvidia-smi && /central/groups/$GROUP/$USER/software/cryosparc/cryosparc_worker/install.sh --license LICENSE_ID --cudapath $CUDAPATH
srun -t 00:15:00 --gres gpu:1 -N 1 cd /central/groups/$GROUP/$USER/software/cryosparc/cryosparc_worker && /central/groups/$GROUP/$USER/software/cryosparc/cryosparc_worker/install.sh --license $LICENSE_ID --cudapath $CUDAPATH

#cat << EOF > ./build-cryosparc-worker
#
##!/bin/bash
##Submit this script with: sbatch thefilename
##SBATCH --time=00:15:00   # walltime
##SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
##SBATCH --nodes=1   # number of nodes
##SBATCH --gres=gpu:1
##SBATCH -J "cryosparc-worker-build-process"   # job name
##SBATCH --mail-user=johnbot@caltech.edu   # email address
##SBATCH --mail-type=BEGIN
##SBATCH --mail-type=END
##SBATCH --mail-type=FAIL
#sleep 60
#echo done
#EOF

# Generate the cluster configs

cat << EOF > /central/groups/$GROUP/$USER/software/cryosparc/cluster_info.json
{
    "name" : "centralhpc-cluster",
    "worker_bin_path" : "/central/groups/$GROUP/$USER/software/cryosparc/cryosparc_worker/bin/cryosparcw",
    "cache_path" : "/central/scratchio/$USER",
    "send_cmd_tpl" : "{{ command }}",
    "qsub_cmd_tpl" : "sbatch {{ script_path_abs }}",
    "qstat_cmd_tpl" : "squeue -j {{ cluster_job_id }}",
    "qdel_cmd_tpl" : "scancel {{ cluster_job_id }}",
    "qinfo_cmd_tpl" : "sinfo",
    "transfer_cmd_tpl" : "scp {{ src_path }} loginnode:{{ dest_path }}"
}
EOF

cp $INSTALLERDIR/cryosparc-installer-cluster-script.sh /central/groups/$GROUP/$USER/software/cryosparc/cluster_script.sh

# Connect to cluster
cd /central/groups/$GROUP/$USER/software/cryosparc
cryosparcm cluster connect



#!/bin/bash
# Pull this cryosparc-resources git into the users ~/ and use for both master and worker installs

echo "Be sure to cd into /central/groups/$GROUPDIR/$USER/software/cryosparc on vislogin2 and run cryosparm cluster connect before using"

# To run
# srun -t 00:30:00  --partition gpu --gres=gpu:1 -N 1 ./cryosparc-configs-v2.12/build-cryosparc-worker.sh
# srun --pty -t 00:30:00 --partition gpu --gres=gpu:1 -N 1 -n 2 /bin/bash -l

# Note: the license ID does not need to be set as slurm will 
# automatically carry it over from the login host that runs
# the job submission. (assuming it's already exported to the env)

#echo "Removing and rebuilding cryoSPARC worker. Be sure that the cryoSPARC license ID has been exported on the login node you submit this from."

usage() { echo "Usage: $0 [-g <groupdir>] [-l <license id>]" 1>&2; exit 1; }

install_cryosparc_worker() {
install_cryosparc_worker() {

# For some reason, changing dir within the srun command continued to end up back in the CWD of where srun was run. Even
# adding slurms native --chdir= did not work. Cd to dir before initiating srun as seen below.
#srun --export=ALL -t 00:30:00 --partition gpu --gres=gpu:1 -N 1 -n 2 cd /central/groups/$GROUPDIR/$USER/software/cryosparc && echo $PWD && curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID > cryosparc_worker.tar.gz && tar -xf cryosparc_worker.tar.gz; cd cryosparc_worker && ./install.sh --license $LICENSE_ID

cd /central/groups/$GROUPDIR/$USER/software/cryosparc && srun --export=ALL -t 00:30:00 --partition gpu --gres=gpu:1 -N 1 -n 1 echo $PWD && curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID > cryosparc_worker.tar.gz && tar -xf cryosparc_worker.tar.gz; cd cryosparc_worker && ./install.sh --license $LICENSE_ID
}

#cd /central/groups/$GROUPDIR/$USER/software/cryosparc
#curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID > cryosparc_worker.tar.gz
#tar -xf cryosparc_worker.tar.gz
#cd cryosparc_worker
#./install.sh --license $LICENSE_ID

while getopts "g:l:" opt; do
    case "${opt}" in
        g)
            GROUPDIR=${OPTARG}
            ;;
        l)
            LICENSE_ID=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z $GROUPDIR || -z $LICENSE_ID ]]; then
  echo 'One or more variables are undefined'        
  exit 1
else
    #get_group_storage_quota
    install_cryosparc_worker
    exit
fi

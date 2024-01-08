#!/bin/bash

# To run
# srun -t 00:30:00  --gres=gpu:1 -N 1 ./cryosparc-configs-v2.12/build-cryosparc-worker.sh
# srun --pty -t 00:30:00 --gres=gpu:1 -N 1 -n 2 /bin/bash -l

# Note: the license ID does not need to be set as slurm will 
# automatically carry it over from the login host that runs
# the job submission. (assuming it's already exported to the env)

echo "Removing and rebuilding cryoSPARC worker. Be sure that the cryoSPARC license ID has been exported on the login node you submit this from."

cd /central/groups/$GROUPDIR/$USER/software/cryosparc
#rm -rf cryosparc2_worker.tar.gz
#rm -rf cryosparc2_worker
#ls -la

curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID > cryosparc_worker.tar.gz
tar -xf cryosparc_worker.tar.gz
cd cryosparc_worker
./install.sh --license $LICENSE_ID

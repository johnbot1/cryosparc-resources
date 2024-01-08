#!/bin/bash

# To run
# srun -t 00:30:00  --gres=gpu:1 -N 1 ./cryosparc-configs-v2.12/build-cryosparc-worker.sh

# Note: the license ID does not need to be set as slurm will 
# automatically carry it over from the login host that runs
# the job submission. (assuming it's already exported to the env)

GROUPDIR=imss_admin
#LICENSE_ID=fc39ab20-0701-11ea-96d1-7b3f0ddb8284
CUDAPATH=/central/software/CUDA/9.1

echo "Removing and rebuilding cryoSPARC worker. Be sure that the cryoSPARC license ID has been exported on the login node you submit this from."

cd /central/groups/$GROUPDIR/$USER/software/cryosparc
rm -rf cryosparc2_worker.tar.gz
rm -rf cryosparc2_worker
#ls -la

curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID > cryosparc2_worker.tar.gz
tar -xf cryosparc2_worker.tar.gz
cd cryosparc2_worker
./install.sh --license $LICENSE_ID --cudapath $CUDAPATH

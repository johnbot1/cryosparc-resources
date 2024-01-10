#!/usr/bin/env bash
#### cryoSPARC cluster submission script template for SLURM
## Available variables:
## {{ run_cmd }}            - the complete command string to run the job
## {{ num_cpu }}            - the number of CPUs needed
## {{ num_gpu }}            - the number of GPUs needed. 
##                            Note: the code will use this many GPUs starting from dev id 0
##                                  the cluster scheduler or this script have the responsibility
##                                  of setting CUDA_VISIBLE_DEVICES so that the job code ends up
##                                  using the correct cluster-allocated GPUs.
## {{ ram_gb }}             - the amount of RAM needed in GB
## {{ job_dir_abs }}        - absolute path to the job directory
## {{ project_dir_abs }}    - absolute path to the project dir
## {{ job_log_path_abs }}   - absolute path to the log file for the job
## {{ worker_bin_path }}    - absolute path to the cryosparc worker command
## {{ run_args }}           - arguments to be passed to cryosparcw run
## {{ project_uid }}        - uid of the project
## {{ job_uid }}            - uid of the job
## {{ job_creator }}        - name of the user that created the job (may contain spaces)
## {{ cryosparc_username }} - cryosparc username of the user that created the job (usually an email)
## {{ job_type }}           - CryoSPARC job type
##
## What follows is a simple SLURM script:

#SBATCH --job-name cryosparc_{{ project_uid }}_{{ job_uid }}
#SBATCH -N 1
#SBATCH -n {{ num_cpu }}
## Not sure if the following are needed any longer. testing required. johnbot
## SBATCH --time=120:00:00
## SBATCH --exclusive
#SBATCH --gres=gpu:{{ num_gpu }}
## We don't use partitions
## SBATCH --partition=gpu
#SBATCH --mem={{ (ram_gb*1024)|int }}MB
#SBATCH --output={{ job_log_path_abs }}
#SBATCH --error={{ job_log_path_abs }}

{{ run_cmd }}

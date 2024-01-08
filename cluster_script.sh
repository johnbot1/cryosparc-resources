#!/usr/bin/env bash
#SBATCH --job-name cryosparc_{{ project_uid }}_{{ job_uid }}
#SBATCH -N 1
#SBATCH -n {{ num_cpu }}
#SBATCH --gres=gpu:{{ num_gpu }}
#SBATCH --mem={{ (ram_gb*1024)|int }}MB             
#SBATCH --time=120:00:00
#SBATCH --exclusive
#SBATCH --output={{ job_dir_abs }}output.txt
#SBATCH --error={{ job_dir_abs }}error.txt

available_devs=""
for devidx in $(seq 0 15);
do
if [[ -z $(nvidia-smi -i $devidx --query-compute-apps=pid --format=csv,noheader) ]] ; then
if [[ -z "$available_devs" ]] ; then
available_devs=$devidx
else
available_devs=$available_devs,$devidx
fi
fi
done
export CUDA_VISIBLE_DEVICES=$available_devs

{{ run_cmd }}

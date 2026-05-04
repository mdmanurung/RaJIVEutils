#!/bin/bash
#SBATCH --job-name=rajive_bench
#SBATCH --partition=all
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=48G
#SBATCH --time=4:00:00
#SBATCH --output=logs/slurm_bench_%j.log
#SBATCH --error=logs/slurm_bench_%j.log

cd /exports/para-lipg-hpc/mdmanurung/rajiveplus

source /exports/archive/hg-funcgenom-research/mdmanurung/conda/etc/profile.d/conda.sh
conda activate R4_51

/exports/archive/hg-funcgenom-research/mdmanurung/conda/envs/R4_51/bin/Rscript \
  -e "rmarkdown::render('vignettes/benchmarking.Rmd')"

echo "EXIT CODE: $?"

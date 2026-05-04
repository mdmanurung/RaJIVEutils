#!/bin/bash
#SBATCH --job-name=rajive_jackstraw
#SBATCH --partition=all
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=4:00:00
#SBATCH --output=logs/slurm_jackstraw_%j.log
#SBATCH --error=logs/slurm_jackstraw_%j.log

cd /exports/para-lipg-hpc/mdmanurung/rajiveplus

source /exports/archive/hg-funcgenom-research/mdmanurung/conda/etc/profile.d/conda.sh
conda activate R4_51

/exports/archive/hg-funcgenom-research/mdmanurung/conda/envs/R4_51/bin/Rscript \
  -e "rmarkdown::render('vignettes/jackstraw_scaling.Rmd')"

echo "EXIT CODE: $?"

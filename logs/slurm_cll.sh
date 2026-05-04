#!/bin/bash
#SBATCH --job-name=rajive_cll
#SBATCH --partition=all
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=6:00:00
#SBATCH --output=logs/slurm_cll_%j.log
#SBATCH --error=logs/slurm_cll_%j.log

cd /exports/para-lipg-hpc/mdmanurung/rajiveplus

source /exports/archive/hg-funcgenom-research/mdmanurung/conda/etc/profile.d/conda.sh
conda activate R4_51

/exports/archive/hg-funcgenom-research/mdmanurung/conda/envs/R4_51/bin/Rscript \
  -e "rmarkdown::render('vignettes/cll_application.Rmd')"

echo "EXIT CODE: $?"

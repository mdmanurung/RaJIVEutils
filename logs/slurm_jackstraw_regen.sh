#!/bin/bash
#SBATCH --job-name=rajive_jack2
#SBATCH --partition=all
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/slurm_jack2_%j.log
#SBATCH --error=logs/slurm_jack2_%j.log

set -euo pipefail
cd /exports/para-lipg-hpc/mdmanurung/rajiveplus

cleanup() {
  perl -0pi -e 's/run_heavy <- TRUE\s+# set to TRUE once to regenerate \.rds cache files/run_heavy <- FALSE  # set to TRUE once to regenerate .rds cache files/g' vignettes/jackstraw_scaling.Rmd || true
}
trap cleanup EXIT

perl -0pi -e 's/run_heavy <- FALSE\s+# set to TRUE once to regenerate \.rds cache files/run_heavy <- TRUE   # set to TRUE once to regenerate .rds cache files/g' vignettes/jackstraw_scaling.Rmd

/exports/archive/hg-funcgenom-research/mdmanurung/conda/envs/R4_51/bin/Rscript -e "rmarkdown::render('vignettes/jackstraw_scaling.Rmd')"

echo "EXIT CODE: $?"

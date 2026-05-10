#!/bin/bash
#SBATCH --job-name=rajive_calibration
#SBATCH --partition=all
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --output=logs/slurm_calibration_%j.log
#SBATCH --error=logs/slurm_calibration_%j.log

# Slow calibration gates for rajiveplus.
# Runs W-M4 (jackstraw null uniformity + power),
#      W-M5 (Wedin Haar-uniform sampler),
#      W-M8 (joint-rank Type-I rate).
#
# Each gate uses B=200 Monte Carlo reps and L'Ecuyer-CMRG seeding.
# Expected wall time: 2-4 h (single core, no parallelism inside tests).
#
# Submit from repo root:
#   sbatch logs/slurm_calibration.sh
#
# Results in: logs/slurm_calibration_<jobid>.log

cd /exports/para-lipg-hpc/mdmanurung/RaJIVEutils

if ! command -v conda >/dev/null 2>&1; then
  echo "conda command not found on compute node"
  exit 127
fi

export RAJIVE_RUN_SLOW=1

conda run -n R4_51 Rscript \
  -e "devtools::test(filter='calibration', reporter='progress')"

CAL_EXIT=$?
echo "EXIT CODE: $CAL_EXIT"
exit $CAL_EXIT

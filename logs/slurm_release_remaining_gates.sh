#!/bin/bash
#SBATCH --job-name=rajive_release_remaining
#SBATCH --partition=all
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=8:00:00
#SBATCH --output=logs/slurm_release_remaining_%j.log
#SBATCH --error=logs/slurm_release_remaining_%j.log

# Continue the release-gate sequence after a green Gate 1.
# Runs:
#   2. devtools::check(args = c('--no-manual'))
#   3. pkgdown::build_site(lazy = TRUE, preview = FALSE)
#   4. Source install & load from built tarball

cd /exports/para-lipg-hpc/mdmanurung/RaJIVEutils

if ! command -v conda >/dev/null 2>&1; then
  echo "conda command not found on compute node"
  exit 127
fi

echo "====== RELEASE REMAINING GATES START ======"
echo "Timestamp: $(date)"

echo ""
echo "GATE 2/4: devtools::check(args = c('--no-manual'))"
echo "==========================================="
conda run -n R4_51 R --no-save -q -e "devtools::check(args = c('--no-manual'))" 2>&1
CHECK_EXIT=$?
echo "Check exit code: $CHECK_EXIT"
if [ $CHECK_EXIT -ne 0 ]; then
  echo "Gate 2 failed; aborting remaining gates."
  exit $CHECK_EXIT
fi

echo ""
echo "GATE 3/4: pkgdown::build_site(lazy = TRUE, preview = FALSE)"
echo "==========================================="
conda run -n R4_51 R --no-save -q -e "pkgdown::build_site(lazy = TRUE, preview = FALSE)" 2>&1
PKG_EXIT=$?
echo "Pkgdown exit code: $PKG_EXIT"
if [ $PKG_EXIT -ne 0 ]; then
  echo "Gate 3 failed; aborting remaining gates."
  exit $PKG_EXIT
fi

echo ""
echo "GATE 4/4: Source install from tarball & load"
echo "==========================================="
conda run -n R4_51 R --no-save -q -e "
  unlink('release_gate_lib', recursive = TRUE, force = TRUE)
  dir.create('release_gate_lib', showWarnings = FALSE)
  src <- pkgbuild::build(path = '.', dest_path = '.', vignettes = FALSE, manual = FALSE)
  install.packages(src, repos = NULL, type = 'source', lib = 'release_gate_lib')
  library(rajiveplus, lib.loc = 'release_gate_lib')
  cat('Loaded rajiveplus version:', as.character(packageVersion('rajiveplus')), '\n')
  sessionInfo()
" 2>&1
INSTALL_EXIT=$?
echo "Install exit code: $INSTALL_EXIT"
if [ $INSTALL_EXIT -ne 0 ]; then
  echo "Gate 4 failed."
  exit $INSTALL_EXIT
fi

echo ""
echo "====== RELEASE REMAINING GATES SUMMARY ======"
echo "Gate 2 (check):          $CHECK_EXIT"
echo "Gate 3 (pkgdown):        $PKG_EXIT"
echo "Gate 4 (install/load):   $INSTALL_EXIT"
echo "Timestamp: $(date)"
echo "REMAINING GATES PASSED"
exit 0

# Result Interpretation Templates

Use this file after Phase 2 caches finish and before final packaging.
Each section is intentionally fill-in-friendly for rapid reporting.

## 1) Benchmarking Summary Template

Run metadata:
- Date:
- Git commit:
- Machine/partition:
- CPU cores used:
- Relevant package versions:

Data completeness:
- bench_results.rds: [present/missing]
- bench_results_bench.rds: [present/missing]
- peakram_single.rds: [present/missing]
- scaling_results.rds: [present/missing]
- parallel_results.rds: [present/missing]

Primary outcomes:
- Median elapsed time (rajiveplus):
- Median elapsed time (RaJIVE):
- Speedup ratio (RaJIVE / rajiveplus):
- Peak RAM (rajiveplus):
- Peak RAM (RaJIVE):

Interpretation statement:
- rajiveplus shows [faster/slower/similar] runtime by [X]x and [lower/higher/similar] RAM.

Acceptance checks:
- Speedup > 5x at p=500: [pass/fail]
- Timing trend vs n approximately linear: [pass/fail]
- Timing trend vs p approximately increasing with p: [pass/fail]

Action if failed:
- Recheck if joint_rank was fixed to 2 for both packages.
- Recheck RaJIVE installation/version and pre-registered doParallel setup.
- Re-run only failed artifacts.

## 2) Jackstraw Scaling Summary Template

Run metadata:
- Date:
- Git commit:
- Machine/partition:
- Parameters (n_null grid, n grid, p grid):

Data completeness:
- jackstraw_time_vs_n.rds: [present/missing]
- jackstraw_time_vs_p.rds: [present/missing]
- jackstraw_time_vs_nnull.rds: [present/missing]
- jackstraw_ram_vs_n.rds: [present/missing]
- jackstraw_ram_vs_p.rds: [present/missing]

Primary outcomes:
- Time trend vs n:
- Time trend vs p:
- Time trend vs n_null:
- Peak RAM trend vs n:
- Peak RAM trend vs p:

Interpretation statement:
- jackstraw runtime scales roughly [linearly/superlinearly/sublinearly] in n and [linearly/superlinearly/sublinearly] in p for tested ranges.

Acceptance checks:
- Trend vs n approximately linear: [pass/fail]
- Trend vs p approximately linear: [pass/fail]
- n_null monotonic runtime increase: [pass/fail]

Action if failed:
- Confirm each grid point used fixed Rajive decomposition before jackstraw.
- Confirm outlier runs are not node contention artifacts.
- Re-run only suspect points and replace rows in cached tables.

## 3) CLL Application Summary Template

Run metadata:
- Date:
- Git commit:
- Dataset package version:
- Number of complete-case samples:

Data completeness:
- cll_preprocessed.rds: [present/missing]
- cll_svd_list.rds: [present/missing]
- cll_rajive_results.rds: [present/missing]
- cll_jackstraw_results.rds: [present/missing]

Preprocessing checks:
- Matrix orientation verified (rows are samples): [yes/no]
- Block dimensions after filtering:
- initial_signal_ranks used:
- Reported joint_rank:

Biological findings:
- Factor 1 association with IGHV:
- Factor 1 association with trisomy12:
- Top significant variables by block:

Clinical findings:
- Random forest OOB accuracy for IGHV:
- Random forest OOB accuracy for trisomy12:
- Cox PH hazard ratio summary for Factor 1:
- KM separation comment:

Acceptance checks:
- Factor 1 correlates with IGHV status: [pass/fail]
- Cox PH Factor 1 significantly different from 1: [pass/fail]

Action if failed:
- Recheck sample alignment across blocks and metadata.
- Recheck scaling and feature filtering thresholds.
- Re-run Rajive then jackstraw with verified orientation and same seed.

## 4) Final Verification Gate Template

Build outputs:
- devtools::build_vignettes() success: [yes/no]
- pkgdown::build_site() success: [yes/no]

Required pages:
- docs/articles/benchmarking.html exists: [yes/no]
- docs/articles/jackstraw_scaling.html exists: [yes/no]
- docs/articles/cll_application.html exists: [yes/no]

Release recommendation:
- [ready/not ready]
- Blocking issues (if any):

# Refactoring and Maintainability Plan for `rajiveplus`

Date: 2026-05-18  
Repository: `/exports/para-lipg-hpc/mdmanurung/RaJIVEutils`

This is a discovery-only planning document. No source code, generated files, audit state, logs, benchmarks, vignettes, or package metadata were modified. No tests, checks, documentation regeneration, SLURM submissions, or heavy jobs were run during this pass.

Operational rules are inherited from [audits/AGENTS.md](audits/AGENTS.md), live state from [audits/PROGRESS.md](audits/PROGRESS.md), and phase/TDD gates from [audits/PLANS.md](audits/PLANS.md). Prior package maps and findings are treated as authoritative inputs, especially [audits/comprehensive-2026-05-13/01_package_map.md](audits/comprehensive-2026-05-13/01_package_map.md). This plan cites prior audit work instead of redoing it.

## Deliverable 1: Codebase Map and Maintainability Diagnosis

### Package Purpose and Runtime Flow

**Confirmed**

`rajiveplus` implements Robust Angle-based Joint and Individual Variation Explained for matched multi-view data. The primary entry point is `R/Rajive.R::Rajive()`, which returns complete-data `rajive` objects or native-missing `rajive_incomplete` objects. The public boundary is the generated `NAMESPACE`, currently 46 `export(...)` entries, including native-missing accessors such as `get_estimability`, `get_missing_diagnostics`, `get_reconstructed_blocks`, and `rajive_missing_control`. `NAMESPACE` is generated and must not be hand-edited.

Complete-data flow:

| Step | Evidence | Data Flow | Behavior Pinned By |
|---|---|---|---|
| Entry and argument routing | `R/Rajive.R::Rajive()` at `R/Rajive.R:241` | Validates `identifiability_norm`, `missing`, `uncertainty`, rejects native-only arguments when `missing = "none"` | `tests/testthat/test-rajive-validation.R`, `tests/testthat/test-missing-native-dispatch.R` |
| Core fit | `R/Rajive.R::.Rajive_core()` at `R/Rajive.R:333` | Validates complete matrices, initial ranks, finite entries, degenerate columns | `tests/testthat/test-rajive-boundaries.R`, `tests/testthat/test-warning-suppression.R` |
| Robust SVD | `R/Rajive.R:420`, `R/Rajive_helpfunctions.R::get_svd_robustH()` | Calls `RobRSVD.all()` for each block, with truncated or full rank depending on `rank_selection` | `tests/testthat/test-robustsvd-rcpp.R`, `tests/testthat/test-robustsvd-deflation.R` |
| Rank thresholds | `R/Rajive.R::get_sv_threshold()` and `R/Rajive_helpfunctions.R` rank-bound helpers | Computes Wedin, permutation, or random-direction thresholds | `tests/testthat/test-rajive-perm.R`, `tests/testthat/test-calibration-wedin.R`, `tests/testthat/test-rank-bound-rcpp.R` |
| Joint score selection | `R/Rajive.R::get_joint_scores_robustH()` at `R/Rajive.R:542` | Builds concatenated signal score matrix, estimates or accepts joint rank, applies identifiability filtering | `tests/testthat/test-calibration-joint-rank.R`, `tests/testthat/test-rajive-threshold-augment.R`, `tests/testthat/test-rajive-boundaries.R` |
| Final decomposition | `R/Rajive.R::get_final_decomposition_robustH()` at `R/Rajive.R:690` | Creates individual, joint, and noise decompositions per block | `tests/testthat/test-extractors.R`, `tests/testthat/test-varexplained.R`, `tests/testthat/test-variance-partition.R` |
| Result construction | `R/Rajive.R:480` | Returns a list with class `rajive` and slots `block_decomps`, `joint_scores`, `joint_rank`, `joint_rank_sel` | `tests/testthat/test-extractors.R`, `tests/testthat/test-visualization.R` |

Native-missing flow:

| Step | Evidence | Data Flow | Behavior Pinned By |
|---|---|---|---|
| Dispatch | `R/Rajive.R:261` | `Rajive(..., missing = "native")` delegates to `R/missing_data.R::.Rajive_incomplete()` | `tests/testthat/test-missing-native-dispatch.R` |
| Control and masks | `R/missing_data.R::rajive_missing_control()` at `R/missing_data.R:530`, `.normalize_missing_mask()` at `R/missing_data.R:47` | Builds native control list and observed-entry masks | `tests/testthat/test-missing-native-validation.R`, `tests/testthat/test-missing-native-preprocess.R` |
| Native validation | `R/missing_data.R::.validate_native_missing_inputs()` at `R/missing_data.R:218` | Rejects fully missing blocks/features and drops all-block-missing samples with warning class `rajiveplus_sample_all_missing` | `tests/testthat/test-missing-native-edge.R`, `tests/testthat/test-missing-native-validation.R` |
| Preprocess | `R/missing_data.R::.center_scale_observed()` at `R/missing_data.R:304` | Centers/scales by observed entries and preserves mask semantics | `tests/testthat/test-missing-native-preprocess.R`, `tests/testthat/test-missing-native-geometry.R` |
| All-observed fast path | `R/missing_data.R:841` | Delegates to `.Rajive_core()` and attaches native-missing metadata | `tests/testthat/test-missing-native-dispatch.R` |
| Observed-entry fit | `R/missing_data.R:898`, `R/missing_data.R:916`, `R/missing_data.R:929` | Weighted per-block SVD, joint score SVD, masked joint/individual/noise decomposition | `tests/testthat/test-missing-native-core.R`, `tests/testthat/test-missing-native-reconstruction.R` |
| Metadata and accessors | `R/missing_data.R::.attach_native_missing_metadata()` at `R/missing_data.R:734` | Adds `missing` metadata and class `c("rajive_incomplete", "rajive")` | `tests/testthat/test-missing-native-diagnostics.R`, `tests/testthat/test-missing-native-estimability.R` |
| Optional uncertainty | `R/Rajive.R:276`, `R/missing_data.R::.compute_missing_uncertainty()` at `R/missing_data.R:1617` | Adds refit-based native-missing uncertainty payload when requested | `tests/testthat/test-missing-native-uncertainty.R` |

**Hypotheses**

No unverified runtime path is needed for Stages 1 and 2. The only algorithmic hypotheses worth preserving for Stage 3 are native-missing statistical design questions from [audits/2026-05-15-missing-data-audit.md](audits/2026-05-15-missing-data-audit.md): per-block rather than joint-level EM, no recentering inside the weighted SVD loop, and weighted native SVD using classical `svd()` rather than Huber robust fitting.

### Module Responsibilities and Data Flow

**Confirmed**

| Module | Responsibility | Inputs and Outputs | Main Readers | Refactor Risk |
|---|---|---|---|---|
| `R/Rajive.R` | Public `Rajive()` dispatch, complete-data fit, rank thresholds, joint score selection, final block decomposition | Blocks and rank settings to `rajive` or `rajive_incomplete` result | Extractors, visualization, inference, bootstrap, variance partition, native metadata attachment | High |
| `R/Rajive_helpfunctions.R` | SVD wrappers, rank-bound resampling, block score/loading/rank/matrix accessors, variance explained | Fit objects and decompositions to scores/loadings/ranks/variance summaries | `R/visualization.R`, tests, downstream users through exports | Medium |
| `R/RobustSVD.R` | R-facing robust SVD wrappers, weighted native missing SVD, shrinkage handling | Matrices, rank, optional weights to `d/u/v` decompositions | `R/Rajive.R`, `R/missing_data.R` | Medium |
| `src/RobustSVD.cpp` | Huber robust rank-one and multi-rank SVD kernels | Numeric matrices to R lists `d`, `u`, `v` | `R/RobustSVD.R` through generated Rcpp exports | Medium |
| `src/RankBounds.cpp` | Native rank-bound simulation helpers | Random draws and singular values to threshold samples | `R/Rajive_helpfunctions.R` | Low |
| `R/missing_data.R` | Native missing-data pipeline, controls, masks, estimability, diagnostics, reconstruction, uncertainty | Blocks plus masks/control to `rajive_incomplete` and metadata/accessor outputs | `R/Rajive.R`, visualization users, native tests | High |
| `R/extractors.R` | Internal matrix reconstruction and extraction backbone for fitted objects | Fit plus component names to reconstructed block matrices | `R/variance_partition.R`, fortify/plot/test helpers | Medium |
| `R/bootstrap_engine.R` | Bootstrap/jackknife engines and stability payloads | Fit object, block data, rank settings to resampled summaries | `R/inference_ci.R`, `R/visualization.R` | Medium |
| `R/inference_ci.R` | Confidence interval API and interval assembly | `rajive` object plus blocks to CI data frames | Users, vignette tests | Medium |
| `R/jackstraw.R` | Jackstraw tests, p-value adjustment, PIP summaries, S3 methods | Blocks, scores, fit to `jackstraw_rajive` | Plotting and significant-variable accessors | Medium |
| `R/variance_partition.R` | Per-block joint/individual/residual variance partition | Fit object and optional original blocks to tidy variance table | Visualization and tests | Low |
| `R/visualization.R` | Plotting, association testing, stability, feature ranking, reports, S3 `autoplot`/`fortify` | Fit objects and metadata to plots/tables/files | Many public API users | High |
| `R/simulation.functions.R` | Small simulation helpers | Dimensions and noise settings to toy blocks | Tests and examples | Low |

The central data flow is:

1. `Rajive()` produces a fitted result object.
2. Extractor/helper layers reconstruct scores, loadings, ranks, block matrices, and variance summaries.
3. Inference, jackstraw, visualization, reporting, and native-missing accessors read the fitted object directly or through partial helper layers.

**Hypotheses**

The package does not yet have an executable internal schema contract for result objects. This is inferred from open-coded list construction in `R/Rajive.R:480`, `R/missing_data.R:958`, and `.Rajive_rank_only()` in `R/bootstrap_engine.R:458`, plus direct readers across modules. A small constructor layer should make this contract explicit before larger refactors.

### Result Object Structures and Slot Invariants

**Confirmed**

| Class | Structure and Invariants | Principal Readers | Pinning Tests |
|---|---|---|---|
| `rajive` | List with `block_decomps`, `joint_scores`, `joint_rank`, `joint_rank_sel`; `block_decomps` is a three-row by K block list matrix where row 1 is individual, row 2 is joint, row 3 is noise, and many readers flatten it with `3 * (k - 1) + offset` | `R/Rajive_helpfunctions.R::get_block_scores()`, `get_block_loadings()`, `get_block_matrix()`, `R/extractors.R::.extract_block_matrices()`, `R/visualization.R::.extract_scores()`, `R/bootstrap_engine.R::.extract_score_matrix()` | `tests/testthat/test-extractors.R`, `tests/testthat/test-varexplained.R`, `tests/testthat/test-variance-partition.R`, `tests/testthat/test-bootstrap-engine.R`, `tests/testthat/test-visualization.R` |
| `rajive_incomplete` | Extends `rajive` with class order `c("rajive_incomplete", "rajive")` and a `missing` list containing masks, missingness metadata, estimability, reconstruction provenance, diagnostics/control, uncertainty, censoring, and sensitivity fields | Native accessors in `R/missing_data.R`, plot/summary methods, reconstruction APIs | `tests/testthat/test-missing-native-diagnostics.R`, `tests/testthat/test-missing-native-estimability.R`, `tests/testthat/test-missing-native-reconstruction.R`, `tests/testthat/test-missing-native-uncertainty.R` |
| `jackstraw_rajive` | List of per-block jackstraw entries plus attributes for `alpha`, correction, joint rank, block/test counts, and optional PIP grouping; class set in `R/jackstraw.R:509` | `summary.jackstraw_rajive()`, `autoplot.jackstraw_rajive()`, `fortify.jackstraw_rajive()`, `get_significant_vars()` | `tests/testthat/test-jackstraw.R`, `tests/testthat/test-jackstraw-defaults.R`, `tests/testthat/test-jackstraw-pip.R`, `tests/testthat/test-calibration-jackstraw.R` |

**Hypotheses**

The flat `block_decomps` convention is the highest-impact internal schema problem because it is simple, pervasive, and not self-documenting. Replacing call-site arithmetic with one accessor layer is likely enough for maintainability without redesigning the public result object.

### R/C++ Boundary

**Confirmed**

| Boundary | Evidence | Responsibility | Fragility |
|---|---|---|---|
| `R/RobustSVD.R::RobRSVD.all()` to `src/RobustSVD.cpp::RobRSVD_all_cpp` | `R/RobustSVD.R:27`, `src/RobustSVD.cpp:185` | Multi-rank Huber robust SVD for complete data, returning `d`, `u`, `v` | Medium, because callers depend on named fields and generated exports |
| `R/RobustSVD.R::RobRSVD1()` to `src/RobustSVD.cpp::RobRSVD1_cpp` | `R/RobustSVD.R:291`, `src/RobustSVD.cpp:27` | Rank-one robust SVD kernel | Low to medium |
| Deflation warm start | `src/RobustSVD.cpp:227` | Recomputes leading singular vector of residual after each deflation step; prior audit W-H3 is landed | Low, pinned by `tests/testthat/test-robustsvd-deflation.R` |
| Rank-bound C++ helpers | `src/RankBounds.cpp::wedin_bound_resampling_cpp_draws()` and `random_direction_bound_cpp_draws()` | Native threshold simulations fed by R-generated draws | Low to medium, pinned by RNG and parity tests |
| Leading singular value helper | `src/RankBounds.cpp:8` | Uses full `arma::svd()` to compute one singular value | Low functional risk, performance opportunity from prior NAT-003b |

Rank validation primarily lives in R:

- Complete-data ranks: `R/Rajive.R::.Rajive_core()` at `R/Rajive.R:346`.
- Robust SVD rank and weights: `R/RobustSVD.R::RobRSVD.all()` at `R/RobustSVD.R:27`.
- Native-missing rank settings and auto-rank control: `R/missing_data.R::.Rajive_incomplete()` at `R/missing_data.R:757` and `diagnose_missing_ranks()` at `R/missing_data.R:1513`.

Generated files `R/RcppExports.R` and `src/RcppExports.cpp` must only be changed through implementation-phase `conda run -n R4_51 R --no-save -q -e "Rcpp::compileAttributes()"` if native signatures change. Stages 1 and 2 below avoid R/C++ signature changes.

**Hypotheses**

Replacing `src/RankBounds.cpp::leading_singular_value()` with an eigenvalue or crossproduct-based one-value computation should be a behavior-preserving performance PR, but it is not required for the maintainability redesign unless profiling keeps rank-bound helpers on the critical path.

### Test Coverage Map

**Confirmed**

| Area | Existing Test Files | Coverage Strength | Refactoring Gap |
|---|---|---|---|
| Complete `Rajive()` validation, boundaries, RNG, rank paths | `tests/testthat/test-rajive-validation.R`, `test-rajive-boundaries.R`, `test-rajive-rng.R`, `test-rajive-seed.R`, `test-rajive-rank-only.R`, `test-rajive-perm.R`, `test-rajive-threshold-augment.R` | Good for user-visible behavior and rank controls | No single schema test for result-object invariants |
| Robust SVD and native C++ | `test-robustsvd-rcpp.R`, `test-robustsvd-deflation.R`, `test-robustsvd-weights.R`, `test-audit-robustsvd-zero-rank.R`, `test-rank-bound-rcpp.R`, `test-performance-refactors.R` | Good for zero-rank, deflation, weighted path, parity/perf gates | C++ boundary safety is split across files; no central "generated-file policy" test, which is fine |
| Native missing-data pipeline | `test-missing-native-core.R`, `test-missing-native-validation.R`, `test-missing-native-preprocess.R`, `test-missing-native-geometry.R`, `test-missing-native-reconstruction.R`, `test-missing-native-diagnostics.R`, `test-missing-native-estimability.R`, `test-missing-native-rank-selection.R`, `test-missing-native-rank-diagnostics.R`, `test-missing-native-uncertainty.R`, `test-missing-native-censoring.R`, `test-missing-native-edge.R`, `test-missing-native-edge-rank.R`, `test-missing-native-shrinkage.R` | Strong for the landed MD roadmap and recent hardening | Algorithmic redesign would need new slow simulation characterization, not just unit tests |
| Extractors and variance | `test-extractors.R`, `test-varexplained.R`, `test-variance-partition.R`, `test-audit-fortify-variance.R` | Good for output shape and variance contracts | Missing focused tests for internal block-decomposition indexing helpers because those helpers do not yet exist |
| Bootstrap and confidence intervals | `test-bootstrap-engine.R`, `test-inference-ci.R`, `test-vignette-inference.R` | Good for payload shape, seeds, rank-only refits, interval types | Row assembly and loadings access rely on direct internals |
| Jackstraw | `test-jackstraw.R`, `test-jackstraw-defaults.R`, `test-jackstraw-pip.R`, `test-calibration-jackstraw.R` | Good, including PERF-002 cache behavior and calibration | Slow calibration remains optional by design |
| Visualization, association, stability, reporting | `test-visualization.R`, `test-visualization-stability.R`, `test-audit-association-method.R`, `test-audit-stability-method.R`, `test-associate-components-uncertainty.R`, `test-associate-all-components-simulations.R` | Broad and useful but concentrated in large files | Splitting `R/visualization.R` needs characterization around exported functions before file moves |
| Vignettes and fixtures | `test-vignette-native-missing-union.R`, `test-vignette-inference.R`, helpers `helper-calibration.R`, `helper-missing-union.R`, `helper-v02-fixtures.R` | Good light workflow checks | Heavy workflows are SLURM-only and must not be local validation |

**Hypotheses**

The riskiest refactors are not under-tested globally, but they lack small, targeted red-first tests for internal structure. Adding `tests/testthat/test-result-object-schema.R` and extending `tests/testthat/test-extractors.R` should reduce that risk before implementation.

### Undocumented Conventions

**Confirmed**

| Convention | Evidence | Maintainer Impact | Tests That Pin It |
|---|---|---|---|
| `block_decomps` flat index arithmetic | `R/Rajive_helpfunctions.R:327`, `R/bootstrap_engine.R:104`, `R/inference_ci.R:101`, `R/visualization.R:643` | Requires remembering row offsets across modules | `test-extractors.R`, `test-bootstrap-engine.R`, `test-inference-ci.R`, `test-visualization.R` |
| Decomposition records use named fields `d`, `u`, `v`, `full`, `rank` | `R/Rajive.R:761`, `R/missing_data.R:625`, `R/extractors.R:77` | Named and positional access are mixed; positional access is avoidable | `test-robustsvd-rcpp.R`, `test-missing-native-reconstruction.R`, `test-varexplained.R` |
| Native masks are observed-entry masks, not missing-entry masks | `R/missing_data.R:.normalize_missing_mask()` and `.classify_missingness()` | Misreading this breaks estimability and reconstruction | `test-missing-native-validation.R`, `test-missing-native-preprocess.R`, `test-missing-native-geometry.R` |
| Native `scaled_blocks` are finite even when `aligned_blocks` may contain `NA` rows in union workflows | `tests/testthat/helper-missing-union.R`, `tests/testthat/test-vignette-native-missing-union.R` | Important for BMV union-cache interpretation | `test-vignette-native-missing-union.R` |
| RNG discipline mixes `withr::local_seed()` in native paths with doRNG/parallel guards in complete paths | `R/missing_data.R:770`, `R/missing_data.R:1542`, `R/Rajive.R:397`, `tests/testthat/helper-calibration.R:34` | Seed handling is correct but distributed across modules | `test-rajive-rng.R`, `test-rajive-seed.R`, `test-missing-native-rank-diagnostics.R` |
| Calibration tolerances are helper-derived for Monte Carlo tests | `tests/testthat/helper-calibration.R` | Prevents brittle calibration tests, but slow gates are easy to forget | `test-calibration-wedin.R`, `test-calibration-joint-rank.R`, `test-calibration-jackstraw.R` |
| Some helpers are exported/documented even if implementation-oriented | `_pkgdown.yml`, `NAMESPACE` | Renames/removals require public API treatment | `test-audit-build-metadata.R`, package build metadata checks |

**Hypotheses**

Documenting only four conventions would give the highest return: result object schema, mask semantics, RNG discipline, and generated-file policy. A larger architecture manual is not necessary for one maintainer unless Stage 3 begins.

### Maintainability Diagnosis

**Confirmed Findings**

| ID | Finding | Evidence | Pinning Test(s) | Why It Matters for One Maintainer | Risk |
|---|---|---|---|---|---|
| M-01 | `block_decomps` indexing is duplicated and arithmetic-based across modules | `R/Rajive_helpfunctions.R:327`, `R/bootstrap_engine.R:104`, `R/inference_ci.R:101`, `R/visualization.R:643`, `R/visualization.R:2980` | `test-extractors.R`, `test-bootstrap-engine.R`, `test-inference-ci.R`, `test-visualization.R`, `test-varexplained.R` | A maintainer must preserve an implicit 3-by-K schema while editing unrelated features | Medium |
| M-02 | Result object construction is open-coded in multiple places | Complete object at `R/Rajive.R:480`, native object at `R/missing_data.R:958`, rank-only object at `R/bootstrap_engine.R:458` | `test-rajive-rank-only.R`, `test-missing-native-dispatch.R`, `test-extractors.R` | Schema drift can appear as downstream extractor or plot failures far from the edit | Medium |
| M-03 | `R/visualization.R` has too many responsibilities | Public API list at `R/visualization.R:1`, plotting at `R/visualization.R:420`, association at `R/visualization.R:1447`, stability at `R/visualization.R:2025`, reporting at `R/visualization.R:2629`, S3 at `R/visualization.R:3181` | `test-visualization.R`, `test-visualization-stability.R`, `test-audit-association-method.R`, `test-audit-stability-method.R`, `test-associate-components-uncertainty.R` | Reviewing or changing one feature requires scanning a 3,254-line mixed module | High |
| M-04 | Reconstruction helpers overlap | `R/extractors.R:77`, `R/missing_data.R:625`, `R/Rajive_helpfunctions.R:75` | `test-extractors.R`, `test-missing-native-reconstruction.R`, `test-variance-partition.R` | Full/zero-rank/native reconstruction semantics can diverge silently | Medium |
| M-05 | Error/message discipline is inconsistent | `R/Rajive.R:551` uses `stop`, `R/Rajive.R:662` emits raw `message`, while other paths use `cli::cli_abort`; visualization has many base `stop()` sites | `test-warning-suppression.R`, `test-rajive-validation.R`, `test-visualization.R` | Typed conditions are harder to catch and noisy output is harder to test | Low |
| M-06 | Native missing-data module is cohesive by feature but cognitively too large | `R/missing_data.R` has control, masks, preprocessing, fit, diagnostics, accessors, plots, uncertainty, censoring, sensitivity in one 1,773-line file | Native missing test group listed above | A single edit can require understanding all layers of the feature | High |
| M-07 | Native weighted SVD is functionally separate from Huber robust C++ SVD | Weighted path at `R/RobustSVD.R:73`, classical `svd()` in `.RobRSVD_all_weighted_R()` at `R/RobustSVD.R:241` | `test-robustsvd-weights.R`, `test-missing-native-shrinkage.R` | The naming can overstate robustness for missing-data fits unless documented | Medium |
| M-08 | Rank-bound native helper still computes one value through full SVD | `src/RankBounds.cpp:8` | `test-rank-bound-rcpp.R`, `test-performance-refactors.R` | Low maintenance burden, but an easy-to-isolate future performance PR | Low |

**Hypotheses**

| ID | Hypothesis | Evidence Basis | Test or Evidence Needed Before Acting | Risk |
|---|---|---|---|---|
| H-01 | Internal constructors will remove most object-schema risk without a public redesign | M-01 and M-02 above | New schema tests plus unchanged existing extractor/plot/inference tests | Medium |
| H-02 | Splitting `R/visualization.R` by topic will reduce cognitive load without behavior change | M-03 above | Characterization tests for each exported visualization/association/stability/report function before file moves | Medium |
| H-03 | Native missing-data algorithm changes are not justified as maintainability work alone | Native audit F1/F2/F5 and current implemented hardening | Slow simulations and benchmark criteria, not just unit tests | High |

## Deliverable 2: Staged Refactoring Proposal

Every proposed source edit below has a red-first test requirement. The package's TDD rule in [audits/PLANS.md](audits/PLANS.md) remains binding: add or update the named test first, confirm it fails for the intended reason, then implement.

### Stage 0: Safety Preparation

**Confirmed**

Stage 0 is read/test-only during an implementation cycle. It should not change source behavior. For this planning pass, none of these commands were run.

Targeted baseline commands, all using the required `R4_51` conda environment:

```bash
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-extractors.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-varexplained.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-variance-partition.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-bootstrap-engine.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-inference-ci.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-visualization.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-visualization-stability.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-missing-native-core.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-missing-native-reconstruction.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-missing-native-diagnostics.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-rajive-rng.R')"
conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-rank-bound-rcpp.R')"
```

Full local validation gates for implementation PRs:

```bash
conda run -n R4_51 R --no-save -q -e "devtools::test()"
conda run -n R4_51 R --no-save -q -e "devtools::check(args = c('--no-manual'), error_on = 'never')"
RAJIVE_RUN_SLOW=1 conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-calibration-wedin.R')"
RAJIVE_RUN_SLOW=1 conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-calibration-joint-rank.R')"
RAJIVE_RUN_SLOW=1 conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-calibration-jackstraw.R')"
```

Stale-validation caveats to carry into implementation review:

- BMV fit/downstream caches are stale relative to the 120-sample union preprocess cache documented in [audits/PROGRESS.md](audits/PROGRESS.md).
- Heavy benchmark jobs `24763952` and `24766432` were cancelled/stale.
- Release Gate 2 job `24728717` timed out and needs extended-walltime resubmission before release claims.
- Full-suite validation was stale after the latest native-missing regularization/hardening pass.
- Acceptable carried warnings/notes are listed in [audits/PROGRESS.md](audits/PROGRESS.md); this plan does not reclassify them.

**Hypotheses**

Stage 0 should add only characterization tests if an implementation PR needs them. The two highest-value new tests are:

| New Test File | Red-First Assertion | Source Edit It Enables | Independent |
|---|---|---|---|
| `tests/testthat/test-result-object-schema.R` (new proposed) | A `Rajive()` fit has named slots, class, block count, three decomposition roles per block, and native fits retain `c("rajive_incomplete", "rajive")`; this fails until explicit schema helper expectations or constructors exist | Internal result constructors | Yes |
| Extension to `tests/testthat/test-extractors.R` | New internal accessors reject invalid block/component names and return the same object as existing flat indexing; this fails until accessors exist | Replace arithmetic block access with named accessors | Yes |

### Stage 1: Low-Risk Cleanup

**Confirmed**

| Item | Current Problem | Proposed Structure or Behavior | Files/Functions Affected | Risk | Red-First Tests Needed | After-Edit Validation | Independent |
|---|---|---|---|---|---|---|---|
| S1-01 | Flat `block_decomps` arithmetic appears in many readers | Add non-exported helpers in `R/extractors.R`, such as `.block_decomp_index()`, `.get_block_decomp()`, `.get_block_role_matrix()`, then migrate call sites gradually | `R/extractors.R`, `R/Rajive_helpfunctions.R`, `R/bootstrap_engine.R`, `R/inference_ci.R`, `R/visualization.R` | Medium | Extend `tests/testthat/test-extractors.R` with failing assertions for invalid role/block and equality with existing joint/individual/noise entries | `test-extractors.R`, `test-bootstrap-engine.R`, `test-inference-ci.R`, `test-visualization.R`, `test-varexplained.R` | Yes, if migrated in small batches |
| S1-02 | Reconstruction helpers duplicate zero-rank/full-matrix rules | Consolidate reconstruction through one non-exported helper in `R/extractors.R`, preserving native metadata and `full=FALSE` semantics | `R/extractors.R::.reconstruct_decomp_matrix()`, `R/missing_data.R::.component_matrix_from_decomp()`, `R/Rajive_helpfunctions.R::svd_reconstruction()` | Medium | Add red-first cases to `test-extractors.R` and `test-missing-native-reconstruction.R` for zero-rank, `full` fallback, and `d/u/v` reconstruction equality | `test-extractors.R`, `test-missing-native-reconstruction.R`, `test-variance-partition.R` | Yes |
| S1-03 | Mixed positional and named SVD list access increases fragility | Replace positional `l[[1]]` in `R/Rajive.R:436` with named `l[['d']]`; audit similar low-risk list accesses | `R/Rajive.R::.Rajive_core()` | Low | Add a red-first expectation in `test-rajive-boundaries.R` or a new local helper test that a named `RobRSVD.all()` result is consumed by name, not order | `test-rajive-boundaries.R`, `test-robustsvd-rcpp.R` | Yes |
| S1-04 | Native-missing constants and validation rules are spread through the large module | Name small internal constants for ridge defaults, tolerance defaults, and role labels without changing values | `R/missing_data.R::rajive_missing_control()`, `.solve_masked_joint_matrix()`, role helpers | Low | Add red-first assertions to `test-missing-native-validation.R` that defaults are unchanged and invalid controls still error identically | Native missing validation/core test subset | Yes |
| S1-05 | Dead-code cleanup is tempting but unsafe without reference scanning | Remove only code with confirmed zero references across `R/`, `tests/`, `vignettes/`, `inst/`, `_pkgdown.yml`, `NAMESPACE`, and docs | Any candidate found later | Low to high depending on candidate | For each candidate, add or update a test that fails if the supposedly dead path is still used; if no such test is sensible, do not remove | Full targeted suite for affected area | Yes, case by case |

**Hypotheses**

S1-01 is the safest first real source change because it can add helpers without changing existing call sites. The second commit can replace readers one file at a time, with existing tests proving behavior preservation.

### Stage 2: Integration Improvements

**Confirmed**

| Item | Current Problem | Proposed Structure or Behavior | Files/Functions Affected | Risk | Red-First Tests Needed | After-Edit Validation | Independent |
|---|---|---|---|---|---|---|---|
| S2-01 | Result construction is duplicated and implicit | Introduce non-exported constructors, e.g. `.new_rajive()` and `.new_rajive_incomplete()`, that validate slot names, class, block count, and decomposition roles | New proposed `R/result_objects.R` or existing `R/extractors.R`; call sites in `R/Rajive.R`, `R/missing_data.R`, `R/bootstrap_engine.R` | Medium | `tests/testthat/test-result-object-schema.R` (new proposed) fails until constructors enforce slot and class invariants | `test-result-object-schema.R`, `test-extractors.R`, `test-missing-native-dispatch.R`, `test-bootstrap-engine.R` | Yes, after S1-01 |
| S2-02 | Complete and native result paths are coupled through ad hoc list shape | Route both `.Rajive_core()` and `.Rajive_incomplete()` through constructors while keeping public object shape unchanged | `R/Rajive.R::.Rajive_core()`, `R/missing_data.R::.Rajive_incomplete()`, `.attach_native_missing_metadata()` | Medium | Extend `test-result-object-schema.R` with complete, all-observed native, and observed-entry native fixtures; assert identical public slots before/after | Native missing core/dispatch/reconstruction tests plus extractor tests | Yes |
| S2-03 | Plotting, association, stability, ranking, reporting, and S3 methods share one huge file | Split `R/visualization.R` into topical files without changing exported function names or roxygen aliases: plots/S3, association, stability, ranking, reporting | `R/visualization.R`; new proposed topical R files | Medium to high | Before each move, add snapshot or structural assertions to `test-visualization.R`, `test-visualization-stability.R`, `test-audit-association-method.R`, and `test-associate-components-uncertainty.R` for the functions being moved | Visualization/association/stability tests and `test-audit-build-metadata.R`; implementation phase may require `conda run -n R4_51 R --no-save -q -e "devtools::document()"` | Yes, one topical split per PR |
| S2-04 | Native missing-data has multiple layers in one module | Split internal native helpers by responsibility only after constructors/accessors are stable: masks/preprocess, fit, diagnostics/accessors, uncertainty | `R/missing_data.R`; new proposed native helper files | High | Add file-level characterization in existing native tests: masks, preprocess, reconstruction, diagnostics, uncertainty each assert public outputs unchanged | Full native missing targeted suite | Yes, but after S2-01 and S2-02 |
| S2-05 | Inference and bootstrap directly read object internals | Replace direct reads with Stage 1 accessors and constructors, preserving payloads | `R/bootstrap_engine.R`, `R/inference_ci.R` | Medium | Extend `test-bootstrap-engine.R` and `test-inference-ci.R` with assertions on score/loading source roles and rank-only object class/schema | Bootstrap and inference tests | Yes |

**Hypotheses**

S2 should be enough for maintainability if it makes the object schema executable and shrinks `R/visualization.R` into topical files. It should not redesign the statistical algorithm or public object shape.

### Stage 3: Architectural Redesign Only If Needed

**Confirmed**

Stage 3 is not required before Stages 1 and 2. It should begin only if, after accessor/constructor extraction and file splitting, maintainability remains blocked by algorithmic coupling or repeated schema exceptions.

Possible Stage 3 scope:

| Area | Current Evidence | Proposed Architecture | Required Red-First Tests | Risk | Migration Path |
|---|---|---|---|---|---|
| Fitted decomposition abstraction | `block_decomps` schema is implicit across many modules | Internal class or structured list for one block decomposition with named `individual`, `joint`, `noise` roles | New proposed `test-result-object-schema.R` plus unchanged public extractor tests | High | Keep public `block_decomps` layout, add adapter layer, migrate internals first |
| Blocks and masks abstraction | Native mask semantics are concentrated in `R/missing_data.R` but consumed by diagnostics/reconstruction | Internal `observed_mask`/`block_set` helper objects, never exported initially | Native validation/preprocess/reconstruction tests with observed-entry and union-sample fixtures | High | Preserve `fit$missing` layout and accessor outputs |
| Diagnostics/provenance abstraction | Native diagnostics, reconstruction provenance, uncertainty, censoring, sensitivity live in one `missing` list | Internal constructor for `missing` metadata payload with required fields | Native diagnostics/uncertainty/censoring tests | Medium | Add payload validator, keep existing accessor names |
| R/C++ boundary safety | Generated exports and native helper signatures are fragile if changed manually | Versioned native wrapper tests and generated-file policy documentation | `test-robustsvd-rcpp.R`, `test-rank-bound-rcpp.R`, `test-audit-build-metadata.R` | Medium | Do not change C++ signatures unless a dedicated PR runs `conda run -n R4_51 R --no-save -q -e "Rcpp::compileAttributes()"` |
| Native missing algorithm redesign | Per-block EM, one-pass centering, and classical weighted SVD are documented design concerns | Joint-level masked decomposition or robust weighted native kernel | New slow simulation/calibration tests plus benchmark criteria | High | Add opt-in control path first, keep current default until validated |

**Hypotheses**

The native-missing algorithm redesign is the riskiest potential Stage 3 item. It is not justified by maintainability alone and should be treated as a research/validation project with rollback to the current `missing = "native"` behavior.

## Deliverable 3: Implementation Roadmap and Documentation Plan

### Roadmap for One Maintainer

**Confirmed**

No roadmap item below proposes reimplementing landed W-R0 through W-R11, MD-0 through MD-14, or PERF-002. PERF-001, PERF-003, PERF-004, and NAT-003b remain deferred unless explicitly scoped into a later PR.

| PR | Scope | Dependencies | Effort | Validation Commands | Rollback Strategy | Definition of Done |
|---|---|---|---|---|---|---|
| PR-1 | Add object-schema and block-accessor characterization tests only | None | S | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-extractors.R')"` and `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-result-object-schema.R')"` | Drop only the new tests if they encode the wrong invariant | Tests fail red-first before implementation, then define the intended schema clearly |
| PR-2 | Add non-exported block-decomposition accessors in `R/extractors.R` | PR-1 | S | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-extractors.R')"` | Remove new helper functions; no public API affected | New helper tests pass; no call sites migrated yet |
| PR-3 | Replace direct block indexing in `R/Rajive_helpfunctions.R`, `R/bootstrap_engine.R`, and `R/inference_ci.R` | PR-2 | M | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-bootstrap-engine.R')"` and `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-inference-ci.R')"` | Revert only the call-site replacement commit | Existing outputs and payload shapes unchanged |
| PR-4 | Replace direct block indexing in `R/visualization.R` | PR-2 and PR-3 | M | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-visualization.R')"` and `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-visualization-stability.R')"` | Revert visualization-only call-site replacement | Plot, fortify, stability, association, and ranking tests unchanged |
| PR-5 | Consolidate reconstruction helpers | PR-2 | M | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-missing-native-reconstruction.R')"` and `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-variance-partition.R')"` | Restore old helper calls; keep tests if they reveal a real invariant | One reconstruction helper owns zero-rank/full/native semantics |
| PR-6 | Add internal result constructors and route complete/native/rank-only object creation through them | PR-1 through PR-5 | M | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-result-object-schema.R')"` and `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-missing-native-dispatch.R')"` | Revert constructor routing; public object shape remains unchanged | Constructors validate schema; public objects are byte-level or structurally equivalent where appropriate |
| PR-7 | Split `R/visualization.R` topically without behavior changes | PR-6 | L | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-visualization.R')"` plus association/stability targeted tests | Revert one topical file move at a time | Exported names, docs, and tests unchanged after implementation-phase `conda run -n R4_51 R --no-save -q -e "devtools::document()"` |
| PR-8 | Split `R/missing_data.R` internally by responsibility | PR-6 | L | Native missing targeted suite listed in Stage 0 | Revert one file split at a time; keep constructors/accessors | Native public API and metadata unchanged; module responsibilities are documented |
| PR-9 | Optional NAT-003b performance PR for `src/RankBounds.cpp::leading_singular_value()` | Any time after PR-1 | S | `conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-rank-bound-rcpp.R')"` and `RAJIVE_RUN_PERF=1 conda run -n R4_51 R --no-save -q -e "testthat::test_file('tests/testthat/test-performance-refactors.R')"` | Revert the C++ helper only | Functional parity and perf gate pass; generated exports unchanged unless signatures change |
| PR-10 | Release validation refresh | After chosen implementation PRs | M | `conda run -n R4_51 R --no-save -q -e "devtools::test()"` and `conda run -n R4_51 R --no-save -q -e "devtools::check(args = c('--no-manual'), error_on = 'never')"` | Revert last behavior-changing PR if failures cannot be isolated | Full local gates refreshed; stale-caveat list in `audits/PROGRESS.md` can be updated by the maintainer in a separate protocol-compliant step |

No local heavy vignette rendering should be part of these PR validations. Heavy workflows under `inst/benchmarks/` and `inst/analyses/` remain SLURM-only.

**Hypotheses**

PR-7 and PR-8 should be separated even if the changes are mechanical. Splitting both large modules in one PR would make rollback and review unnecessarily hard for a one-person maintainer.

### Documentation Plan

**Confirmed**

The smallest useful documentation set is:

1. A concise architecture overview in `README.Rmd` and the pkgdown reference index.
2. A new proposed `audits/ARCHITECTURE.md` for internal module responsibilities, result-object schema, mask semantics, R/C++ boundary, and generated-file policy.
3. A short testing and validation extension in `audits/AGENTS.md`.
4. A new proposed `logs/README.md` for SLURM-only validation and stale-cache interpretation.

Suggested homes:

| Topic | Suggested Home | Smallest Useful Content | Timing |
|---|---|---|---|
| Top-level architecture overview | `README.Rmd` plus `_pkgdown.yml` reference index | One diagram-style paragraph: `Rajive()` to fit object to extractors/inference/visualization/native accessors | After constructors/accessors land |
| Module responsibility table | New proposed `audits/ARCHITECTURE.md` | The module table from Deliverable 1, kept shorter | After PR-6 |
| Main workflows | `vignettes/` light only | Existing workflows plus a pointer to native missing union vignette; no heavy benchmark rendering | Only when behavior changes |
| `rajive`, `rajive_incomplete`, `jackstraw_rajive` reference | `man/` via roxygen on constructors or class docs | Slot schema, invariants, and accessor-first guidance | After PR-6, generated by implementation-phase `conda run -n R4_51 R --no-save -q -e "devtools::document()"` |
| Native-missing workflow | Existing `vignettes/native_missing_union.Rmd` reference | Link to mask semantics, estimability, reconstruction provenance | After PR-8 if file split changes internals |
| R/C++ boundary explanation | New proposed `audits/ARCHITECTURE.md` | Which R wrappers call which C++ functions and generated-file policy | After any C++ PR or PR-6 |
| Testing guide | `audits/AGENTS.md` extension | R4_51 command patterns, slow/perf env vars, targeted test matrix | After PR-1 |
| SLURM/validation guide | New proposed `logs/README.md` | Which jobs are heavy, stale cache caveats, release gate expectations | Before release validation refresh |
| Generated-file policy | `audits/AGENTS.md` | Do not hand-edit `man/`, `NAMESPACE`, `R/RcppExports.R`, or `src/RcppExports.cpp`; regenerate only in scoped PRs | After PR-1 |

Helpful diagrams described in text:

- Runtime flow: `Rajive()` branches into complete-data `.Rajive_core()` and native `.Rajive_incomplete()`, both producing the same public `rajive`-compatible schema.
- Object schema: one fitted object with `joint_scores`, `joint_rank`, `joint_rank_sel`, and a three-role-per-block decomposition matrix.
- Native missing: raw blocks plus observed masks to preprocessing, weighted per-block SVD, masked reconstruction, metadata/accessors.
- R/C++ boundary: R validation/wrappers above generated Rcpp exports above `src/RobustSVD.cpp` and `src/RankBounds.cpp`.

**Hypotheses**

A separate long-form developer manual is unnecessary. The maintainer needs a compact architecture note plus tests that encode the important invariants.

1. **Top three highest-impact refactors** - First, centralize `block_decomps` access in `R/extractors.R` and migrate readers in `R/Rajive_helpfunctions.R`, `R/bootstrap_engine.R`, `R/inference_ci.R`, and `R/visualization.R`; second, add internal result constructors for `rajive` and `rajive_incomplete` in a new proposed result-object helper and route `R/Rajive.R` plus `R/missing_data.R` through them; third, split `R/visualization.R` into topical plotting, association, stability, feature-ranking, reporting, and S3 modules without changing exported names.
2. **Safest first change** - Add red-first accessor tests to `tests/testthat/test-extractors.R` for `.block_decomp_index()` and `.get_block_decomp()` before implementing the non-exported helpers in `R/extractors.R`.
3. **Riskiest proposed change** - Native missing-data algorithm redesign is highest risk because it changes statistical behavior in `R/missing_data.R` and `R/RobustSVD.R`; rollback is to keep the current `missing = "native"` path as default and introduce any redesigned path behind an opt-in control only after slow simulation validation.
4. **Minimum test coverage required before implementation begins** - Existing files: `tests/testthat/test-extractors.R`, `test-varexplained.R`, `test-variance-partition.R`, `test-bootstrap-engine.R`, `test-inference-ci.R`, `test-visualization.R`, `test-visualization-stability.R`, `test-missing-native-core.R`, `test-missing-native-reconstruction.R`, `test-missing-native-diagnostics.R`, `test-missing-native-dispatch.R`, `test-rajive-boundaries.R`, `test-rajive-rng.R`, `test-rank-bound-rcpp.R`; new proposed file: `tests/testthat/test-result-object-schema.R`.

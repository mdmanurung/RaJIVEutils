# Package index

## Core decomposition

Run the RaJIVE decomposition and simulate data.

- [`Rajive()`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md)
  : Robust Angle based Joint and Individual Variation Explained
- [`ajive.data.sim()`](https://mdmanurung.github.io/RaJIVEutils/reference/ajive.data.sim.md)
  : Simulation of data blocks
- [`sim_dist()`](https://mdmanurung.github.io/RaJIVEutils/reference/sim_dist.md)
  : Simulation of single data block from distribution

## Rank accessors

Extract rank estimates from a `rajive` object.

- [`get_joint_rank()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_joint_rank.md)
  : Joint Rank
- [`get_individual_rank()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_individual_rank.md)
  : Individual Rank
- [`get_all_ranks()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_all_ranks.md)
  : Summary table of all ranks

## Component accessors

Extract scores, loadings, and reconstructed matrices.

- [`get_joint_scores()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_joint_scores.md)
  : Joint Scores
- [`get_block_scores()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_block_scores.md)
  : Block Scores
- [`get_block_loadings()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_block_loadings.md)
  : Block Loadings
- [`get_block_matrix()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_block_matrix.md)
  : Extract a reconstructed block matrix

## S3 methods for `rajive` objects

print and summary methods.

- [`print(`*`<rajive>`*`)`](https://mdmanurung.github.io/RaJIVEutils/reference/print.rajive.md)
  : Print method for rajive objects
- [`summary(`*`<rajive>`*`)`](https://mdmanurung.github.io/RaJIVEutils/reference/summary.rajive.md)
  : Summary method for rajive objects

## Variance explained

Quantify and visualise explained variance.

- [`showVarExplained_robust()`](https://mdmanurung.github.io/RaJIVEutils/reference/showVarExplained_robust.md)
  : Proportions of variance explained
- [`plot_variance_explained()`](https://mdmanurung.github.io/RaJIVEutils/reference/plot_variance_explained.md)
  : Bar chart of variance explained

## Visualisation

Heatmaps and score plots.

- [`decomposition_heatmaps_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/decomposition_heatmaps_robustH.md)
  : Decomposition Heatmaps
- [`data_heatmap()`](https://mdmanurung.github.io/RaJIVEutils/reference/data_heatmap.md)
  : Decomposition Heatmaps
- [`plot_scores()`](https://mdmanurung.github.io/RaJIVEutils/reference/plot_scores.md)
  : Scatter plot of block scores

## Internal decomposition helpers

Low-level functions used internally by
[`Rajive()`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md)
to compute joint and individual decompositions.

- [`get_final_decomposition_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_final_decomposition_robustH.md)
  : Computes the final JIVE decomposition.
- [`get_individual_decomposition_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_individual_decomposition_robustH.md)
  : Computes the individual matrix for a data block.
- [`get_joint_decomposition_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_joint_decomposition_robustH.md)
  : Computes the individual matrix for a data block
- [`get_joint_scores_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_joint_scores_robustH.md)
  : Computes the joint scores.

## Robust SVD utilities

Functions for computing, truncating, and reconstructing the robust SVD.

- [`RobRSVD.all()`](https://mdmanurung.github.io/RaJIVEutils/reference/RobRSVD.all.md)
  : Computes the robust SVD of a matrix
- [`RobRSVD1()`](https://mdmanurung.github.io/RaJIVEutils/reference/RobRSVD1.md)
  : Single robust rank-1 component (Rcpp wrapper)
- [`get_svd_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_svd_robustH.md)
  : Computes the robust SVD of a matrix Using robRsvd
- [`get_sv_threshold()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_sv_threshold.md)
  : The singular value threshold.
- [`truncate_svd()`](https://mdmanurung.github.io/RaJIVEutils/reference/truncate_svd.md)
  : Truncates a robust SVD.
- [`svd_reconstruction()`](https://mdmanurung.github.io/RaJIVEutils/reference/svd_reconstruction.md)
  : Reconstruces the original matrix from its robust SVD.

## Rank estimation internals

Wedin bound and random direction bound helpers used in joint rank
estimation.

- [`get_random_direction_bound_robustH()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_random_direction_bound_robustH.md)
  : Estimate the wedin bound for a data matrix.
- [`get_wedin_bound_samples()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_wedin_bound_samples.md)
  : Gets the wedin bounds
- [`wedin_bound_resampling()`](https://mdmanurung.github.io/RaJIVEutils/reference/wedin_bound_resampling.md)
  : Resampling procedure for the wedin bound

## Jackstraw significance testing

Permutation-based test to identify variables with significantly non-zero
joint loadings.

- [`jackstraw_rajive()`](https://mdmanurung.github.io/RaJIVEutils/reference/jackstraw_rajive.md)
  : Jackstraw significance testing for RaJIVE joint loadings
- [`print(`*`<jackstraw_rajive>`*`)`](https://mdmanurung.github.io/RaJIVEutils/reference/print.jackstraw_rajive.md)
  : Print method for jackstraw_rajive objects
- [`summary(`*`<jackstraw_rajive>`*`)`](https://mdmanurung.github.io/RaJIVEutils/reference/summary.jackstraw_rajive.md)
  : Summary method for jackstraw_rajive objects
- [`get_significant_vars()`](https://mdmanurung.github.io/RaJIVEutils/reference/get_significant_vars.md)
  : Extract significant variables from jackstraw results
- [`plot_jackstraw()`](https://mdmanurung.github.io/RaJIVEutils/reference/plot_jackstraw.md)
  : Plot jackstraw results

## Package

Package-level documentation.

- [`rajiveutils`](https://mdmanurung.github.io/RaJIVEutils/reference/rajiveutils-package.md)
  [`rajiveutils-package`](https://mdmanurung.github.io/RaJIVEutils/reference/rajiveutils-package.md)
  : rajiveutils: Robust Angle Based Joint and Individual Variation
  Explained

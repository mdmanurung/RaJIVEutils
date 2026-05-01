# Computes the joint scores.

Estimate the joint rank with the wedin bound, compute the signal scores
SVD, double check each joint component.

## Usage

``` r
get_joint_scores_robustH(
  blocks,
  block_svd,
  initial_signal_ranks,
  sv_thresholds,
  n_wedin_samples = 1000,
  n_rand_dir_samples = 1000,
  joint_rank = NA,
  num_cores = 2
)
```

## Arguments

- blocks:

  List. A list of the data matrices.

- block_svd:

  List. The SVD of the data blocks.

- initial_signal_ranks:

  Numeric vector. Initial signal ranks estimates.

- sv_thresholds:

  Numeric vector. The singular value thresholds from the initial signal
  rank estimates.

- n_wedin_samples:

  Integer. Number of wedin bound samples to draw for each data matrix.

- n_rand_dir_samples:

  Integer. Number of random direction bound samples to draw.

- joint_rank:

  Integer or NA. User specified joint_rank. If NA will be estimated from
  data.

- num_cores:

  Integer. Number of cores for parallel resampling.

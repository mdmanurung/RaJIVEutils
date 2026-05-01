# Computes the individual matrix for a data block.

Computes the individual matrix for a data block.

## Usage

``` r
get_individual_decomposition_robustH(
  X,
  joint_scores,
  sv_threshold,
  full = TRUE
)
```

## Arguments

- X:

  Matrix. The original data matrix.

- joint_scores:

  Matrix. The basis of the joint space (dimension n x joint_rank).

- sv_threshold:

  Numeric vector. The singular value thresholds from the initial signal
  rank estimates.

- full:

  Boolean. Do we compute the full J, I matrices or just the SVD (set to
  FALSE to save memory).

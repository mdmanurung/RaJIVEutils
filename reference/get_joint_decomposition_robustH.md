# Computes the individual matrix for a data block

Computes the individual matrix for a data block

## Usage

``` r
get_joint_decomposition_robustH(X, joint_scores, full = TRUE)
```

## Arguments

- X:

  Matrix. The original data matrix.

- joint_scores:

  Matrix. The basis of the joint space (dimension n x joint_rank).

- full:

  Boolean. Do we compute the full J, I matrices or just the SVD (set to
  FALSE to save memory).

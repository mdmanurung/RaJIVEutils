# Resampling procedure for the wedin bound

Resampling procedure for the wedin bound

## Usage

``` r
wedin_bound_resampling(
  X,
  perp_basis,
  right_vectors,
  num_samples = 1000,
  num_cores = 2
)
```

## Arguments

- X:

  Matrix. The data matrix.

- perp_basis:

  Matrix. Either U_perp or V_perp: the remaining left/right singluar
  vectors of X after estimating the signal rank.

- right_vectors:

  Boolean. Right multiplication or left multiplication.

- num_samples:

  Integer. Number of vectors selected for resampling procedure.

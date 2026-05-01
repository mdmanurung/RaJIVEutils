# Gets the wedin bounds

Gets the wedin bounds

## Usage

``` r
get_wedin_bound_samples(X, SVD, signal_rank, num_samples = 1000, num_cores = 2)
```

## Arguments

- X:

  Matrix. The data matrix.

- SVD:

  List. The SVD decomposition of the matrix. List with entries 'u', 'd',
  and 'v'from the svd function.

- signal_rank:

  Integer.

- num_samples:

  Integer. Number of vectors selected for resampling procedure.

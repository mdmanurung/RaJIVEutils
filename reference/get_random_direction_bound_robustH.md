# Estimate the wedin bound for a data matrix.

Samples from the random direction bound. Returns on the scale of squared
singular value.

## Usage

``` r
get_random_direction_bound_robustH(
  n_obs,
  dims,
  num_samples = 1000,
  num_cores = 2
)
```

## Arguments

- n_obs:

  The number of observations.

- dims:

  The number of features in each data matrix

- num_samples:

  Integer. Number of vectors selected for resampling procedure.

## Value

rand_dir_samples

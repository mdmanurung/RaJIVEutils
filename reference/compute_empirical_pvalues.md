# Compute empirical p-values from observed and null F-statistics

For feature `i`, the p-value is the proportion of its `n_null` null
F-statistics that exceed the observed value. `NA` observed statistics
(constant features) receive p-value = 1.

## Usage

``` r
compute_empirical_pvalues(f_obs, f_null)
```

## Arguments

- f_obs:

  length-`d` numeric vector of observed F-statistics.

- f_null:

  `d x n_null` numeric matrix of null F-statistics.

## Value

length-`d` numeric vector of empirical p-values in \[0, 1\].

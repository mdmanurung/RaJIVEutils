# Vectorized OLS F-statistics for simple linear regression

For every row of `Y_t` (each feature), compute the F-statistic for
`feature ~ x + 1` in a single matrix operation. Constant rows (zero
variance) return `NA`.

## Usage

``` r
ols_f_stat_matrix(Y_t, x)
```

## Arguments

- Y_t:

  `d x n` numeric matrix; features are rows, observations are columns.

- x:

  length-`n` numeric vector of predictor values (joint scores for one
  component).

## Value

length-`d` numeric vector of F-statistics (`NA` for constant rows).

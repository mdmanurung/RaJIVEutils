# Extract significant variables from jackstraw results

Convenience accessor that retrieves the vector of significant variables
(either column names or integer indices) for a given block and joint
component.

## Usage

``` r
get_significant_vars(jackstraw_result, block = 1L, component = 1L)
```

## Arguments

- jackstraw_result:

  An object of class `"jackstraw_rajive"`.

- block:

  Positive integer; which block.

- component:

  Positive integer; which joint component.

## Value

A character vector of variable names (when the original data matrix had
column names) or an integer vector of column indices.

## Examples

``` r
# \donttest{
set.seed(42)
n   <- 50
pks <- c(100, 80)
Y   <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                      pks = pks, dist.type = 1)
data.ajive           <- Y$sim_data
initial_signal_ranks <- c(5, 4)
ajive_result <- Rajive(data.ajive, initial_signal_ranks)
js <- jackstraw_rajive(ajive_result, data.ajive, alpha = 0.05, n_null = 10)
get_significant_vars(js, block = 1, component = 1)
#>  [1]  1  2  6  8  9 10 11 14 15 16 19 23 24 25 26 27 29 30 31 32 34 37 38 39 41
#> [26] 47 48 50 51 56 59 61 64 65 67 69 70 71 73 75 76 77 78 79 80 81 82 84 85 86
#> [51] 88 89 91 92 94 95 96 97 98 99
# }
```

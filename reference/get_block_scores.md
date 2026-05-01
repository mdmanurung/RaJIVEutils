# Block Scores

Gets the block scores from the Rajive decomposition

## Usage

``` r
get_block_scores(ajive_output, k, type)
```

## Arguments

- ajive_output:

  List. The decomposition from Rajive

- k:

  Integer. The index of the data block

- type:

  Character. Joint or individual

## Value

The block scores

## Examples

``` r
# \donttest{
n <- 10
pks <- c(20, 10)
Y <- ajive.data.sim(K =2, rankJ = 2, rankA = c(7, 4), n = n,
                 pks = pks, dist.type = 1)
initial_signal_ranks <-  c(7, 4)
data.ajive <- list((Y$sim_data[[1]]), (Y$sim_data[[2]]))
ajive.results.robust <- Rajive(data.ajive, initial_signal_ranks)
#> [1] "removing column 0"
#> [1] "removing column 0"
get_block_scores(ajive.results.robust, 2, 'joint')
#>             [,1]
#>  [1,] -0.3213410
#>  [2,] -0.1297164
#>  [3,] -0.2827318
#>  [4,] -0.2763831
#>  [5,]  0.2642353
#>  [6,] -0.0167420
#>  [7,] -0.4941460
#>  [8,] -0.3076598
#>  [9,]  0.4932019
#> [10,] -0.2672174
# }
```

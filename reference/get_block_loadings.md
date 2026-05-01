# Block Loadings

Gets the block loadings from the Rajive decomposition

## Usage

``` r
get_block_loadings(ajive_output, k, type)
```

## Arguments

- ajive_output:

  List. The decomposition from Rajive

- k:

  Integer. The index of the data block

- type:

  Character. Joint or individual

## Value

The block loadings

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
get_block_loadings(ajive.results.robust, 2, 'joint')
#>              [,1]
#>  [1,]  0.33393104
#>  [2,] -0.40750975
#>  [3,] -0.10352564
#>  [4,]  0.08190530
#>  [5,] -0.71437028
#>  [6,]  0.23069178
#>  [7,] -0.07688778
#>  [8,] -0.01612791
#>  [9,]  0.32505268
#> [10,] -0.17211960
# }
```

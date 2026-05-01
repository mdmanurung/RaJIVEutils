# Proportions of variance explained

Gets the variance explained by each component of the Rajive
decomposition

## Usage

``` r
showVarExplained_robust(ajiveResults, blocks)
```

## Arguments

- ajiveResults:

  List. The decomposition from Rajive

- blocks:

  List. The initial data blocks

## Value

The proportion of variance explained by each component

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
showVarExplained_robust(ajive.results.robust, data.ajive)
#> $Joint
#> [1] 0.1514145 0.3372620
#> 
#> $Indiv
#> [1] 0.8121792 0.5820067
#> 
#> $Resid
#> [1] 0.03640635 0.08073130
#> 
# }
```

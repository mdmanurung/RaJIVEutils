# Joint Rank

Gets the joint rank from the Rajive decomposition

## Usage

``` r
get_joint_rank(ajive_output)
```

## Arguments

- ajive_output:

  List. The decomposition from Rajive

## Value

The joint rank

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
get_joint_rank(ajive.results.robust)
#> [1] 1
# }
```

# Summary table of all ranks

Returns a `data.frame` with the joint rank and individual rank for every
data block, making it easy to inspect all estimated ranks at once.

## Usage

``` r
get_all_ranks(ajive_output)
```

## Arguments

- ajive_output:

  List returned by
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md).

## Value

A `data.frame` with columns `block`, `joint_rank`, and
`individual_rank`.

## Examples

``` r
# \donttest{
n <- 30; pks <- c(40, 30)
Y <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                    pks = pks, dist.type = 1)
res <- Rajive(Y$sim_data, c(5, 4))
get_all_ranks(res)
#>    block joint_rank individual_rank
#> 1 block1          1               4
#> 2 block2          1               3
# }
```

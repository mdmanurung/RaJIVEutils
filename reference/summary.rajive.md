# Summary method for rajive objects

Returns (and prints) a `data.frame` with the joint rank and individual
rank for every data block.

## Usage

``` r
# S3 method for class 'rajive'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"rajive"` returned by
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md).

- ...:

  Ignored.

## Value

A `data.frame` with columns `block`, `joint_rank`, and
`individual_rank`, returned invisibly.

## Examples

``` r
# \donttest{
n <- 30; pks <- c(40, 30)
Y <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                    pks = pks, dist.type = 1)
res <- Rajive(Y$sim_data, c(5, 4))
summary(res)
#>   block joint_rank individual_rank
#>  block1          1               4
#>  block2          1               3
# }
```

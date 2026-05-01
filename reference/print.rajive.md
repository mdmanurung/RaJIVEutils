# Print method for rajive objects

Displays a concise summary of the RaJIVE decomposition: number of
blocks, estimated joint rank, and individual rank for each data block.

## Usage

``` r
# S3 method for class 'rajive'
print(x, ...)
```

## Arguments

- x:

  An object of class `"rajive"` returned by
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md).

- ...:

  Ignored.

## Value

`x` invisibly.

## Examples

``` r
# \donttest{
n <- 30; pks <- c(40, 30)
Y <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                    pks = pks, dist.type = 1)
res <- Rajive(Y$sim_data, c(5, 4))
print(res)
#> RaJIVE Decomposition
#>   Number of blocks : 2
#>   Joint rank       : 1
#>   Individual ranks : 4, 3
# }
```

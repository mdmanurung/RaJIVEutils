# Extract a reconstructed block matrix

Returns the full reconstructed matrix for the joint (\\J\\), individual
(\\I\\), or noise (\\E\\) component of a single data block from a RaJIVE
decomposition.

## Usage

``` r
get_block_matrix(ajive_output, k, type = c("joint", "individual", "noise"))
```

## Arguments

- ajive_output:

  List returned by
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md).

- k:

  Positive integer; index of the data block.

- type:

  Character string; one of `"joint"`, `"individual"`, or `"noise"`.

## Value

The reconstructed matrix for the requested component and block. Returns
`NA` if
[`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md)
was called with `full = FALSE`.

## Examples

``` r
# \donttest{
n <- 30; pks <- c(40, 30)
Y <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                    pks = pks, dist.type = 1)
res <- Rajive(Y$sim_data, c(5, 4))
J1 <- get_block_matrix(res, k = 1, type = "joint")
# }
```

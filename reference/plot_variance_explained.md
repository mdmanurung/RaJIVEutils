# Bar chart of variance explained

Produces a stacked bar chart showing the proportion of total variance
explained by the joint, individual, and residual components for each
data block.

## Usage

``` r
plot_variance_explained(ajive_output, blocks)
```

## Arguments

- ajive_output:

  List returned by
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md).

- blocks:

  List of data matrices (the same list passed to
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md)).

## Value

A `ggplot2` object.

## Examples

``` r
# \donttest{
n <- 30; pks <- c(40, 30)
Y <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                    pks = pks, dist.type = 1)
data.ajive <- Y$sim_data
res <- Rajive(data.ajive, c(5, 4))
#> [1] "removing column 0"
#> [1] "removing column 0"
plot_variance_explained(res, data.ajive)

# }
```

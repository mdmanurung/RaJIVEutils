# Truncates a robust SVD.

Removes columns from the U, D, V matrix computed form an SVD.

## Usage

``` r
truncate_svd(decomposition, rank)
```

## Arguments

- decomposition:

  List. List with entries 'u', 'd', and 'v'from the svd function.

- rank:

  List. List with entries 'u', 'd', and 'v'from the svd function.

## Value

The trucated robust SVD of X.

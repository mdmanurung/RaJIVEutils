# Reconstruces the original matrix from its robust SVD.

Computes UDV^T to get the approximate (or full) X matrix.

## Usage

``` r
svd_reconstruction(decomposition)
```

## Arguments

- decomposition:

  List. List with entries 'u', 'd', and 'v'from the svd function.

## Value

Matrix. The original matrix.

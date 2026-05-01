# Computes the robust SVD of a matrix

Thin R wrapper around the RcppArmadillo implementation
`RobRSVD_all_cpp`. The interface and return value are identical to the
original pure-R version.

## Usage

``` r
RobRSVD.all(data, nrank = min(dim(data)), svdinit = svd(data))
```

## Arguments

- data:

  Matrix. X matrix.

- nrank:

  Integer. Rank of SVD decomposition

- svdinit:

  List. The standard SVD.

## Value

List with entries `d`, `u`, `v`.

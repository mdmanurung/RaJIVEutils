# Single robust rank-1 component (Rcpp wrapper)

Thin R wrapper around `RobRSVD1_cpp`, preserved for backward
compatibility and direct testing.

## Usage

``` r
RobRSVD1(data, huberk = 1.345, niter = 1000, tol = 1e-05, sinit, uinit, vinit)
```

## Arguments

- data:

  Matrix. X matrix.

- huberk:

  Numeric. Huber k tuning constant.

- niter:

  Integer. Maximum iterations.

- tol:

  Numeric. Convergence tolerance.

- sinit:

  Numeric. Initial singular value.

- uinit:

  Numeric vector. Initial left singular vector.

- vinit:

  Numeric vector. Initial right singular vector.

## Value

List with entries `s`, `u`, `v`.

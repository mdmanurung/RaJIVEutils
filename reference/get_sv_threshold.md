# The singular value threshold.

Computes the singular value threshold for the data matrix (half way
between the rank and rank + 1 singluar value).

## Usage

``` r
get_sv_threshold(singular_values, rank)
```

## Arguments

- singular_values:

  Numeric. The singular values.

- rank:

  Integer. The rank of the approximation.

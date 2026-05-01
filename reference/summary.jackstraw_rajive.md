# Summary method for jackstraw_rajive objects

Returns (and prints) a `data.frame` with one row per block/component
combination.

## Usage

``` r
# S3 method for class 'jackstraw_rajive'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"jackstraw_rajive"`.

- ...:

  Ignored.

## Value

A `data.frame` with columns `block`, `component`, `n_features`,
`n_significant`, and `alpha`.

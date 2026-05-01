# Generate null F-statistics via jackstraw permutation

For each of the `d` features, sample `n_null` feature rows from `X_t`
(with replacement), permute the sampled rows' values (breaking any
association with `joint_comp_scores`), and compute their F-statistics.

## Usage

``` r
generate_null_f_stats(X_t, joint_comp_scores, n_null)
```

## Arguments

- X_t:

  `d x n` numeric matrix (data block, transposed).

- joint_comp_scores:

  length-`n` numeric vector of joint scores for one component.

- n_null:

  positive integer; number of null F-statistics per feature.

## Value

`d x n_null` numeric matrix of null F-statistics.

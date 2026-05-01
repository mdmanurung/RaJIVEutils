# Robust Angle based Joint and Individual Variation Explained

Computes the robust aJIVE decomposition with parallel computation.

## Usage

``` r
Rajive(
  blocks,
  initial_signal_ranks,
  full = TRUE,
  n_wedin_samples = 1000,
  n_rand_dir_samples = 1000,
  joint_rank = NA,
  num_cores = 1L
)
```

## Arguments

- blocks:

  List. A list of the data matrices.

- initial_signal_ranks:

  Vector. The initial signal rank estimates.

- full:

  Boolean. Whether or not to store the full J, I, E matrices or just
  their SVDs (set to FALSE to save memory).

- n_wedin_samples:

  Integer. Number of wedin bound samples to draw for each data matrix.

- n_rand_dir_samples:

  Integer. Number of random direction bound samples to draw.

- joint_rank:

  Integer or NA. User specified joint_rank. If NA will be estimated from
  data.

- num_cores:

  Integer. Number of cores to use for parallel computation (block SVD,
  singular value extraction, Wedin bound resampling, and random
  direction bound sampling). Default `1L` (serial). Set to a value
  greater than 1 to enable parallel execution via
  [`mclapply`](https://rdrr.io/r/parallel/mclapply.html) and
  [`registerDoParallel`](https://rdrr.io/pkg/doParallel/man/registerDoParallel.html).

## Value

An object of class `"rajive"`: a named list containing:

- `block_decomps`:

  A list matrix (length \\3 \times K\\) of per-block decompositions. For
  block \\k\\: individual component at index \\3(k-1)+1\\, joint
  component at \\3(k-1)+2\\, noise (residual) at \\3(k-1)+3\\.

- `joint_scores`:

  The \\n \times r_J\\ matrix of shared joint score vectors, where
  \\r_J\\ is the estimated (or user-supplied) joint rank.

- `joint_rank`:

  Integer. The estimated (or user-supplied) joint rank.

- `joint_rank_sel`:

  A list of diagnostic information from the joint rank selection step
  (observed singular values, Wedin samples, random direction samples,
  thresholds).

## Examples

``` r
# \donttest{
n <- 50
pks <- c(100, 80, 50)
Y <- ajive.data.sim(K =3, rankJ = 3, rankA = c(7, 6, 4), n = n,
                   pks = pks, dist.type = 1)
initial_signal_ranks <-  c(7, 6, 4)
data.ajive <- list((Y$sim_data[[1]]), (Y$sim_data[[2]]), (Y$sim_data[[3]]))
ajive.results.robust <- Rajive(data.ajive, initial_signal_ranks)
# }
```

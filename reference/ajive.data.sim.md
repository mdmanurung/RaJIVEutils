# Simulation of data blocks

Simulates blocks of data with joint and individual structures

## Usage

``` r
ajive.data.sim(
  K = 3,
  rankJ = 2,
  rankA = c(20, 15, 10),
  n = 100,
  pks,
  dist.type = 1,
  noise = 1
)
```

## Arguments

- K:

  Integer. Number of data blocks.

- rankJ:

  Integer. Joint rank.

- rankA:

  Vector of Integers. Individual Ranks.

- n:

  Integer. Number of data points.

- pks:

  Vector of Integers. Number of variables in each block.

- dist.type:

  Integer. 1 for normal, 2 for uniform, 3 for exponential

- noise:

  Integer. Standard deviation in dist

## Value

Xsim a list of simulated data matrices and true rank values

## Examples

``` r
n <- 20
p1 <- 10
p2 <- 8
p3 <- 5
JrankTrue <- 2
initial_signal_ranks <- c(5, 2, 2)
 Y <- ajive.data.sim(K =3, rankJ = JrankTrue,
 rankA = initial_signal_ranks,n = n,
 pks = c(p1, p2, p3), dist.type = 1)
```

# Joint Scores

Returns the shared (cross-block) joint score matrix from a RaJIVE
decomposition. Each column corresponds to one joint component and each
row to one observation.

## Usage

``` r
get_joint_scores(ajive_output)
```

## Arguments

- ajive_output:

  List returned by
  [`Rajive`](https://mdmanurung.github.io/RaJIVEutils/reference/Rajive.md).

## Value

An \\n \times r_J\\ numeric matrix of joint scores, where \\r_J\\ is the
joint rank.

## Examples

``` r
# \donttest{
n <- 30; pks <- c(40, 30)
Y <- ajive.data.sim(K = 2, rankJ = 2, rankA = c(5, 4), n = n,
                    pks = pks, dist.type = 1)
res <- Rajive(Y$sim_data, c(5, 4))
get_joint_scores(res)
#>               [,1]
#>  [1,] -0.119835276
#>  [2,]  0.065225726
#>  [3,] -0.147097894
#>  [4,]  0.162890565
#>  [5,] -0.113374744
#>  [6,] -0.040709703
#>  [7,] -0.014397202
#>  [8,]  0.295080922
#>  [9,] -0.027664593
#> [10,] -0.459695812
#> [11,] -0.020072316
#> [12,] -0.391961993
#> [13,] -0.239694914
#> [14,]  0.153579306
#> [15,]  0.069975005
#> [16,] -0.345640463
#> [17,] -0.142625041
#> [18,] -0.054704045
#> [19,]  0.056566124
#> [20,]  0.002219755
#> [21,]  0.080603188
#> [22,] -0.073446441
#> [23,]  0.200562665
#> [24,]  0.165287980
#> [25,]  0.017819274
#> [26,]  0.010298120
#> [27,] -0.002584854
#> [28,]  0.147079110
#> [29,] -0.277817495
#> [30,]  0.233827201
# }
```

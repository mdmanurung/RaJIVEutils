
<!-- README.md is generated from README.Rmd. Please edit that file -->

``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "man/figures/README-",
  out.width = "100%"
)
```

# rajiveplus

<!-- badges: start -->

<!-- badges: end -->

rajiveplus (Robust Angle based Joint and Individual Variation Explained)
is a robust alternative to the aJIVE method for the estimation of joint
and individual components in the presence of outliers in multi-source
data. It decomposes the multi-source data into joint, individual and
residual (noise) contributions. The decomposition is robust with respect
to outliers and other types of noises present in the data.

## Installation

You can install the released version of rajiveplus from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("rajiveplus")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mdmanurung/rajiveplus")
```

## Example

This is a basic example which shows how to use rajiveplus on simple
simulated data:

### Running robust aJIVE

``` r
library(rajiveplus)
## basic example code
n <- 50
pks <- c(100, 80, 50)
Y <- ajive.data.sim(K =3, rankJ = 3, rankA = c(7, 6, 4), n = n,
                   pks = pks, dist.type = 1)

initial_signal_ranks <-  c(7, 6, 4)
data.ajive <- list((Y$sim_data[[1]]), (Y$sim_data[[2]]), (Y$sim_data[[3]]))
ajive.results.robust <- Rajive(data.ajive, initial_signal_ranks)
#> Loading required package: foreach
#> Loading required package: rngtools
```

The function returns a list of class `"rajive"` containing the RaJIVE
decomposition, with the joint component (shared across data sources),
individual component (data source specific) and residual component for
each data source.

### Inspecting the decomposition

- Print a concise overview:

``` r
print(ajive.results.robust)
#> RaJIVE Decomposition
#>   Number of blocks : 3
#>   Joint rank       : 2
#>   Individual ranks : 5, 5, 3
```

- Summary table of all ranks:

``` r
summary(ajive.results.robust)
#>   block joint_rank individual_rank
#>  block1          2               5
#>  block2          2               5
#>  block3          2               3
get_all_ranks(ajive.results.robust)
#>    block joint_rank individual_rank
#> 1 block1          2               5
#> 2 block2          2               5
#> 3 block3          2               3
```

- Joint rank:

``` r
get_joint_rank(ajive.results.robust)
#> [1] 2
```

- Individual ranks:

``` r
get_individual_rank(ajive.results.robust, 1)
#> [1] 5
get_individual_rank(ajive.results.robust, 2)
#> [1] 5
get_individual_rank(ajive.results.robust, 3)
#> [1] 3
```

- Shared joint scores (n × joint_rank matrix):

``` r
get_joint_scores(ajive.results.robust)
#>                [,1]         [,2]
#>  [1,] -0.1269092076 -0.049391981
#>  [2,] -0.0060429318 -0.173387549
#>  [3,] -0.0342059026 -0.151155078
#>  [4,]  0.0491275023 -0.007335108
#>  [5,]  0.2413407639  0.056574168
#>  [6,]  0.0956757420  0.135810008
#>  [7,]  0.2378519328  0.054564292
#>  [8,]  0.0776440092  0.127265089
#>  [9,] -0.1932531915  0.068697471
#> [10,] -0.1545606524  0.014038958
#> [11,] -0.0365219405  0.227268870
#> [12,]  0.1684782867  0.036226184
#> [13,] -0.0753771956  0.043694419
#> [14,] -0.0968551271 -0.060857453
#> [15,]  0.1085210787 -0.066015191
#> [16,]  0.1057764223  0.021479455
#> [17,]  0.0471357663  0.044353022
#> [18,]  0.0142216164 -0.445891142
#> [19,]  0.1593950554 -0.117827440
#> [20,]  0.2440673594 -0.115811287
#> [21,]  0.1204123993 -0.207177649
#> [22,]  0.0247477691 -0.034689293
#> [23,]  0.3462080301 -0.025321517
#> [24,]  0.0770182846 -0.186048456
#> [25,] -0.1164931984  0.192950896
#> [26,] -0.1276410204 -0.013653644
#> [27,] -0.0330780485  0.073373946
#> [28,]  0.2058204584 -0.172954359
#> [29,]  0.1157546280  0.264233792
#> [30,] -0.2456604577 -0.040632879
#> [31,]  0.1653167993  0.194993838
#> [32,]  0.0082455636  0.187518278
#> [33,]  0.0072784238  0.154348757
#> [34,]  0.0008337975 -0.068418747
#> [35,]  0.0484577512 -0.186278934
#> [36,]  0.0938016525  0.089964463
#> [37,] -0.1791544955  0.113484663
#> [38,] -0.0592576595 -0.180632270
#> [39,] -0.0383289629  0.001836948
#> [40,] -0.2387195550 -0.016940657
#> [41,]  0.2087582389 -0.259141177
#> [42,] -0.2502695364 -0.223352415
#> [43,] -0.0346730956 -0.038158866
#> [44,] -0.1587980149 -0.222803604
#> [45,]  0.1112226930  0.128080624
#> [46,] -0.0374507054 -0.019871086
#> [47,] -0.0016854543  0.015311829
#> [48,]  0.1732428942  0.005909057
#> [49,]  0.1203274508  0.006938221
#> [50,] -0.1495186475 -0.091005765
```

- Block-specific scores and loadings:

``` r
# Joint scores for block 1
get_block_scores(ajive.results.robust, k = 1, type = "joint")
#>               [,1]         [,2]
#>  [1,] -0.135068923 -0.006961756
#>  [2,] -0.057231111 -0.163687932
#>  [3,] -0.077346044 -0.133529914
#>  [4,]  0.044428704 -0.022572370
#>  [5,]  0.245763470 -0.022437442
#>  [6,]  0.131104884  0.099396412
#>  [7,]  0.241856654 -0.023251603
#>  [8,]  0.111460215  0.096948703
#>  [9,] -0.162935560  0.126847484
#> [10,] -0.142462134  0.062382896
#> [11,]  0.032853162  0.228637215
#> [12,]  0.170595158 -0.018784543
#> [13,] -0.058532669  0.065616709
#> [14,] -0.109961964 -0.027435416
#> [15,]  0.083346774 -0.097437320
#> [16,]  0.106729871 -0.013001381
#> [17,]  0.057891134  0.027426143
#> [18,] -0.118942933 -0.430377560
#> [19,]  0.116222118 -0.163043262
#> [20,]  0.197149654 -0.187946995
#> [21,]  0.052701147 -0.236029688
#> [22,]  0.013175103 -0.040973401
#> [23,]  0.320927171 -0.133884494
#> [24,]  0.017808722 -0.202099255
#> [25,] -0.053208512  0.221199853
#> [26,] -0.125148481  0.027403866
#> [27,] -0.009588245  0.080560712
#> [28,]  0.143892599 -0.230405470
#> [29,]  0.188297145  0.215691937
#> [30,] -0.245126815  0.039031733
#> [31,]  0.214751742  0.133856429
#> [32,]  0.063517745  0.176486284
#> [33,]  0.052748475  0.145112475
#> [34,] -0.019530161 -0.065611044
#> [35,] -0.009355144 -0.193269661
#> [36,]  0.115710258  0.056203091
#> [37,] -0.136257779  0.165156468
#> [38,] -0.109867754 -0.153745696
#> [39,] -0.035817137  0.013899431
#> [40,] -0.231505100  0.059460907
#> [41,]  0.121081160 -0.313653494
#> [42,] -0.303769339 -0.134023525
#> [43,] -0.044228046 -0.025459032
#> [44,] -0.216827196 -0.162483127
#> [45,]  0.143558575  0.087087841
#> [46,] -0.041431478 -0.007112230
#> [47,]  0.002948804  0.015158405
#> [48,]  0.166110797 -0.049250195
#> [49,]  0.116215528 -0.031500389
#> [50,] -0.168878316 -0.039543088

# Individual loadings for block 2
get_block_loadings(ajive.results.robust, k = 2, type = "individual")
#>                [,1]         [,2]         [,3]         [,4]         [,5]
#>  [1,] -0.0544259879 -0.030503061 -0.171707970 -0.015184456 -0.123889817
#>  [2,]  0.1382204397  0.083292763  0.177195325 -0.028457811  0.141457335
#>  [3,] -0.0154689928 -0.011656024  0.052228285 -0.153461326 -0.142487494
#>  [4,]  0.3123120565 -0.138215523 -0.066475584 -0.041977010  0.088004993
#>  [5,]  0.1056150848  0.145751283 -0.098027116  0.185705794  0.020693222
#>  [6,]  0.2297179626 -0.031377789  0.088193151 -0.084372331 -0.088190960
#>  [7,]  0.0383986634  0.151249470  0.107986916  0.159769759  0.024174278
#>  [8,]  0.1629587445  0.035130999 -0.051480230 -0.114186344  0.004106824
#>  [9,]  0.1162698765  0.084200716  0.141239204  0.101088645  0.137185100
#> [10,]  0.0782362614 -0.016782579  0.012711974 -0.045788008 -0.036544811
#> [11,]  0.0924243716 -0.144184455 -0.055903341  0.230319202 -0.017774892
#> [12,] -0.1215615906 -0.108592839 -0.031905904 -0.204579741  0.047402610
#> [13,] -0.2124455021 -0.022332996  0.028302617  0.204122042  0.199092797
#> [14,] -0.0126724821  0.229253847 -0.007667275  0.098448306 -0.106521725
#> [15,] -0.0670091666 -0.203157575  0.122176642  0.006412954 -0.058771765
#> [16,] -0.1053409094  0.106578269 -0.065397773 -0.203793145  0.216794461
#> [17,]  0.0201859493  0.186136273 -0.124908936  0.034254538 -0.167929494
#> [18,]  0.0491177272  0.047695454 -0.046928396 -0.085464581  0.129992666
#> [19,] -0.0555964533  0.054775620  0.081201548  0.042757965  0.020928394
#> [20,] -0.0325734354  0.065477603 -0.141042681  0.068044757  0.084630289
#> [21,] -0.0290771367  0.074474272  0.015547095 -0.137045032 -0.077397696
#> [22,]  0.1837974312 -0.047261446 -0.022262250  0.119086864 -0.145878424
#> [23,] -0.1350845334  0.133596695  0.036621737 -0.066138734 -0.165924707
#> [24,] -0.0197329838  0.115291132 -0.003012773  0.101706481 -0.130484573
#> [25,] -0.0848028891  0.034436792 -0.016457491 -0.094701915  0.089598417
#> [26,] -0.1216541552 -0.139865125 -0.097035007 -0.073162223  0.122831133
#> [27,] -0.0182048605  0.155586708 -0.200056265 -0.042633271 -0.021568174
#> [28,]  0.0311689723  0.009906397  0.078289365  0.003121019  0.019496316
#> [29,]  0.0303982181  0.004558546 -0.015869641 -0.013199712  0.093167862
#> [30,] -0.1946680284  0.104437905  0.133382220 -0.016842462 -0.261514381
#> [31,] -0.1925752833 -0.023397393 -0.013185857  0.056679892  0.104147826
#> [32,]  0.2198750945  0.193014099  0.304614242 -0.087943215  0.028917937
#> [33,] -0.0042727897  0.092806582 -0.151073569  0.360562242  0.150754647
#> [34,] -0.1131534021 -0.030807310 -0.034851656  0.172295326 -0.176552647
#> [35,] -0.0857925747  0.146161013  0.123765760 -0.152469876 -0.057603809
#> [36,]  0.2661604255 -0.155158430 -0.032967682  0.065807964 -0.038401373
#> [37,]  0.1152860096  0.014661883 -0.083489685 -0.149142870  0.092244977
#> [38,] -0.0817664367 -0.057534894  0.055249851  0.071300182 -0.236113287
#> [39,] -0.0081839438 -0.067604997  0.015566676  0.086733048 -0.067653810
#> [40,] -0.0292231190 -0.041442635  0.169466612  0.051683994  0.016785116
#> [41,]  0.0909540118  0.051282409  0.010306339 -0.011640654 -0.023341185
#> [42,]  0.0211186346  0.078574369  0.085916281 -0.032219792 -0.180945454
#> [43,] -0.1597915329 -0.035865232 -0.095809620 -0.008059591 -0.057486757
#> [44,] -0.0202715916  0.014988724  0.161729767  0.040079968  0.110865801
#> [45,] -0.1208791300  0.043176136  0.224539265 -0.035237271  0.117184117
#> [46,] -0.0840635339 -0.264807606  0.094732575  0.208673764  0.091670040
#> [47,] -0.1146727416  0.014630543  0.222136714  0.052789504  0.146437402
#> [48,]  0.1313750401 -0.111049507  0.150246219  0.093316103 -0.090438062
#> [49,]  0.0205717700 -0.124650936 -0.055802828  0.060554944  0.242346067
#> [50,] -0.0719406476  0.103076779 -0.011839249  0.107615958  0.089907247
#> [51,]  0.0133688299  0.026558702 -0.254778432 -0.098300945  0.140490597
#> [52,]  0.0259202722  0.173832289  0.117293930 -0.136137669  0.132127947
#> [53,]  0.0556991805 -0.197738425  0.128900989 -0.045374135 -0.105772200
#> [54,]  0.0723012802 -0.044651492 -0.090805415  0.054988131 -0.005388514
#> [55,]  0.0380427216 -0.019248970 -0.040416273  0.143170134  0.085091678
#> [56,] -0.0529025997 -0.176380004 -0.061779114  0.059514439 -0.087093437
#> [57,]  0.0166174223 -0.158113716  0.079761683 -0.024501661 -0.041208927
#> [58,]  0.2307237246  0.167377043 -0.059322782  0.068155310  0.157279264
#> [59,]  0.0882533611 -0.151282383  0.139810965  0.021322392  0.177468108
#> [60,]  0.0106453135 -0.016380695  0.109802277 -0.004404667 -0.118673560
#> [61,] -0.0005266323  0.042757133 -0.037753825  0.276559822  0.073640789
#> [62,] -0.1110287867 -0.004201067  0.134213841  0.068539655 -0.011262507
#> [63,] -0.1075646817 -0.081359961 -0.096579042 -0.183266358  0.176795039
#> [64,]  0.1477140657  0.041271842 -0.028281007  0.115792019  0.031938469
#> [65,] -0.1057482897 -0.052426887  0.024903678  0.004683597  0.098912836
#> [66,]  0.1805622838  0.043361237  0.201060826  0.102241684  0.075655221
#> [67,]  0.1615072460  0.001416908 -0.017050180 -0.099217210 -0.096649478
#> [68,]  0.0817764604 -0.153995023 -0.078453472 -0.159309626  0.004032909
#> [69,]  0.1387576773  0.008053717  0.186020795 -0.050554025  0.036377915
#> [70,]  0.0286914801  0.311923995 -0.033528341  0.064397449 -0.091981281
#> [71,] -0.0852556124 -0.086541079  0.188361920  0.012952964 -0.172890585
#> [72,] -0.1586438084  0.188254388  0.083811522  0.014849662  0.076923977
#> [73,]  0.0404141407  0.132813394 -0.012096120 -0.112391938  0.076844943
#> [74,]  0.0174934167  0.037503664  0.087319666  0.044945462 -0.046306228
#> [75,]  0.0090465737  0.026125058 -0.057448127  0.084510800 -0.037780398
#> [76,] -0.0699700556 -0.060168250  0.234644717 -0.098377463  0.097132428
#> [77,] -0.1137922061 -0.103518097 -0.053927495 -0.042719852 -0.004478411
#> [78,] -0.0172180341  0.004968161  0.030081579  0.038729002  0.045320269
#> [79,] -0.0134647499 -0.134053181 -0.101078634  0.059249841  0.066192144
#> [80,]  0.0483736169 -0.087437788  0.001054430  0.147252953 -0.047155623
```

- Full reconstructed matrices (J, I, or E) for a block:

``` r
J1 <- get_block_matrix(ajive.results.robust, k = 1, type = "joint")
I2 <- get_block_matrix(ajive.results.robust, k = 2, type = "individual")
E3 <- get_block_matrix(ajive.results.robust, k = 3, type = "noise")
```

### Visualizing results

- Heatmap decomposition:

``` r
decomposition_heatmaps_robustH(data.ajive, ajive.results.robust)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" alt="" width="100%" />

``` r
knitr::include_graphics("man/figures/README-heatmap-1.png")
```

<img src="man/figures/README-heatmap-1.png" alt="" width="100%" />

- Proportion of variance explained (as a list):

``` r
showVarExplained_robust(ajive.results.robust, data.ajive)
#> $Joint
#> [1] 0.2545417 0.2486230 0.3634878
#> 
#> $Indiv
#> [1] 0.5144969 0.5654048 0.3881891
#> 
#> $Resid
#> [1] 0.2309614 0.1859722 0.2483231
```

- Proportion of variance explained (as a bar chart):

``` r
png("man/figures/README-variance-explained.png", width = 1600, height = 900, res = 150)
print(plot_variance_explained(ajive.results.robust, data.ajive))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-variance-explained.png")
```

<img src="man/figures/README-variance-explained.png" alt="" width="100%" />

- Scatter plot of scores (e.g. joint component 1 vs 2 for block 1):

``` r
png("man/figures/README-scores-joint.png", width = 1600, height = 900, res = 150)
print(plot_scores(ajive.results.robust, k = 1, type = "joint",
                  comp_x = 1, comp_y = 2))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-scores-joint.png")
```

<img src="man/figures/README-scores-joint.png" alt="" width="100%" />

``` r

# Colour points by a grouping variable
group_labels <- rep(c("A", "B"), each = n / 2)
png("man/figures/README-scores-joint-grouped.png", width = 1600, height = 900, res = 150)
print(plot_scores(ajive.results.robust, k = 1, type = "joint",
                  comp_x = 1, comp_y = 2, group = group_labels))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-scores-joint-grouped.png")
```

<img src="man/figures/README-scores-joint-grouped.png" alt="" width="100%" />

### Jackstraw significance testing

After running the RaJIVE decomposition, you can test which variables in
each data block have statistically significantly non-zero joint loadings
using the jackstraw permutation test.

By default, `jackstraw_rajive()` applies global BH correction across all
block/component/feature tests.

``` r
# Run jackstraw test (increase n_null to 50-100 for publication-quality results)
js <- jackstraw_rajive(ajive.results.robust, data.ajive,
                       alpha = 0.05, n_null = 10)

# Print a concise summary table
print(js)
#> JIVE Jackstraw Significance Test
#>   Joint rank: 2   Alpha: 0.05   Correction: BH
#> 
#>   Block      Component    N features     N significant 
#>   ----------------------------------------------------
#>   block1     comp1        100            40            
#>   block1     comp2        100            21            
#>   block2     comp1        80             35            
#>   block2     comp2        80             29            
#>   block3     comp1        50             18            
#>   block3     comp2        50             28

# Get a data frame summary
summary(js)
#>   block component n_features n_significant alpha correction
#>  block1     comp1        100            40  0.05         BH
#>  block1     comp2        100            21  0.05         BH
#>  block2     comp1         80            35  0.05         BH
#>  block2     comp2         80            29  0.05         BH
#>  block3     comp1         50            18  0.05         BH
#>  block3     comp2         50            28  0.05         BH
```

### AJIVE diagnostics and interpretation helpers

The package now includes unified helpers for diagnostics, metadata
association, and bootstrap stability assessment:

``` r
# Extract AJIVE rank diagnostics (wide or long format)
diag_wide <- extract_components(ajive.results.robust, what = "rank_diagnostics")
diag_long <- extract_components(ajive.results.robust, what = "rank_diagnostics", format = "long")
head(diag_long)
#>   component_index obs_sval obs_sval_sq classification joint_rank_estimate
#> 1               1 1.676735    2.811441          joint                   2
#> 2               2 1.556577    2.422931          joint                   2
#> 3               3 1.374272    1.888624       nonjoint                   2
#> 4               4 1.314514    1.727947       nonjoint                   2
#>   overall_sv_sq_threshold wedin_cutoff rand_cutoff perm_cutoff
#> 1                2.030483         -997    2.030483          NA
#> 2                2.030483         -997    2.030483          NA
#> 3                2.030483         -997    2.030483          NA
#> 4                2.030483         -997    2.030483          NA

# Unified diagnostic plots
png("man/figures/README-rank-threshold.png", width = 1600, height = 900, res = 150)
print(plot_components(ajive.results.robust, plot_type = "rank_threshold"))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-rank-threshold.png")
```

<img src="man/figures/README-rank-threshold.png" alt="" width="100%" />

``` r
png("man/figures/README-bound-distributions.png", width = 1600, height = 900, res = 150)
print(plot_components(ajive.results.robust, plot_type = "bound_distributions"))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-bound-distributions.png")
```

<img src="man/figures/README-bound-distributions.png" alt="" width="100%" />

``` r

# Associate estimated joint scores with sample-level metadata
metadata_df <- data.frame(group = rep(c("A", "B"), each = n / 2))
associate_components(ajive.results.robust, metadata_df,
                     variable = "group", mode = "categorical")
#> [associate_components] NOTE: Component scores are estimated quantities. Score estimation error is NOT propagated into the returned p-values. Treat results as post-decomposition exploratory associations, not exact fixed-design inference (StatisticalAudits.md, Finding 4).
#>   variable component        stat   p_value     p_adj  method
#> 1    group         1 2.033788235 0.1538367 0.3076735 kruskal
#> 2    group         2 0.002352941 0.9613121 0.9613121 kruskal

# Bootstrap stability of estimated joint rank
assess_stability(ajive.results.robust, data.ajive, initial_signal_ranks,
                 target = "joint_rank", B = 20)
#> $rank_distribution
#>  [1] 1 2 3 2 2 2 1 2 2 3 2 3 2 2 3 4 3 2 1 3
#> 
#> $rank_table
#> rank_draws
#>  1  2  3  4 
#>  3 10  6  1 
#> 
#> $observed_rank
#> [1] 2
```

- Retrieve significant variables for a given block and component:

``` r
get_significant_vars(js, block = 1, component = 1)
#>  [1]  4  9 12 13 15 16 17 19 20 24 28 29 33 40 41 43 44 47 50 51 52 55 58 60 61
#> [26] 62 65 67 69 70 72 73 82 84 85 86 87 88 95 96
```

- Visualize jackstraw results (three plot types available):

``` r
# P-value histogram
png("man/figures/README-jackstraw-pvalue-hist.png", width = 1600, height = 900, res = 150)
print(plot_jackstraw(js, type = "pvalue_hist", block = 1, component = 1))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-jackstraw-pvalue-hist.png")
```

<img src="man/figures/README-jackstraw-pvalue-hist.png" alt="" width="100%" />

``` r

# F-statistic vs -log10(p-value) scatter plot
png("man/figures/README-jackstraw-scatter.png", width = 1600, height = 900, res = 150)
print(plot_jackstraw(js, type = "scatter", block = 1, component = 1))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-jackstraw-scatter.png")
```

<img src="man/figures/README-jackstraw-scatter.png" alt="" width="100%" />

``` r

# Heatmap of -log10(p-value) across all joint components for one block
png("man/figures/README-jackstraw-loadings-significance.png", width = 1600, height = 900, res = 150)
print(plot_jackstraw(js, type = "loadings_significance", block = 1))
dev.off()
#> png 
#>   2
knitr::include_graphics("man/figures/README-jackstraw-loadings-significance.png")
```

<img src="man/figures/README-jackstraw-loadings-significance.png" alt="" width="100%" />

## Function reference

### Core decomposition

| Function | Description |
|----|----|
| `Rajive()` | Run the RaJIVE decomposition on a list of data matrices. Returns an object of class `"rajive"`. |
| `ajive.data.sim()` | Simulate multi-block data with known joint and individual structure for testing and benchmarking. |

### Rank accessors

| Function | Description |
|----|----|
| `get_joint_rank()` | Extract the estimated joint rank from a `"rajive"` object. |
| `get_individual_rank()` | Extract the individual rank for a specific data block. |
| `get_all_ranks()` | Return a `data.frame` of joint and individual ranks for all blocks at once. |

### Component accessors

| Function | Description |
|----|----|
| `get_joint_scores()` | Return the shared n x r_J joint score matrix (r_J = joint rank). |
| `get_block_scores()` | Return the score matrix (U) for a given block and component type (joint or individual). |
| `get_block_loadings()` | Return the loading matrix (V) for a given block and component type. |
| `get_block_matrix()` | Return the full reconstructed matrix (J, I, or E) for a given block and component type. |

### S3 methods for `"rajive"` objects

| Function | Description |
|----|----|
| `print.rajive()` | Print a concise summary of ranks for a `"rajive"` object. |
| `summary.rajive()` | Return and print a `data.frame` of all estimated ranks. |

### Variance explained

| Function | Description |
|----|----|
| `showVarExplained_robust()` | Compute the proportion of variance explained by joint, individual, and residual components for each block (returns a list). |
| `plot_variance_explained()` | Stacked bar chart of variance explained by each component and block. |

### Diagnostics and interpretation

| Function | Description |
|----|----|
| `extract_components()` | Extract AJIVE rank diagnostics in wide-list or long-data-frame format. |
| `plot_components()` | Unified AJIVE diagnostic plotting (`rank_threshold`, `bound_distributions`, `ajive_diagnostic`). |
| `associate_components()` | Test associations between estimated component scores and sample metadata. |
| `assess_stability()` | Bootstrap-based stability assessment for joint rank or loadings (with Procrustes alignment for loadings). |

### Visualisation

| Function | Description |
|----|----|
| `decomposition_heatmaps_robustH()` | Heatmaps of the raw data and the joint, individual, and noise components for all blocks. |
| `plot_scores()` | Scatter plot of two score components for a given block (joint or individual), with optional group colouring. |

### Jackstraw significance testing

| Function | Description |
|----|----|
| `jackstraw_rajive()` | Run the jackstraw permutation test to identify features significantly associated with estimated joint scores. Default multiple-testing correction is global BH across all tests. |
| `print.jackstraw_rajive()` | Print a significance table for a `"jackstraw_rajive"` object. |
| `summary.jackstraw_rajive()` | Return and print a `data.frame` summary of jackstraw results. |
| `get_significant_vars()` | Extract significant variable names/indices for a given block and component from jackstraw results. |
| `plot_jackstraw()` | Diagnostic plots for jackstraw results: p-value histogram, F-stat scatter plot, or loadings significance heatmap. |

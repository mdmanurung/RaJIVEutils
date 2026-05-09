# Tests for W-R1: perm bound augments rand_dir (both computed independently).

test_that("both perm and rand_dir samples are stored when both n_* are supplied", {
  skip_on_cran()

  set.seed(99)
  n   <- 40
  X1  <- matrix(rnorm(n * 8), n, 8)
  X2  <- matrix(rnorm(n * 7), n, 7)

  fit <- Rajive(
    list(X1, X2),
    initial_signal_ranks = c(3, 3),
    n_wedin_samples      = 50,
    n_rand_dir_samples   = 50,
    n_perm_samples       = 50,
    num_cores            = 1L
  )

  sel <- fit$joint_rank_sel
  expect_true(!is.null(sel[["rand_dir"]]),
              info = "rand_dir samples must be stored when n_rand_dir_samples > 0")
  expect_true(!is.null(sel[["perm"]]),
              info = "perm samples must be stored when n_perm_samples > 0")
  expect_length(sel[["rand_dir"]]$rand_dir_samples, 50)
  expect_length(sel[["perm"]]$perm_samples, 50)
})

test_that("perm-only run omits rand_dir entry", {
  skip_on_cran()

  set.seed(100)
  n  <- 40
  X1 <- matrix(rnorm(n * 8), n, 8)
  X2 <- matrix(rnorm(n * 7), n, 7)

  fit <- Rajive(
    list(X1, X2),
    initial_signal_ranks = c(3, 3),
    n_wedin_samples      = 50,
    n_rand_dir_samples   = NA,
    n_perm_samples       = 50,
    num_cores            = 1L
  )

  sel <- fit$joint_rank_sel
  expect_null(sel[["rand_dir"]])
  expect_true(!is.null(sel[["perm"]]))
})

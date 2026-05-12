test_that(".bootstrap_resample_indices handles observation bootstrap", {
  set.seed(1)
  idx <- rajiveplus:::.bootstrap_resample_indices(n = 10L, sample_frac = 0.6)

  expect_length(idx, 6L)
  expect_true(all(idx >= 1L & idx <= 10L))
})

test_that(".bootstrap_resample_indices handles whole-cluster bootstrap", {
  set.seed(2)
  cluster <- rep(letters[1:4], each = 3L)
  idx <- rajiveplus:::.bootstrap_resample_indices(
    n = length(cluster),
    sample_frac = 1,
    cluster = cluster,
    resample = "cluster"
  )

  counts <- table(cluster[idx])
  expect_true(all(as.integer(counts) %% 3L == 0L))
  expect_equal(length(idx), length(cluster))
})

test_that(".bootstrap_resample_indices respects cluster strata", {
  set.seed(3)
  cluster <- rep(letters[1:6], each = 2L)
  strata <- rep(c("case", "control"), each = 6L)
  idx <- rajiveplus:::.bootstrap_resample_indices(
    n = length(cluster),
    sample_frac = 1,
    cluster = cluster,
    strata = strata,
    resample = "cluster"
  )

  expect_equal(unname(table(strata[idx])), unname(table(strata)))
})

test_that(".rajive_bootstrap returns requested replicate payloads", {
  fx <- make_small_rajive_fixture()

  set.seed(4)
  reps <- rajiveplus:::.rajive_bootstrap(
    fx$fit, fx$blocks, fx$initial_signal_ranks,
    B = 2L,
    sample_frac = 0.75,
    keep = c("loadings", "scores", "joint_rank", "component_cors",
             "indices", "var_explained"),
    n_wedin_samples = NA,
    n_rand_dir_samples = NA,
    joint_rank = 1L
  )

  expect_named(reps, c("loadings", "scores", "joint_rank", "component_cors",
                       "indices", "var_explained"))
  expect_length(reps$loadings, 2L)
  expect_equal(dim(reps$loadings[[1L]]), c(8L, 1L, 2L))
  expect_equal(dim(reps$scores), c(12L, 1L, 2L))
  expect_length(reps$joint_rank, 2L)
  expect_equal(dim(reps$component_cors), c(2L, 1L))
  expect_length(reps$indices, 2L)
  expect_equal(dim(reps$var_explained), c(2L, 1L, 2L))
})

test_that(".rajive_bootstrap is deterministic under set.seed", {
  fx <- make_small_rajive_fixture()

  set.seed(5)
  a <- rajiveplus:::.rajive_bootstrap(
    fx$fit, fx$blocks, fx$initial_signal_ranks,
    B = 2L,
    keep = c("joint_rank", "indices"),
    n_wedin_samples = NA,
    n_rand_dir_samples = NA,
    joint_rank = 1L
  )
  set.seed(5)
  b <- rajiveplus:::.rajive_bootstrap(
    fx$fit, fx$blocks, fx$initial_signal_ranks,
    B = 2L,
    keep = c("joint_rank", "indices"),
    n_wedin_samples = NA,
    n_rand_dir_samples = NA,
    joint_rank = 1L
  )

  expect_equal(a, b)
})

test_that("assess_stability joint_rank works without fitted reference components", {
  fx <- make_small_rajive_fixture()

  set.seed(51)
  out <- assess_stability(
    blocks = fx$blocks,
    initial_signal_ranks = fx$initial_signal_ranks,
    target = "joint_rank",
    B = 2L,
    n_wedin_samples = NA,
    n_rand_dir_samples = NA,
    joint_rank = 1L
  )

  expect_length(out$rank_distribution, 2L)
  expect_true(inherits(out$rank_table, "table"))
  expect_true(is.na(out$observed_rank))
})

test_that("assess_stability can attach bootstrap replicates", {
  fx <- make_small_rajive_fixture()

  set.seed(6)
  out <- assess_stability(
    fx$fit, fx$blocks, fx$initial_signal_ranks,
    target = "components",
    B = 2L,
    return_replicates = TRUE,
    n_wedin_samples = NA,
    n_rand_dir_samples = NA,
    joint_rank = 1L
  )

  reps <- attr(out, "replicates")
  expect_true(is.data.frame(out))
  expect_true(is.list(reps))
  expect_equal(dim(reps$scores), c(12L, 1L, 2L))
})

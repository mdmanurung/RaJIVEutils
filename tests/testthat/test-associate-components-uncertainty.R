test_that("associate_components default output keeps legacy columns", {
  set.seed(21)
  scores <- matrix(rnorm(30), ncol = 1)
  fit <- structure(list(joint_scores = scores, joint_rank = 1L), class = "rajive")
  metadata <- data.frame(marker = rnorm(30))

  out <- suppressMessages(
    associate_components(fit, metadata, variable = "marker",
                         mode = "continuous")
  )

  expect_named(out, c("variable", "component", "stat", "p_value",
                      "p_adj", "method"))
})

test_that("associate_components bootstrap propagation adds uncertainty columns", {
  set.seed(22)
  n <- 30L
  B <- 6L
  score <- rnorm(n)
  metadata <- data.frame(marker = score + rnorm(n, sd = 0.05))
  fit <- structure(list(joint_scores = matrix(score, ncol = 1),
                        joint_rank = 1L),
                   class = "rajive")
  reps <- list(scores = array(rep(score, B), dim = c(n, 1L, B)))
  for (b in seq_len(B)) {
    reps$scores[, 1L, b] <- score + rnorm(n, sd = 0.02)
  }

  out <- suppressMessages(
    associate_components(
      fit, metadata, variable = "marker",
      mode = "continuous",
      propagate_uncertainty = "bootstrap",
      alpha_stability = 0.05,
      replicates = reps
    )
  )

  expect_true(all(c("stability", "effect_lo", "effect_hi", "p_median",
                    "p_adj_median") %in% names(out)))
  expect_gte(out$stability, 0.9)
  expect_gt(out$effect_lo, 0)
  expect_lt(out$p_median, 0.05)
})

test_that("associate_components bootstrap propagation can build replicates", {
  fx <- make_small_rajive_fixture(seed = 23L)
  score <- fx$fit$joint_scores[, 1L]
  metadata <- data.frame(marker = score + rnorm(length(score), sd = 0.05))

  set.seed(24)
  out <- suppressMessages(
    associate_components(
      fx$fit, metadata, variable = "marker",
      mode = "continuous",
      propagate_uncertainty = "bootstrap",
      blocks = fx$blocks,
      initial_signal_ranks = fx$initial_signal_ranks,
      B = 2L,
      n_wedin_samples = NA,
      n_rand_dir_samples = NA,
      joint_rank = 1L
    )
  )

  expect_true(all(c("stability", "effect_lo", "effect_hi", "p_median",
                    "p_adj_median") %in% names(out)))
  expect_equal(nrow(out), 1L)
})

# Smoke tests for clustered fixtures used by cluster-bootstrap calibration.
#
# These tests are FAST (no MC) and verify only that the fixtures construct
# blocks of the right shape and induce non-trivial within-cluster correlation.
# The full naive-vs-cluster bootstrap calibration test ships alongside the
# bootstrap engine refactor (R0.2 in the v0.2.0 roadmap).

# ---------------------------------------------------------------------------
# null_blocks_clustered: shape and cluster assignment
# ---------------------------------------------------------------------------

test_that("null_blocks_clustered returns blocks and cluster of correct shape", {
  out <- null_blocks_clustered(K = 3, n_clusters = 10, obs_per_cluster = 4,
                               pks = c(20L, 15L, 10L), seed = 1L)
  expect_named(out, c("blocks", "cluster"))
  expect_length(out$blocks, 3L)
  expect_named(out$blocks, c("block1", "block2", "block3"))
  expect_equal(vapply(out$blocks, nrow, integer(1)), c(block1 = 40L,
                                                       block2 = 40L,
                                                       block3 = 40L))
  expect_equal(vapply(out$blocks, ncol, integer(1)), c(block1 = 20L,
                                                       block2 = 15L,
                                                       block3 = 10L))
  expect_length(out$cluster, 40L)
  # Each cluster represented exactly obs_per_cluster times.
  expect_equal(as.integer(table(out$cluster)), rep(4L, 10L))
})

test_that("null_blocks_clustered supports unbalanced obs_per_cluster", {
  out <- null_blocks_clustered(K = 1, n_clusters = 3,
                               obs_per_cluster = c(5L, 2L, 7L),
                               pks = 6L, seed = 2L)
  expect_length(out$cluster, 14L)
  expect_equal(as.integer(table(out$cluster)), c(5L, 2L, 7L))
  expect_equal(nrow(out$blocks[[1L]]), 14L)
})

# ---------------------------------------------------------------------------
# null_blocks_clustered: cluster effect produces non-trivial within-cluster cor
# ---------------------------------------------------------------------------

test_that("null_blocks_clustered induces positive within-cluster correlation", {
  # With cluster_sd >> 0, rows of the same cluster should share an offset that
  # makes them positively correlated (averaged over many cluster/feature pairs).
  out <- null_blocks_clustered(K = 1, n_clusters = 20, obs_per_cluster = 5,
                               pks = 50L, cluster_sd = 1.5, seed = 3L)
  X <- out$blocks[[1L]]
  cl <- out$cluster

  # Within-cluster average pair correlation across rows
  within_cors <- vapply(unique(cl), function(c_id) {
    idx <- which(cl == c_id)
    if (length(idx) < 2L) return(NA_real_)
    rows <- X[idx, , drop = FALSE]
    # mean off-diagonal element of cor(t(rows))
    M <- stats::cor(t(rows))
    mean(M[upper.tri(M)])
  }, numeric(1))
  expect_gt(mean(within_cors, na.rm = TRUE), 0.30)
})

test_that("null_blocks_clustered with cluster_sd = 0 mimics null_blocks", {
  # With no cluster effect, within-cluster correlation should average ~0.
  out <- null_blocks_clustered(K = 1, n_clusters = 20, obs_per_cluster = 5,
                               pks = 50L, cluster_sd = 0, seed = 4L)
  X <- out$blocks[[1L]]
  cl <- out$cluster
  within_cors <- vapply(unique(cl), function(c_id) {
    idx <- which(cl == c_id)
    rows <- X[idx, , drop = FALSE]
    M <- stats::cor(t(rows))
    mean(M[upper.tri(M)])
  }, numeric(1))
  expect_lt(abs(mean(within_cors, na.rm = TRUE)), 0.15)
})

# ---------------------------------------------------------------------------
# signal_blocks_clustered: shape and cluster assignment
# ---------------------------------------------------------------------------

test_that("signal_blocks_clustered returns blocks and cluster of correct shape", {
  out <- signal_blocks_clustered(K = 2, n_clusters = 12, obs_per_cluster = 3,
                                 pks = c(30L, 20L),
                                 rankJ = 2L, rankA = c(3L, 2L), seed = 5L)
  expect_named(out, c("blocks", "cluster"))
  expect_length(out$blocks, 2L)
  expect_equal(vapply(out$blocks, nrow, integer(1)), c(block1 = 36L,
                                                       block2 = 36L))
  expect_equal(vapply(out$blocks, ncol, integer(1)), c(block1 = 30L,
                                                       block2 = 20L))
  expect_length(out$cluster, 36L)
  expect_equal(as.integer(table(out$cluster)), rep(3L, 12L))
})

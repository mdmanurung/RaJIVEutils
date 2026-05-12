.wedin_sample_project_R_draws <- function(X, signal_basis, right_vectors, draws) {
  signal_basis <- qr.Q(qr(signal_basis))
  vapply(seq_len(dim(draws)[3L]), function(s) {
    raw <- draws[, , s, drop = TRUE]
    projected <- raw - signal_basis %*% (t(signal_basis) %*% raw)
    q <- qr.Q(qr(projected))
    projection <- if (right_vectors) {
      X %*% q
    } else {
      t(q) %*% X
    }
    norm(projection, type = "2")
  }, numeric(1L))
}

.random_direction_bound_R_draws <- function(n_obs, dims, draws_by_block) {
  vapply(seq_len(dim(draws_by_block[[1L]])[3L]), function(s) {
    rand_subspaces <- lapply(draws_by_block, function(x) {
      svd(x[, , s, drop = TRUE])[["u"]]
    })
    M <- do.call(cbind, rand_subspaces)
    svd(M, nu = 0L, nv = 0L)[["d"]][1L]^2
  }, numeric(1L))
}

test_that("wedin_bound_resampling_cpp_draws matches sample-project U reference", {
  set.seed(9201)
  X <- matrix(rnorm(20 * 12), 20, 12)
  signal_basis <- qr.Q(qr(matrix(rnorm(20 * 3), 20, 3)))
  draws <- array(rnorm(20 * 3 * 4), dim = c(20L, 3L, 4L))

  ref <- .wedin_sample_project_R_draws(
    X = X,
    signal_basis = signal_basis,
    right_vectors = FALSE,
    draws = draws
  )
  got <- rajiveplus:::wedin_bound_resampling_cpp_draws(
    X = X,
    signal_basis = signal_basis,
    right_vectors = FALSE,
    draws = draws
  )

  expect_equal(as.numeric(got), ref, tolerance = 1e-10)
})

test_that("wedin_bound_resampling_cpp_draws matches sample-project V reference", {
  set.seed(9202)
  X <- matrix(rnorm(20 * 12), 20, 12)
  signal_basis <- qr.Q(qr(matrix(rnorm(12 * 3), 12, 3)))
  draws <- array(rnorm(12 * 3 * 4), dim = c(12L, 3L, 4L))

  ref <- .wedin_sample_project_R_draws(
    X = X,
    signal_basis = signal_basis,
    right_vectors = TRUE,
    draws = draws
  )
  got <- rajiveplus:::wedin_bound_resampling_cpp_draws(
    X = X,
    signal_basis = signal_basis,
    right_vectors = TRUE,
    draws = draws
  )

  expect_equal(as.numeric(got), ref, tolerance = 1e-10)
})

test_that("get_wedin_bound_samples matches sample-project scale under fixed draws", {
  set.seed(9204)
  X <- matrix(rnorm(18 * 11), 18, 11)
  SVD <- svd(X, nu = 4L, nv = 4L)
  signal_rank <- 3L
  num_samples <- 5L

  set.seed(9205)
  got <- rajiveplus:::get_wedin_bound_samples(
    X = X,
    SVD = SVD,
    signal_rank = signal_rank,
    num_samples = num_samples,
    num_cores = 1L
  )

  set.seed(9205)
  u_draws <- array(rnorm(nrow(SVD$u) * signal_rank * num_samples),
                   dim = c(nrow(SVD$u), signal_rank, num_samples))
  v_draws <- array(rnorm(nrow(SVD$v) * signal_rank * num_samples),
                   dim = c(nrow(SVD$v), signal_rank, num_samples))
  u_norms <- .wedin_sample_project_R_draws(
    X = X,
    signal_basis = SVD$u[, seq_len(signal_rank), drop = FALSE],
    right_vectors = FALSE,
    draws = u_draws
  )
  v_norms <- .wedin_sample_project_R_draws(
    X = X,
    signal_basis = SVD$v[, seq_len(signal_rank), drop = FALSE],
    right_vectors = TRUE,
    draws = v_draws
  )
  expected <- pmin(pmax(u_norms, v_norms) / SVD$d[[signal_rank]], 1)^2

  expect_equal(got, expected, tolerance = 1e-10)
  expect_true(all(is.finite(got)))
  expect_true(any(got > 0))
})

test_that("random_direction_bound_cpp_draws matches R reference", {
  set.seed(9203)
  n_obs <- 16L
  dims <- c(3L, 4L, 2L)
  draws_by_block <- lapply(dims, function(p) {
    array(rnorm(n_obs * p * 5L), dim = c(n_obs, p, 5L))
  })

  ref <- .random_direction_bound_R_draws(n_obs, dims, draws_by_block)
  got <- rajiveplus:::random_direction_bound_cpp_draws(
    n_obs = n_obs,
    dims = dims,
    draws_by_block = draws_by_block
  )

  expect_equal(as.numeric(got), ref, tolerance = 1e-10)
})

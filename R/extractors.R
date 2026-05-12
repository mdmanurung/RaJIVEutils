# Internal matrix extractors shared by inference helpers.

.default_block_names <- function(blocks, K = NULL) {
  if (!is.null(blocks) && !is.null(names(blocks)) && all(nzchar(names(blocks)))) {
    return(names(blocks))
  }
  if (is.null(K)) K <- length(blocks)
  paste0("block", seq_len(K))
}

.validate_feature_space <- function(mats) {
  if (!is.list(mats) || length(mats) == 0L) {
    cli::cli_abort("`blocks` must be a non-empty list of numeric matrices.")
  }
  bad_matrix <- !vapply(mats, is.matrix, logical(1L))
  if (any(bad_matrix)) {
    cli::cli_abort("Every block must be a matrix.")
  }
  bad_numeric <- !vapply(mats, is.numeric, logical(1L))
  if (any(bad_numeric)) {
    cli::cli_abort("Every block must be numeric.")
  }
  bad_dim <- vapply(mats, function(x) any(dim(x) == 0L), logical(1L))
  if (any(bad_dim)) {
    cli::cli_abort("Every block must have at least one sample and one feature.")
  }
  bad_finite <- !vapply(mats, function(x) all(is.finite(x)), logical(1L))
  if (any(bad_finite)) {
    cli::cli_abort("Every block must contain only finite values.")
  }
  invisible(mats)
}

.validate_matched_samples <- function(mats) {
  n <- vapply(mats, nrow, integer(1L))
  if (length(unique(n)) != 1L) {
    cli::cli_abort("All blocks must have the same number of samples.")
  }

  rn <- lapply(mats, rownames)
  has_rn <- vapply(rn, function(x) !is.null(x), logical(1L))
  if (all(has_rn)) {
    ref <- rn[[1L]]
    bad <- vapply(rn[-1L], function(x) !identical(ref, x), logical(1L))
    if (any(bad)) {
      cli::cli_abort("All blocks must have identical sample row names.")
    }
  }
  invisible(mats)
}

.dim_label <- function(x) {
  paste(dim(x), collapse = " x ")
}

.validate_component_dims <- function(mats, blocks, component, block_names) {
  if (is.null(blocks)) {
    return(invisible(mats))
  }

  bad <- which(!mapply(function(x, y) identical(dim(x), dim(y)), mats, blocks))
  if (length(bad) > 0L) {
    k <- bad[[1L]]
    block_label <- block_names[[k]]
    block_dim <- .dim_label(blocks[[k]])
    component_dim <- .dim_label(mats[[k]])
    cli::cli_abort(c(
      "Extracted {.val {component}} matrix dimensions do not match `blocks`.",
      "i" = "Block {.val {block_label}}: `blocks` has dimensions {block_dim}, but the fitted component has dimensions {component_dim}.",
      "i" = "This usually means the fitted object was created from different or stale input blocks."
    ))
  }

  invisible(mats)
}

.reconstruct_decomp_matrix <- function(decomp) {
  full <- decomp[["full"]]
  if (is.matrix(full) && length(full) > 1L && !all(is.na(full))) {
    return(full)
  }

  u <- decomp[["u"]]
  d <- decomp[["d"]]
  v <- decomp[["v"]]
  if (!is.matrix(u) || !is.matrix(v) || is.null(d)) {
    cli::cli_abort("Component decomposition must contain `u`, `d`, and `v`.")
  }
  if (length(d) == 0L || ncol(u) == 0L || ncol(v) == 0L) {
    return(matrix(0, nrow = nrow(u), ncol = nrow(v)))
  }
  u %*% (diag(d, nrow = length(d), ncol = length(d)) %*% t(v))
}

.extract_one_component <- function(ajive_output, k, component) {
  idx <- switch(component,
                joint = 3L * (k - 1L) + 2L,
                individual = 3L * (k - 1L) + 1L,
                cli::cli_abort("Unsupported component {.val {component}}."))
  .reconstruct_decomp_matrix(ajive_output$block_decomps[[idx]])
}

.extract_block_matrices <- function(ajive_output,
                                    blocks = NULL,
                                    component = c("data", "joint",
                                                  "individual", "residual")) {
  component <- match.arg(component)

  if (!is.null(blocks)) {
    .validate_feature_space(blocks)
    .validate_matched_samples(blocks)
  }

  if (component == "data") {
    if (is.null(blocks)) {
      cli::cli_abort("`blocks` must be supplied when `component = 'data'`.")
    }
    names(blocks) <- .default_block_names(blocks)
    return(blocks)
  }

  if (is.null(ajive_output$block_decomps)) {
    cli::cli_abort("`ajive_output` must contain `block_decomps`.")
  }

  K <- length(ajive_output$block_decomps) / 3L
  if (K != as.integer(K) || K < 1L) {
    cli::cli_abort("`ajive_output$block_decomps` must contain 3 entries per block.")
  }
  K <- as.integer(K)
  if (!is.null(blocks) && length(blocks) != K) {
    cli::cli_abort("`blocks` must contain the same number of blocks as `ajive_output`.")
  }
  block_names <- .default_block_names(blocks, K)

  if (component %in% c("joint", "individual")) {
    out <- lapply(seq_len(K), function(k) .extract_one_component(ajive_output, k, component))
    names(out) <- block_names
    .validate_component_dims(out, blocks, component, block_names)
    return(out)
  }

  if (is.null(blocks)) {
    cli::cli_abort("`blocks` must be supplied when `component = 'residual'`.")
  }
  joint <- .extract_block_matrices(ajive_output, blocks, "joint")
  indiv <- .extract_block_matrices(ajive_output, blocks, "individual")
  out <- lapply(seq_len(K), function(k) blocks[[k]] - joint[[k]] - indiv[[k]])
  names(out) <- block_names
  out
}

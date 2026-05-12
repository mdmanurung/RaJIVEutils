# Internal bootstrap engine for RaJIVE inference helpers.

.bootstrap_resample_indices <- function(n, sample_frac = 0.8,
                                        cluster = NULL,
                                        strata = NULL,
                                        resample = NULL) {
  if (!is.numeric(n) || length(n) != 1L || n < 2L) {
    cli::cli_abort("`n` must be a sample count of at least 2.")
  }
  n <- as.integer(n)
  if (!is.numeric(sample_frac) || length(sample_frac) != 1L ||
      !is.finite(sample_frac) || sample_frac <= 0 || sample_frac > 1) {
    cli::cli_abort("`sample_frac` must be in (0, 1].")
  }

  if (is.null(resample)) {
    resample <- if (is.null(cluster)) "observation" else "cluster"
  }
  resample <- match.arg(resample, c("observation", "cluster"))

  if (resample == "observation") {
    size <- max(2L, floor(sample_frac * n))
    return(sample.int(n, size = size, replace = TRUE))
  }

  if (is.null(cluster)) {
    cli::cli_abort("`cluster` must be supplied when `resample = 'cluster'`.")
  }
  if (length(cluster) != n) {
    cli::cli_abort("`cluster` must have one value per sample.")
  }
  if (!is.null(strata) && length(strata) != n) {
    cli::cli_abort("`strata` must have one value per sample.")
  }

  cluster_f <- factor(cluster)
  row_by_cluster <- split(seq_len(n), cluster_f)

  if (is.null(strata)) {
    cluster_groups <- list(all = names(row_by_cluster))
  } else {
    strata_f <- factor(strata)
    cluster_strata <- vapply(row_by_cluster, function(idx) {
      vals <- unique(as.character(strata_f[idx]))
      if (length(vals) != 1L) {
        cli::cli_abort("Each cluster must belong to exactly one stratum.")
      }
      vals
    }, character(1L))
    cluster_groups <- split(names(cluster_strata), cluster_strata)
  }

  sampled <- unlist(lapply(cluster_groups, function(ids) {
    size <- max(1L, floor(sample_frac * length(ids)))
    draw <- sample(ids, size = size, replace = TRUE)
    unlist(row_by_cluster[draw], use.names = FALSE)
  }), use.names = FALSE)

  as.integer(sampled)
}

.scatter_scores_to_reference_rows <- function(scores, idx, n_ref) {
  out <- matrix(NA_real_, nrow = n_ref, ncol = ncol(scores))
  for (i in unique(idx)) {
    pos <- which(idx == i)
    out[i, ] <- colMeans(scores[pos, , drop = FALSE])
  }
  out
}

.component_var_explained <- function(fit, blocks, n_comp) {
  K <- length(blocks)
  out <- matrix(NA_real_, nrow = K, ncol = n_comp)
  for (k in seq_len(K)) {
    decomp <- fit$block_decomps[[3L * (k - 1L) + 2L]]
    d <- decomp[["d"]]
    if (length(d) == 0L) next
    n_use <- min(length(d), n_comp)
    denom <- norm(blocks[[k]], type = "F")^2
    out[k, seq_len(n_use)] <- d[seq_len(n_use)]^2 / denom
  }
  out
}

.rajive_bootstrap <- function(ajive_output, blocks, initial_signal_ranks,
                              B = 100L,
                              sample_frac = 0.8,
                              cluster = NULL,
                              strata = NULL,
                              resample = NULL,
                              align_to = c("reference", "first_replicate", "none"),
                              num_cores = 1L,
                              keep = c("loadings", "scores", "joint_rank",
                                       "component_cors", "indices",
                                       "var_explained"),
                              ...) {
  align_to <- match.arg(align_to)
  keep <- match.arg(keep, c("loadings", "scores", "joint_rank",
                            "component_cors", "indices", "var_explained"),
                    several.ok = TRUE)

  .validate_feature_space(blocks)
  .validate_matched_samples(blocks)
  if (length(initial_signal_ranks) != length(blocks)) {
    cli::cli_abort("`initial_signal_ranks` must have one entry per block.")
  }
  B <- as.integer(B)
  if (B < 1L) {
    cli::cli_abort("`B` must be a positive integer.")
  }

  K <- length(blocks)
  n_ref <- nrow(blocks[[1L]])
  needs_reference <- any(keep %in% c("loadings", "scores", "component_cors",
                                     "var_explained"))
  n_comp <- 0L
  if (needs_reference) {
    if (is.null(ajive_output) || !inherits(ajive_output, "rajive")) {
      cli::cli_abort("`ajive_output` must be a fitted rajive object for the requested bootstrap payload.")
    }
    n_comp <- if (!is.null(ajive_output$joint_scores)) {
      ncol(ajive_output$joint_scores)
    } else {
      as.integer(ajive_output$joint_rank)
    }
    if (is.null(n_comp) || is.na(n_comp) || n_comp < 1L) {
      cli::cli_abort("`ajive_output` must contain at least one joint component.")
    }
  }

  ref_scores <- if (!is.null(ajive_output)) ajive_output$joint_scores else NULL
  ref_loadings <- NULL
  if ("loadings" %in% keep && !is.null(ajive_output$block_decomps)) {
    ref_loadings <- lapply(seq_len(K), function(k) {
      ajive_output$block_decomps[[3L * (k - 1L) + 2L]]$v
    })
  }

  out <- list()
  if ("loadings" %in% keep) {
    out$loadings <- lapply(seq_len(K), function(k) {
      array(NA_real_, dim = c(ncol(blocks[[k]]), n_comp, B))
    })
    names(out$loadings) <- .default_block_names(blocks)
  }
  if ("scores" %in% keep) {
    out$scores <- array(NA_real_, dim = c(n_ref, n_comp, B))
  }
  if ("joint_rank" %in% keep) out$joint_rank <- rep(NA_integer_, B)
  if ("component_cors" %in% keep) {
    out$component_cors <- matrix(NA_real_, nrow = B, ncol = n_comp)
  }
  if ("indices" %in% keep) out$indices <- vector("list", B)
  if ("var_explained" %in% keep) {
    out$var_explained <- array(NA_real_, dim = c(K, n_comp, B))
  }

  dots <- list(...)
  for (b in seq_len(B)) {
    idx <- .bootstrap_resample_indices(
      n = n_ref,
      sample_frac = sample_frac,
      cluster = cluster,
      strata = strata,
      resample = resample
    )
    b_list <- lapply(blocks, function(x) x[idx, , drop = FALSE])
    fit_b <- tryCatch(
      do.call(Rajive, c(list(b_list, initial_signal_ranks),
                        dots)),
      error = function(e) NULL
    )

    if ("indices" %in% keep) out$indices[[b]] <- idx
    if (is.null(fit_b)) next
    if ("joint_rank" %in% keep) out$joint_rank[[b]] <- fit_b$joint_rank

    bs <- fit_b$joint_scores
    if (any(keep %in% c("scores", "component_cors")) &&
        !is.null(bs) && ncol(bs) > 0L && !is.null(ref_scores)) {
      n_use <- min(ncol(bs), n_comp)
      bs_sub <- bs[, seq_len(n_use), drop = FALSE]
      if (align_to == "reference") {
        Q <- .procrustes_align(ref_scores[idx, seq_len(n_use), drop = FALSE], bs_sub)
        bs_sub <- bs_sub %*% Q
      }
      if ("scores" %in% keep) {
        out$scores[, seq_len(n_use), b] <-
          .scatter_scores_to_reference_rows(bs_sub, idx, n_ref)
      }
      if ("component_cors" %in% keep) {
        for (j in seq_len(n_use)) {
          out$component_cors[b, j] <- suppressWarnings(abs(stats::cor(
            ref_scores[idx, j], bs_sub[, j],
            use = "pairwise.complete.obs"
          )))
        }
      }
    }

    if ("loadings" %in% keep && !is.null(fit_b$block_decomps) &&
        !is.null(ref_loadings)) {
      for (k in seq_len(K)) {
        L_b <- fit_b$block_decomps[[3L * (k - 1L) + 2L]]$v
        if (is.null(L_b) || ncol(L_b) == 0L) next
        n_use <- min(ncol(L_b), n_comp)
        L_sub <- L_b[, seq_len(n_use), drop = FALSE]
        if (align_to == "reference") {
          Q <- .procrustes_align(ref_loadings[[k]][, seq_len(n_use), drop = FALSE], L_sub)
          L_sub <- L_sub %*% Q
        }
        out$loadings[[k]][, seq_len(n_use), b] <- L_sub
      }
    }

    if ("var_explained" %in% keep && !is.null(fit_b$block_decomps)) {
      out$var_explained[, , b] <- .component_var_explained(fit_b, b_list, n_comp)
    }
  }

  out[keep]
}

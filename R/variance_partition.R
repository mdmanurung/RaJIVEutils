#' Feature-level joint, individual, and residual variance partition
#'
#' Computes a per-feature sum-of-squares decomposition for each block from a
#' fitted \code{\link{Rajive}} object and the original data blocks used for
#' fitting.
#'
#' @param ajive_output An object returned by \code{\link{Rajive}}.
#' @param blocks List of original block matrices, with samples in rows and
#'   features in columns.
#' @param eps Numeric tolerance used to identify zero component totals.
#'
#' @return A data frame with one row per feature and columns:
#'   \code{feature}, \code{block}, \code{joint_ss}, \code{individual_ss},
#'   \code{residual_ss}, \code{component_total_ss}, \code{data_total_ss},
#'   \code{joint_prop}, \code{individual_prop}, \code{residual_prop}, and
#'   \code{reconstruction_error}.
#'
#' @export
joint_variance_partition <- function(ajive_output, blocks, eps = 1e-12) {
  if (!inherits(ajive_output, "rajive")) {
    cli::cli_abort("`ajive_output` must be an object of class {.val rajive}.")
  }
  if (!is.numeric(eps) || length(eps) != 1L || !is.finite(eps) || eps < 0) {
    cli::cli_abort("`eps` must be a non-negative finite numeric scalar.")
  }

  data <- .extract_block_matrices(ajive_output, blocks, "data")
  joint <- .extract_block_matrices(ajive_output, blocks, "joint")
  indiv <- .extract_block_matrices(ajive_output, blocks, "individual")
  resid <- .extract_block_matrices(ajive_output, blocks, "residual")

  block_names <- .default_block_names(data)
  out <- lapply(seq_along(data), function(k) {
    X <- data[[k]]
    J <- joint[[k]]
    I <- indiv[[k]]
    E <- resid[[k]]

    if (!identical(dim(X), dim(J)) || !identical(dim(X), dim(I)) ||
        !identical(dim(X), dim(E))) {
      cli::cli_abort("Extracted component matrices must match the dimensions of `blocks`.")
    }

    joint_ss <- colSums(J^2)
    indiv_ss <- colSums(I^2)
    resid_ss <- colSums(E^2)
    component_total_ss <- joint_ss + indiv_ss + resid_ss
    data_total_ss <- colSums(X^2)

    denom <- ifelse(component_total_ss > eps, component_total_ss, NA_real_)
    joint_prop <- joint_ss / denom
    indiv_prop <- indiv_ss / denom
    resid_prop <- resid_ss / denom

    zero <- is.na(denom)
    joint_prop[zero] <- 0
    indiv_prop[zero] <- 0
    resid_prop[zero] <- 0

    feature <- colnames(X)
    if (is.null(feature)) {
      feature <- paste0("feature", seq_len(ncol(X)))
    }

    data.frame(
      feature = feature,
      block = block_names[[k]],
      joint_ss = joint_ss,
      individual_ss = indiv_ss,
      residual_ss = resid_ss,
      component_total_ss = component_total_ss,
      data_total_ss = data_total_ss,
      joint_prop = joint_prop,
      individual_prop = indiv_prop,
      residual_prop = resid_prop,
      reconstruction_error = abs(data_total_ss - component_total_ss),
      row.names = NULL,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, out)
}

# PCA and variance threshold calculation

run_pca <- function(feature_df, center = TRUE, scale. = TRUE) {
  if (ncol(feature_df) < 2) {
    stop("Need at least two descriptor columns to run PCA")
  }

  pca <- stats::prcomp(feature_df, center = center, scale. = scale.)
  pca
}

determine_n_pcs <- function(pca_obj, variance_threshold = 0.90) {
  cumvar <- cumsum(pca_obj$sdev^2) / sum(pca_obj$sdev^2)
  n_pcs <- which(cumvar >= variance_threshold)[1]

  if (is.na(n_pcs)) {
    n_pcs <- length(pca_obj$sdev)
  }

  n_pcs
}

pca_scores <- function(pca_obj, n_pcs) {
  pca_obj$x[, 1:n_pcs, drop = FALSE]
}

pca_loadings <- function(pca_obj, digits = 3) {
  round(pca_obj$rotation, digits)
}

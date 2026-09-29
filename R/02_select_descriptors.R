# Build the PCA feature matrix and manage descriptor selection

select_descriptor_columns <- function(metrics, descriptors, id_column = "Label") {
  if (!(id_column %in% names(metrics))) {
    stop("id_column '", id_column, "' not found in metrics")
  }

  missing <- descriptors[!(descriptors %in% names(metrics))]
  if (length(missing) > 0) {
    stop("Descriptor columns not found in metrics: ", paste(missing, collapse = ", "))
  }

  metrics %>%
    dplyr::select(dplyr::all_of(id_column), dplyr::all_of(descriptors))
}

make_feature_matrix <- function(metrics, descriptors, id_column = "Label") {
  feature_df <- select_descriptor_columns(metrics, descriptors, id_column = id_column)
  rownames(feature_df) <- feature_df[[id_column]]
  feature_df <- feature_df %>% dplyr::select(-dplyr::all_of(id_column))

  feature_df
}

# Export results and report generation

export_selection_results <- function(metrics, selected_ids, output_dir, id_column = "Label", descriptors = NULL, counts = NULL) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  selected_metrics <- metrics %>%
    dplyr::filter(.data[[id_column]] %in% selected_ids)

  write.csv(selected_metrics, file.path(output_dir, "selected_samples.csv"), row.names = FALSE)

  selection_summary <- metrics %>%
    dplyr::mutate(Selected = .data[[id_column]] %in% selected_ids) %>%
    dplyr::summarise(
      n_total = dplyr::n(),
      n_selected = sum(Selected),
      selection_fraction = mean(Selected),
      .groups = "drop"
    )

  write.csv(selection_summary, file.path(output_dir, "selection_summary.csv"), row.names = FALSE)

  if (!is.null(counts)) {
    selected_counts <- counts %>%
      dplyr::filter(Batch %in% selected_ids)
    write.csv(selected_counts, file.path(output_dir, "selected_germination_curves.csv"), row.names = FALSE)
  }

  invisible(selected_metrics)
}

write_pca_summary <- function(pca_obj, n_pcs, output_file) {
  cumvar <- cumsum(pca_obj$sdev^2) / sum(pca_obj$sdev^2)
  summary_df <- data.frame(
    PC = paste0("PC", seq_along(pca_obj$sdev)),
    StdDev = pca_obj$sdev,
    ProportionVariance = pca_obj$sdev^2 / sum(pca_obj$sdev^2),
    CumulativeVariance = cumvar
  )

  write.csv(summary_df, output_file, row.names = FALSE)
  summary_df
}

selection_report <- function(metrics, selected_ids, pca_obj, n_pcs, descriptors, output_file) {
  report <- list(
    n_total = nrow(metrics),
    n_selected = length(selected_ids),
    selected_ids = selected_ids,
    descriptors = descriptors,
    n_pcs = n_pcs,
    cumulative_variance = cumsum(pca_obj$sdev^2) / sum(pca_obj$sdev^2),
    explained_var = sum(pca_obj$sdev[1:n_pcs]^2) / sum(pca_obj$sdev^2)
  )

  capture.output(print(report), file = output_file)
  report
}

# Main orchestration function for the generalized pipeline

run_germination_selection <- function(config_file, output_dir = NULL) {
  check_required_packages()

  config <- validate_config(read_config(config_file))
  output_dir <- create_output_dir(output_dir)

  metrics <- load_metrics(config$data$metrics_file, id_column = config$data$id_column)
  counts <- load_counts(config$data$counts_file, id_column = config$data$count_id_column)

  features <- make_feature_matrix(
    metrics = metrics,
    descriptors = config$descriptors,
    id_column = config$data$id_column
  )

  pca_obj <- run_pca(features, center = config$pca$center, scale. = config$pca$scale)
  n_pcs <- determine_n_pcs(pca_obj, variance_threshold = config$pca$variance_threshold)
  scores <- pca_scores(pca_obj, n_pcs)

  ks <- select_kennard_stone(
    scores = scores,
    n_select = config$kennard_stone$n_samples,
    metric = config$kennard_stone$metric,
    id_vector = metrics[[config$data$id_column]]
  )

  selected_ids <- ks$selected_ids
  selected_index <- ks$model

  if (config$plots$pca_plot) {
    pca_plot_file <- file.path(output_dir, "pca_selection.png")
    plot_pca_selection(
      pca_obj = pca_obj,
      selected_index = selected_index,
      id_vector = metrics[[config$data$id_column]],
      output_file = pca_plot_file,
      save_png = config$plots$save_png,
      dpi = config$plots$dpi
    )
  }

  if (config$plots$density_plots) {
    density_file <- file.path(output_dir, "density_selection.png")
    density_selection_plot(
      metrics = metrics,
      descriptors = config$descriptors,
      id_column = config$data$id_column,
      selected_ids = selected_ids,
      output_file = density_file,
      save_png = config$plots$save_png,
      dpi = config$plots$dpi
    )
  }

  if (config$plots$germination_curves) {
    curve_file <- file.path(output_dir, "germination_curves.png")
    plot_germination_curves(
      counts = counts,
      selected_ids = selected_ids,
      output_file = curve_file,
      save_png = config$plots$save_png,
      dpi = config$plots$dpi
    )
  }

  write_pca_summary(
    pca_obj = pca_obj,
    n_pcs = n_pcs,
    output_file = file.path(output_dir, "pca_summary.csv")
  )

  selection_report(
    metrics = metrics,
    selected_ids = selected_ids,
    pca_obj = pca_obj,
    n_pcs = n_pcs,
    descriptors = config$descriptors,
    output_file = file.path(output_dir, "selection_report.txt")
  )

  export_selection_results(
    metrics = metrics,
    selected_ids = selected_ids,
    output_dir = output_dir,
    id_column = config$data$id_column,
    descriptors = config$descriptors,
    counts = counts
  )

  result <- list(
    config = config,
    metrics = metrics,
    counts = counts,
    features = features,
    pca = pca_obj,
    n_pcs = n_pcs,
    selected_ids = selected_ids,
    selected_index = selected_index,
    output_dir = output_dir
  )

  result
}

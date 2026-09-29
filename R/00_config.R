# General configuration and helper functions

check_required_packages <- function() {
  required <- c("readxl", "tidyverse", "prospectr", "factoextra", "yaml")

  missing <- required[!(required %in% rownames(installed.packages()))]
  if (length(missing) > 0) {
    install.packages(missing, repos = "https://cloud.r-project.org")
  }

  invisible(TRUE)
}

merge_lists <- function(base, override) {
  if (is.null(base)) base <- list()
  if (is.null(override)) return(base)

  for (nm in names(override)) {
    if (nm %in% names(base) && is.list(base[[nm]]) && is.list(override[[nm]])) {
      base[[nm]] <- merge_lists(base[[nm]], override[[nm]])
    } else {
      base[[nm]] <- override[[nm]]
    }
  }

  base
}

default_config <- function() {
  list(
    crop_name = "example_crop",
    experiment_id = "example_experiment",
    data = list(
      metrics_file = "data/examples/metrics.csv",
      counts_file = "data/examples/counts.csv",
      id_column = "Label",
      count_id_column = "Batch"
    ),
    descriptors = c("Gmax", "t50germ", "AUC", "uniformity", "b (slope)"),
    pca = list(
      variance_threshold = 0.90,
      center = TRUE,
      scale = TRUE
    ),
    kennard_stone = list(
      n_samples = 30,
      metric = "mahal"
    ),
    plots = list(
      pca_plot = TRUE,
      density_plots = TRUE,
      germination_curves = TRUE,
      save_png = TRUE,
      dpi = 300
    )
  )
}

read_config <- function(config_file) {
  if (!file.exists(config_file)) {
    stop("Config file not found: ", config_file)
  }

  cfg <- yaml::read_yaml(config_file)
  cfg <- merge_lists(default_config(), cfg)
  cfg
}

validate_config <- function(cfg) {
  if (is.null(cfg$data$metrics_file) || !file.exists(cfg$data$metrics_file)) {
    stop("metrics_file in config does not exist: ", cfg$data$metrics_file)
  }

  if (is.null(cfg$data$counts_file) || !file.exists(cfg$data$counts_file)) {
    stop("counts_file in config does not exist: ", cfg$data$counts_file)
  }

  if (length(cfg$descriptors) == 0) {
    stop("At least one descriptor must be specified in config$descriptors")
  }

  if (is.null(cfg$kennard_stone$n_samples) || cfg$kennard_stone$n_samples < 2) {
    stop("kennard_stone$n_samples must be an integer >= 2")
  }

  if (is.null(cfg$pca$variance_threshold) || cfg$pca$variance_threshold <= 0 || cfg$pca$variance_threshold >= 1) {
    stop("pca$variance_threshold must be between 0 and 1 (exclusive)")
  }

  cfg
}

create_output_dir <- function(output_dir) {
  if (is.null(output_dir)) {
    output_dir <- file.path("outputs", format(Sys.time(), "%Y%m%d_%H%M%S"))
  }

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir
}

# Diagnostics and visualizations

make_selection_flag <- function(dataset, id_column, selected_ids) {
  dataset %>%
    dplyr::mutate(
      Selected = .data[[id_column]] %in% selected_ids
    )
}

plot_pca_selection <- function(pca_obj, selected_index, id_vector, output_file = NULL, save_png = TRUE, dpi = 300) {
  selected_flag <- rep(FALSE, nrow(pca_obj$x))
  selected_flag[selected_index] <- TRUE

  plot_df <- data.frame(
    PC1 = pca_obj$x[, 1],
    PC2 = if (ncol(pca_obj$x) >= 2) pca_obj$x[, 2] else 0,
    Selected = selected_flag,
    SampleID = id_vector
  )

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = PC1, y = PC2, colour = Selected, shape = Selected)) +
    ggplot2::geom_point(size = 2.5, alpha = 0.8) +
    ggplot2::labs(x = "PC1", y = "PC2") +
    ggplot2::theme_bw() +
    ggplot2::scale_colour_manual(values = c("FALSE" = "grey70", "TRUE" = "red")) +
    ggplot2::scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 17)) +
    ggplot2::theme(legend.position = "none")

  if (!is.null(output_file) && save_png) {
    ggplot2::ggsave(output_file, p, dpi = dpi, width = 7, height = 6)
  }

  p
}

density_selection_plot <- function(metrics, descriptors, id_column, selected_ids, output_file = NULL, save_png = TRUE, dpi = 300) {
  density_data <- metrics %>%
    dplyr::select(dplyr::all_of(c(id_column, descriptors))) %>%
    tidyr::pivot_longer(cols = -dplyr::all_of(id_column), names_to = "Descriptor", values_to = "Value") %>%
    dplyr::mutate(Selected = .data[[id_column]] %in% selected_ids)

  p <- ggplot2::ggplot(density_data, ggplot2::aes(Value)) +
    ggplot2::geom_density(fill = "grey80", alpha = 0.5) +
    ggplot2::geom_rug(data = subset(density_data, Selected), colour = "red", linewidth = 0.8) +
    ggplot2::facet_wrap(~ Descriptor, scales = "free") +
    ggplot2::theme_bw()

  if (!is.null(output_file) && save_png) {
    ggplot2::ggsave(output_file, p, dpi = dpi, width = 10, height = 7)
  }

  p
}

plot_germination_curves <- function(counts, selected_ids, output_file = NULL, save_png = TRUE, dpi = 300) {
  selected_data <- counts %>%
    dplyr::mutate(Selected = Batch %in% selected_ids)

  p <- ggplot2::ggplot() +
    ggplot2::geom_line(
      data = selected_data,
      ggplot2::aes(Time, Count, group = Batch),
      colour = "grey80",
      linewidth = 0.4
    ) +
    ggplot2::geom_line(
      data = subset(selected_data, Selected),
      ggplot2::aes(Time, Count, group = Batch),
      colour = "red",
      linewidth = 0.4
    ) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Time (h)", y = "Germination (%)")

  if (!is.null(output_file) && save_png) {
    ggplot2::ggsave(output_file, p, dpi = dpi, width = 9, height = 6)
  }

  p
}

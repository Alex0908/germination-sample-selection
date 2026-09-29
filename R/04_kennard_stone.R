# Kennard-Stone selection

select_kennard_stone <- function(scores, n_select, metric = "mahal", id_vector = NULL) {
  if (n_select > nrow(scores)) {
    stop("Requested n_select (", n_select, ") exceeds number of samples (", nrow(scores), ")")
  }

  if (!requireNamespace("prospectr", quietly = TRUE)) {
    stop("Package 'prospectr' is required for KenStone selection")
  }

  ks <- prospectr::kenStone(scores, k = n_select, metric = metric)

  selected_index <- ks$model

  if (!is.null(id_vector)) {
    selected_ids <- id_vector[selected_index]
  } else {
    selected_ids <- selected_index
  }

  list(
    model = selected_index,
    selected_ids = selected_ids,
    object = ks
  )
}

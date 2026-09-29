# Load and validate the descriptor metrics and germination count data

read_table_by_extension <- function(file_path) {
  ext <- tolower(tools::file_ext(file_path))

  if (ext %in% c("csv", "txt")) {
    return(readr::read_csv(file_path, show_col_types = FALSE))
  }

  if (ext %in% c("xls", "xlsx")) {
    return(readxl::read_excel(file_path))
  }

  stop("Unsupported file extension: ", ext)
}

load_metrics <- function(metrics_file, id_column = "Label") {
  metrics <- read_table_by_extension(metrics_file)

  if (!(id_column %in% names(metrics))) {
    stop("id_column '", id_column, "' not found in metrics file")
  }

  metrics
}

parse_time_value <- function(x) {
  if (length(x) == 0) return(numeric(0))

  out <- numeric(length(x))

  for (i in seq_along(x)) {
    val <- x[i]

    if (is.na(val) || is.null(val) || val == "") {
      out[i] <- NA_real_
      next
    }

    if (is.numeric(val)) {
      out[i] <- as.numeric(val)
      next
    }

    if (grepl(":", as.character(val))) {
      parts <- strsplit(as.character(val), ":")[[1]]
      if (length(parts) == 3) {
        out[i] <- as.numeric(parts[1]) * 3600 + as.numeric(parts[2]) * 60 + as.numeric(parts[3])
      } else if (length(parts) == 2) {
        out[i] <- as.numeric(parts[1]) * 3600 + as.numeric(parts[2]) * 60
      } else {
        out[i] <- as.numeric(parts[1])
      }
    } else {
      out[i] <- as.numeric(val)
    }
  }

  out / 3600
}

extract_index_from_name <- function(x) {
  if (length(x) == 0) return(integer(0))

  idx <- regmatches(x, regexpr("\\d+", x))
  suppressWarnings(as.integer(idx))
}

reshape_count_data <- function(raw_counts, id_column = "Batch") {
  if (!(id_column %in% names(raw_counts))) {
    stop("id_column '", id_column, "' not found in count data")
  }

  long_data <- raw_counts %>%
    tidyr::pivot_longer(cols = -dplyr::all_of(id_column), names_to = "var", values_to = "value") %>%
    dplyr::mutate(
      type = tolower(stringr::str_extract(var, "Time|Count|time|count")),
      index = extract_index_from_name(var)
    ) %>%
    dplyr::filter(!is.na(index), !is.na(type)) %>%
    dplyr::mutate(
      type = dplyr::if_else(type == "time", "Time", "Count")
    ) %>%
    dplyr::group_by(.data[[id_column]], index, type) %>%
    dplyr::summarise(value = dplyr::first(value), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = type, values_from = value) %>%
    dplyr::mutate(
      Time = parse_time_value(Time),
      Count = as.numeric(Count)
    ) %>%
    dplyr::arrange(.data[[id_column]], index) %>%
    dplyr::select(dplyr::all_of(id_column), index, Time, Count)

  names(long_data)[names(long_data) == id_column] <- "Batch"

  long_data
}

load_counts <- function(counts_file, id_column = "Batch") {
  raw_counts <- read_table_by_extension(counts_file)

  if (!(id_column %in% names(raw_counts))) {
    stop("id_column '", id_column, "' not found in counts file")
  }

  reshape_count_data(raw_counts, id_column = id_column)
}

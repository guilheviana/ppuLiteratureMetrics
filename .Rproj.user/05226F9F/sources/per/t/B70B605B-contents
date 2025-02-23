# useful helper functions, etc.
getCumulativeNumberOfPubs <- function(dataset = results_clean, filter = "AE015451.2") {

  filtered_data <- dataset |>
                    dplyr::filter(query == filter)

  years <- filtered_data |>
            dplyr::pull(year) |>
            unique() |>
            sort()

  publications_cumsum <- filtered_data |>
    dplyr::group_by(year) |>
    dplyr::tally(sort = FALSE) |>
    dplyr::ungroup() |>
    dplyr::reframe(cummulative = cumsum(n))

  output <- dplyr::bind_cols(year = years, publications_cumsum, query = filter)

  return(output)

}



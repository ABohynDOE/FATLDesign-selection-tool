#' Extract the top 5 designs for different criteria, for all design cases
library(dplyr)

file_list <- list.files('data/')

#' Retrieve the four informative values from a file name: run size, number of 
#' four-level factors, number of two-level factors, resolution
file_info <- function(filename){
  filename |>
    stringr::str_extract_all("\\d+") |>
    unlist()
}

#' Extract the MA designs of all types and join them into a single dataframe along
#' with general infos about the designs
gather_MA_designs <- function(filename, n=5){
  load(paste0('data/',filename))
  
  # Design information to join later into a single dataframe
  infos <- file_info(filename) |>
    purrr::map(as.integer) |>
    unlist()
  
  # Add a design ID to remove duplicate designs later
  data <- data |>
    mutate(
      ID = 1:n(),
      .before = "columns"
    ) |>
    mutate(
      columns = as.character(columns),
      runsize = infos[1],
      m = infos[2],
      n = infos[3],
      p = n - (log2(runsize) - 2*m),
      resolution = infos[4]
    )
  
  # generalized MA over all types of words
  MA <- data |>
    arrange(A3, A4, A5) |>
    slice_head(n=n) |>
    mutate(
      MA_type = "G",
      rank = 1:n()
    )
  
  # Type of words that we have in the design
  for (m_value in 0:infos[2]){
    MA <- data |>
      arrange(
        across(
          matches(
            sprintf("A\\d.%i", m_value)
          )
        )
      ) |>
      slice_head(n=n) |>
      mutate(
        MA_type = m_value,
        rank = 1:n()
      ) |>
      rbind(MA)
  }
  MA
}

# Map MA function to all design files and gather everything into a single df
MA_designs <- purrr::map(
  file_list, 
  gather_MA_designs, 
  .progress = TRUE
) |> 
  bind_rows()

library(dplyr)

file_list <- list.files('data/')

#' Retrieve the four informative values from a file name: run size, number of 
#' four-level factors, number of two-level factors, resolution
file_info <- function(filename){
  out <- filename |>
    stringr::str_extract_all("\\d+") |>
    unlist() |>
    as.integer()
  names(out) <- c('N','m','n','Resolution')
  out
}

catalog_info <- purrr::map(file_list, file_info)
catalog_info <- do.call(rbind, catalog_info)

coverage <- catalog_info |>
  tibble::as_tibble() |>
  group_by(N, m, Resolution) |>
  summarise(n_min = min(n), n_max = max(n), .groups = "drop") |>
  mutate(Resolution = as.roman(Resolution))

# Turns a matrix into a string where entries are tab separated
create_text <- function(m){
  res <- ""
  m <- formatC(m, width = max(nchar(trunc(m))), flag = "", format = "d")
  for(i in 1:nrow(m)){
    res <- paste0(res, paste0(paste(as.character(m[i, 1:ncol(m)]), collapse = "\t"), "\n"))
  }
  return(res)
}
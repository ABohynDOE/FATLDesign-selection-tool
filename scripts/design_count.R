library(dplyr)
library(tidyr)

file_list <- list.files('data/')

design_count <- data.frame()

file_info <- function(filename){
  out <- filename |>
    stringr::str_extract_all("\\d+") |>
    unlist() |>
    as.integer()
  names(out) <- c('N','m','n','Resolution')
  out
}

for (file in file_list) {
  out <- file |>
    stringr::str_extract_all("\\d+") |>
    unlist() |>
    as.integer()
  names(out) <- c('N','m','n','Resolution')
  load(paste0('data/', file))
  out$count <- dim(data)[1]
  design_count <- design_count |>
    rbind(out)
}

count_wide <- design_count |>
  rename("runsize" = "N") |>
  mutate(Resolution = as.roman(Resolution)) |>
  pivot_wider(
    names_from = c(runsize, m, Resolution), 
    values_from = count
  ) |>
  arrange(n)

writexl::write_xlsx(count_wide, "output/count_table.xlsx")

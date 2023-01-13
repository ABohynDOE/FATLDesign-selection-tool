library(dplyr)

# Catalog coverage
coverage <- data.frame(
  N = c(16, 16, 32, 32, 64, 64, 64, 64, 64, 64, 128, 128, 128),
  m = factor(
    c(1, 2, 1, 2, 1, 2, 3, 1, 2, 3, 1, 2, 3),
    levels = c(1, 2, 3)
  ),
  n_min = c(2, 1, 3, 1, 4, 2, 1, 4, 3, 1, 5, 3, 1),
  n_max = c(12, 9, 20, 20, 20, 20, 20, 13, 11, 6, 20, 20, 20),
  resolution = c(3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4)
) %>%
  arrange(resolution, N) %>%
  mutate(
    resolution = as.roman(resolution)) %>%
  select(N, resolution, m, n_min, n_max) %>%
  filter(N != 64 | resolution != as.roman(3))


# Turns a matrix into a string where entries are tab separated
create_text <- function(m){
  res <- ""
  m <- formatC(m, width = max(nchar(trunc(m))), flag = "", format = "d")
  for(i in 1:nrow(m)){
    res <- paste0(res, paste0(paste(as.character(m[i, 1:ncol(m)]), collapse = "\t"), "\n"))
  }
  return(res)
}
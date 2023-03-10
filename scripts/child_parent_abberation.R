library(dplyr)
library(ggplot2)

runsize <- 32
m <- 2
n <- 12

child_file <- sprintf("data/N%i_m%i_n%i_R3.rds", runsize, m, n)
load(child_file)

child_df <- data |>
  mutate(
    child_id = row_number(),
    parent_cols = stringr::str_remove(columns, ',\\d+$')
  ) |>
  rename(child_cols = columns) |>
  arrange(A3, A4, A5) |>
  mutate(child_rank = row_number()) |>
  select(child_id, child_rank, child_cols, parent_cols)

parent_file <- sprintf("data/N%i_m%i_n%i_R3.rds", runsize, m, n-1)
load(parent_file)

parent_df <- data |>
  mutate(
    parent_id = row_number(),
    parent_cols = as.character(columns)
  )|>
  arrange(A3, A4, A5) |>
  mutate(parent_rank = row_number()) |>
  select(parent_id, parent_rank, parent_cols)

complete_df <- child_df |>
  full_join(parent_df, by = join_by(parent_cols)) |>
  mutate(Abberation = ifelse(child_rank < 100, 'Top 100', 'Other')) |>
  arrange(desc(child_rank))

ggplot(complete_df, aes(x=parent_rank, y=child_rank, color=Abberation)) +
  geom_point() +
  theme_classic(base_size = 12) +
  scale_color_manual(values = c('black', 'red')) +
  labs(
    x = "Parent design's rank",
    y = "Child design's rank",
    title = "Abberation ranking of parent design compared to their children design",
    subtitle = sprintf("Parents are %i-run 4^%i 2^%i designs", runsize, m, n-1)
  )

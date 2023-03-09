library(ggplot2)
library(dplyr)
library(plotly)

query_catalog <- function(runsize, m, n, resolution){
  filename <- sprintf(
    'data/N%s_m%s_n%s_R%s.rds',
    runsize, m, n, resolution
  )
  load(filename)
  data
}

data <- query_catalog(32, 2, 7, 3)

p <- data |>
  ggplot(aes(
    x = A3.1,
    y = A3.0, 
    color = A3))+
  geom_point() +
  scale_x_continuous(
    limits = c(0, NA),
    breaks = c(0:max(data$A3.1))
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    breaks = c(0:max(data$A3.0))
  ) + 
  theme_bw() 

p |>
  ggplotly()

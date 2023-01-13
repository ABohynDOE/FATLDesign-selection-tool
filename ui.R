library(reactable)

# Load separate parts of the UI
source("R/introduction.R", local = TRUE)
source("R/sidebar_panel.R", local = TRUE)
source("R/tabs.R", local = TRUE)

ui <- fluidPage(
  # Include css style
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),

  # Application title
  titlePanel("Catalog of regular four-and-two-level designs"),

  # Brief introduction
  introduction,

  # Sidebar with design selection features
  sidebarLayout(
    sidebar_panel,
    mainPanel(
      tabsetPanel(
        id = "tabs",
        type = "tabs",
        information_tab,
        catalog_tab,
        effect_coding_tab
      )
    )
  )
)

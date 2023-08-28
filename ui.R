library(shiny)
library(shinyBS)
library(reactable)

# Load separate parts of the UI
source("R/introduction.R", local = TRUE)
source("R/sidebar_panel.R", local = TRUE)
source("R/tabs.R", local = TRUE)

ui <- fluidPage(
  # Include css style
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel = "icon", type = "image/gif/png", href="icon.png"),
    tags$style(
      HTML(
        ".panel-heading .panel-title a.collapsed:after {
      transform: rotate(180deg);
      transition: .5s ease-in-out;
    }
    .panel-heading .panel-title a:after {
      content:'⏶';
      text-align: right;
      float:right;
      transition: .5s ease-in-out;
    }
    .panel-heading .panel-title a:not([class]):after {
      transform: rotate(180deg);
    }"
      )
    ),
    tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}")
  ),
  
  # Application title
  titlePanel("Catalog of regular four-and-two-level designs"),

  # Brief introduction
  introduction,
  fluidRow(
    align = "left",
    column(
      width = 8,
      tags$blockquote(
        "Bohyn et al., Enumeration of regular fractional factorial designs with four-level and two-level factors,",
        tags$cite("Journal of the Royal Statistical Society Series C: Applied Statistics,"),
        "2023;",
        style = "font-size:10pt;"
      )
    ),
    column(
      width = 4,
      downloadButton(
        outputId = "downloadBib",
        label = "Download .bib",
        icon = icon("book")
      )
    )
  ),
  p(),
  # Sidebar with design selection features
  sidebarLayout(
    sidebar_panel,
    mainPanel(
      tabsetPanel(
        id = "tabs",
        type = "tabs",
        information_tab,
        catalog_tab,
        effect_coding_tab,
        permutations_tab,
        contact_tab
      )
    )
  )
)

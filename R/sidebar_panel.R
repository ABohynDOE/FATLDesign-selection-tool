sidebar_panel <- sidebarPanel(
  h3("Design characteristics:"),

  # Run size
  selectInput(
    inputId = "runsize",
    label = h4(withMathJax("Number of runs \\(N\\)")),
    choices = list(
      "16" = 16,
      "32" = 32,
      "64" = 64,
      "128" = 128
    ),
    selected = 32
  ),

  # Number of four-level factors
  selectInput(
    inputId = "nbr_flvl_fac",
    label = h4(withMathJax("Number of four-level factors \\(m\\)")),
    choices = list(
      "1" = 1,
      "2" = 2,
      "3" = 3
    ),
    selected = 1
  ),

  # Number of two-level factors
  sliderInput(
    inputId = "nbr_tlvl_fac",
    label = h4(withMathJax("Number of two-level factors \\(n\\)")),
    min = 0,
    max = 20,
    value = 10
  ),

  # Resolution
  selectInput("resolution",
    label = h4("Resolution"),
    choices = list(
      "3" = 3,
      "4" = 4
    ),
    selected = 3
  ),

  # Design table attributes
  tags$hr(style = "border-color: #525354;"),
  h3("Table attributes:"),
  p("Select the design properties to display in the table"),

  # Design characteristics to display
  checkboxGroupInput(
    inputId = "characteristics",
    label = h4("Characteristics to display"),
    choices = c(
      "Columns" = "cols",
      "GWLP" = "full",
      "Word counts" = "general",
      "Type-specific word counts" = "type_spe"
    ),
    selected = c("cols", "full")
  ),

  # Number of designs
  numericInput(
    inputId = "n_designs",
    label = h4("Number of designs to display in the table"),
    value = 5,
    min = 1
  ),

  # Generate the table
  actionButton(
    inputId = "generate",
    label = "Generate table",
    icon = icon("table"),
    style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
  ),
)

library(shiny)
library(reactable)
library(dplyr)
library(stringr)

source("R/global.R") # Retrieve coverage data
source("R/mixed_level_design.R") # Function to generate a mixed-level design

server <- function(input, output, session) {
  # Catalog coverage data table ----
  output$coverage <- renderReactable(
    coverage %>%
      mutate(resolution = as.character(resolution)) %>%
      reactable(
        sortable = FALSE,
        defaultColDef = colDef(
          searchable = FALSE,
          align = "center",
          minWidth = 70,
          headerStyle = list(background = "#f7f7f8"),
          header = function(value) gsub("_", " ", value, fixed = TRUE)
        ),
        highlight = TRUE
      )
  )

  # Only update table if button is pressed
  dataInput <- eventReactive(input$generate, {
    # Generate path to characteristics file
    path <- paste0(
      "data/N",
      input$runsize,
      "_m",
      input$nbr_flvl_fac,
      "_n",
      input$nbr_tlvl_fac,
      "_R",
      input$resolution,
      ".rds"
    )
    # Check that the file exists
    file_ok <- file.exists(path)
    validate(need(file_ok, "This design case is not covered in the catalog !"))
    # Read the table as a dataframe
    load(path)
    # Extract the column names
    col_names <- colnames(data)
    # Create the subset of columns based on the characteristics chosen
    var_list <- c()
    if ("cols" %in% input$characteristics) {
      var_list <- append(var_list, "columns")
    }
    if ("full" %in% input$characteristics) {
      var_list <- append(var_list, "wlp")
    }
    if ("general" %in% input$characteristics) {
      new_vars <- col_names[grepl("A\\d$", col_names)]
      var_list <- append(var_list, new_vars)
    }
    if ("type_spe" %in% input$characteristics) {
      new_vars <- col_names[grepl("A\\d\\.\\d", col_names)]
      var_list <- append(var_list, new_vars)
    }
    # Make the selection based on the subset of variables
    data %>%
      select(all_of(var_list)) %>%
      # Rename the variables in title case except WLP
      rename_all(.funs = stringr::str_to_title) %>%
      rename_with(stringr::str_to_upper, starts_with("W")) %>%
      tibble::rowid_to_column("ID")
  })

  # Change the panel to display the catalog when the "Generate" button is pressed
  # to avoid confusion for the user
  observeEvent(input$generate, {
    updateTabsetPanel(session, "tabs", selected = "Catalog")
  })

  # Reactable for the design is generated using the reactive data source
  output$table <- renderReactable({
    data <- dataInput()
    columns <- colnames(data)

    # `WLP` and `Columns` columns should not be sortable and filterable
    define_colDef <- function(name) {
      col_definition <- colDef(minWidth = 70)
      if (name == "WLP" || name == "Columns") {
        col_definition$sortable <- FALSE
        col_definition$filterable <- FALSE
        col_definition$minWidth <- 200
      }
      col_definition
    }

    # Define columns options dynamically to avoid mismatch
    columns_list <- columns %>%
      purrr::map(define_colDef) %>%
      purrr::set_names(columns)

    data %>%
      reactable(
        filterable = TRUE,
        sortable = TRUE,
        columns = columns_list,
        selection = "multiple",
        onClick = "select",
        highlight = TRUE,
        theme = reactableTheme(
          rowSelectedStyle = list(
            backgroundColor = "#eee",
            boxShadow = "inset 2px 0 0 0 #ffa62d"
          )
        )
      )
  })

  # Dynamically retrieve selected rows in the table
  selected <- reactive(getReactableState("table", "selected"))

  # Design table download button ----
  output$downloadTable <- downloadHandler(
    # All design information should be part of the name
    filename = function() {
      sprintf(
        "N%s_m%s_n%s_R%s_design_table.xlsx",
        input$runsize,
        input$nbr_flvl_fac,
        input$nbr_tlvl_fac,
        input$resolution
      )
    },
    content = function(file) {
      data <- dataInput() %>%
        # We only want to export selected designs
        dplyr::slice(selected()) %>%
        # Design ID should be part of the table too
        tibble::rownames_to_column("Rank") %>%
        # Design general information (N, m, n, R) should be displayed in the table too
        mutate(
          N = input$runsize,
          n = input$nbr_tlvl_fac,
          m = input$nbr_flvl_fac,
          resolution = input$resolution,
          .before = "Rank"
        ) %>%
        writexl::write_xlsx(file)
    }
  )

  # Design download button ----
  # Download the designs selected in the data table
  output$downloadDesigns <- downloadHandler(
    filename = function() {
      sprintf(
        "N%s_m%s_n%s_R%s_selected_designs.txt",
        input$runsize,
        input$nbr_flvl_fac,
        input$nbr_tlvl_fac,
        input$resolution
      )
    },
    content = function(file) {
      # First line of the file should give information about the designs created
      info <- paste(
        # We only want to export selected designs
        length(selected()),
        as.integer(input$runsize),
        as.integer(input$nbr_flvl_fac),
        as.integer(input$nbr_tlvl_fac),
        "\n",
        collapse = " "
      )
      write(info, file)
      # Only column numbers are needed
      cols <- dataInput() %>%
        dplyr::slice(selected()) %>%
        pull(Columns)
      # Columns must be transformed into integer
      cols_vec <- lapply(str_split(cols, ","), as.integer)
      # Each column set in the list gives a matrix
      make_design <- function(x) {
        mixed_level_design(
          as.double(input$runsize),
          as.double(input$nbr_flvl_fac),
          x
        )
      }
      matrices <- lapply(cols_vec, make_design)
      # Matrices must be text to later write it to the file as a single line
      matrices_text <- text <- lapply(matrices, create_text)
      index <- 1
      design_id_vec <- selected()
      for (matrix_text in matrices_text) {
        design_id <- design_id_vec[index]
        write(as.character(design_id), file, append = TRUE)
        write(matrix_text, file, append = TRUE)
        index <- index + 1
      }
    }
  )

  # Display the selected designs
  output$designs_selected <- renderText({
    paste(
      "You have selected",
      length(selected()),
      "designs"
    ) %>%
      HTML()
  })
}

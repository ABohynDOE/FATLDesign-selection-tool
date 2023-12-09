library(shiny)
# library(shinyjs)
library(reactable)
library(dplyr)
library(stringr)

source("R/global.R") # Retrieve coverage data
source("R/mixed_level_design.R") # Function to generate a mixed-level design

server <- function(input, output, session) {
  
  output$permutations <- renderReactable({
    read.csv('permutations.csv', header = TRUE, sep = ";") |>
      select(label, p1) |>
      rename(
        Notation = "label",
        `Permutation` = "p1",
      )|>
      reactable(
        sortable = FALSE,
        defaultColDef = colDef(
          searchable = FALSE,
          align = "center",
          minWidth = 30,
          headerStyle = list(background = "#f7f7f8"),
          header = function(value) gsub("_", " ", value, fixed = TRUE)
        ),
        highlight = TRUE,
        defaultPageSize = 12
      )
  })
  
  output$coverage <- renderReactable({
    coverage %>%
      mutate(Resolution = as.character(Resolution)) %>%
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
  })
  
  # Download button for the bibtex file of the reference
  output$downloadBib <- downloadHandler(
    filename = "bohyn_2023_enumeration.bib",
    content = function(file){
      file_conn <- file(file)
      writeLines(
        text = "@article{bohyn2023enumeration,
  title = {Enumeration of Regular Fractional Factorial Designs with Four-Level and Two-Level Factors},
  author = {Bohyn, Alexandre and Schoen, Eric D. and Goos, Peter},
  journal = {Journal of the Royal Statistical Society Series C: Applied Statistics},
  volume={72},
  number={3},
  pages={750--769},
  year = {2023},
  month = may,
  issn = {0035-9254},
  doi = {10.1093/jrsssc/qlad031}
}
",
        con = file_conn
      )
        close(file_conn)
    }
  )
  
  # Only update table if button is pressed
  dataInput <- eventReactive(input$generate, {
    # Currently the resolution is uniquely defined by the run size so the user 
    # doesn't need to input it
    if (input$runsize == 16 || input$runsize == 32) {
      resolution <- 3
    } else {
      resolution <- 4
    }
    
    # Generate path to characteristics file
    path <- paste0(
      "data/N",
      input$runsize,
      "_m",
      input$nbr_flvl_fac,
      "_n",
      input$nbr_tlvl_fac,
      "_R",
      resolution,
      ".rds"
    )
    
    # Check that the file exists
    file_ok <- file.exists(path)
    validate(need(file_ok, "This design case is not covered in the catalog !"))
    
    # Read the table as a dataframe
    # load(path)
    data <- readRDS(path)
  
    data
  })
  
  # Change the panel to display the catalog when the "Generate" button is pressed
  # to avoid confusion for the user
  observeEvent(input$generate, {
    updateTabsetPanel(session, "tabs", selected = "Output")
  })

  # Gather characteristics input from all check boxes into one
  v <- reactiveValues()
  observe({
    v$characteristics <- c(
      input$gen_characteristics,
      input$characteristics,
      input$characteristics_alpha,
      input$characteristics_beta,
      input$characteristics_w2
    )
  })
  
  # Reactable for the design is generated using the reactive data source
  output$table <- renderReactable({
    
    # Data is generated based on the side panel information
    data <- dataInput()
    col_names <- colnames(data)
    
    # `Real` columns are selected in data set based on the selected column names
    # in the side panel
    real_colnames_list <- c()
    if ("index" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "index")
    }
    if ("cols" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "columns")
    }
    if ("full" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "wlp")
    }
    if ("general" %in% v$characteristics) {
      new_vars <- col_names[grepl("A\\d$", col_names)]
      real_colnames_list <- append(real_colnames_list, new_vars)
    }
    if ("type_spe" %in% v$characteristics) {
      new_vars <- col_names[grepl("A\\d\\.\\d", col_names)]
      real_colnames_list <- append(real_colnames_list, new_vars)
    }
    if ("bwlp" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "beta_star_wlp")
    }
    if ("bcounts" %in% v$characteristics) {
      new_vars <- col_names[grepl("B\\d", col_names)]
      real_colnames_list <- append(real_colnames_list, new_vars)
    }
    if ("perm" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "permutations")
    }
    if ("awlp" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "alpha_wlp")
    }
    if ("wvalues" %in% v$characteristics) {
      new_vars <- col_names[grepl("w\\d{1,2}$", col_names)]
      real_colnames_list <- append(real_colnames_list, new_vars)
    }
    if ("w2wlp" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "w2_wlp")
    }
    if ("w2counts" %in% v$characteristics) {
      new_vars <- col_names[grepl("C\\d\\.\\d", col_names)]
      real_colnames_list <- append(real_colnames_list, new_vars)
    }
    if ("factor" %in% v$characteristics) {
      real_colnames_list <- append(real_colnames_list, "factor")
    }
    
    # Generate look up table for the names of the columns
    lookup <- c(
      ID = "index",
      Columns = "columns",
      GWLP = "wlp",
      `β* WLP` = "beta_star_wlp",
      `α WLP` = "alpha_wlp",
      `W₂ WLP` = "w2_wlp",
      `Blocking\nfactor` = "factor",
      Perm. = 'permutations',
      `A₃` = "A3",
      `A₄` = "A4",
      `A₅` = "A5",
      `β*₃` = "B3",
      `β*₄` = "B4",
      `β*₅` = "B5",
      `β*₆` = "B6"
    )
    
    # Data is filtered using the `real` column names just generated and some
    # columns are renamed for aesthetics
    data <- data |>
      # select(all_of(real_colnames_list)) |>
      select(any_of(real_colnames_list)) |>
      # Rename the variables using a look-up table
      rename(any_of(lookup)) |>
      # Rename the omega variables
      rename_with(
        .cols = matches("w\\d+"),
        .fn = ~ str_replace_all(
          string = .x,
          pattern = "\\d",
          replacement = ~ intToUtf8(as.numeric(.x) + 8320)
          ) |> 
          str_replace(
            pattern = "w", 
            replacement = "ω"
          )
      )
    
    
    # We need the "beautified" column names to define their look in the react
    # table
    columns <- colnames(data)
    
    # `WLP` and `Columns` columns should not be sortable and filterable
    define_colDef <- function(name) {
      col_definition <- colDef(minWidth = 70)
      if (name == "Columns" || str_detect(name, "WLP")) {
        col_definition$sortable <- FALSE
        col_definition$filterable <- FALSE
        col_definition$minWidth <- 200
      } else if (name == "Perm.") {
        col_definition$sortable <- FALSE
        col_definition$filterable <- FALSE
      }
      col_definition
    }

    # Define columns options dynamically to avoid mismatch
    columns_list <- columns %>%
      purrr::map(define_colDef) %>%
      purrr::set_names(columns)

    data %>%
      reactable(
        defaultPageSize = input$n_designs,
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
          ),
          inputStyle = list(
            borderColor = "#919191",
            backgroundColor = "#f6f8fa"
          ),
          style = list(
            fontFamily = "Segoe UI"
          )
        )
      )
  })

  # Dynamically retrieve selected rows in the table
  selected <- reactive(getReactableState("table", "selected"))

  
  output$downloadTable <- downloadHandler(
    filename = function() {
      # Currently the resolution is uniquely defined by the run size so the user 
      # doesn't need to input it
      if (input$runsize < 64) {
        resolution <- 3
      } else {
        resolution <- 4
      }

      # All design information should be part of the name
      sprintf(
        "N%s_m%s_n%s_R%s_design_table.xlsx",
        input$runsize,
        input$nbr_flvl_fac,
        input$nbr_tlvl_fac,
        resolution
      )
    },
    content = function(file) {
      # Currently the resolution is uniquely defined by the runsize so the user 
      # doesn't need to input it
      # if (input$runsize < 64) {
      #   resolution <- 3
      # } else {
      #   resolution <- 4
      # }
      data <- dataInput() %>%
        # We only want to export selected designs
        dplyr::slice(selected()) %>%
        # # Design ID should be part of the table too
        # tibble::rownames_to_column("Rank") %>%
        # Design general information (N, m, n, R) should be displayed in the table too
        mutate(
          N = input$runsize,
          n = input$nbr_tlvl_fac,
          m = input$nbr_flvl_fac,
          # Resolution can be inferred from the WLP so no need to add it to the table
          # resolution = resolution
        ) %>%
        writexl::write_xlsx(file)
    }
  )

  output$downloadDesigns <- downloadHandler(
    filename = function() {
      # Currently the resolution is uniquely defined by the runsize so the user 
      # doesn't need to input it
      if (input$runsize < 64) {
        resolution <- 3
      } else {
        resolution <- 4
      }
      sprintf(
        "N%s_m%s_n%s_R%s_selected_designs.txt",
        input$runsize,
        input$nbr_flvl_fac,
        input$nbr_tlvl_fac,
        resolution
      )
    },
    content = function(file) {
      # First line of the file should give information about the designs created
      info <- paste(
        # We only want to export selected designs
        (as.integer(input$nbr_flvl_fac) + as.integer(input$nbr_tlvl_fac)),
        as.integer(input$runsize),
        length(selected()),
        collapse = " "
      )
      write(info, file)
      # Only column numbers are needed
      cols <- dataInput() %>%
        dplyr::slice(selected()) %>%
        pull(columns)
      # Columns must be transformed into integer
      cols_vec <- lapply(str_split(cols, ","), as.integer)
      
      # Function to generate a mixed-level design based on the columns
      make_design <- function(x) {
        mixed_level_design(
          as.double(input$runsize),
          as.double(input$nbr_flvl_fac),
          x
        )
      }
      # Each column set in the list gives a matrix
      matrices <- lapply(cols_vec, make_design)
      # Matrices must be text to later write it to the file as a single line
      matrices_text <- lapply(matrices, create_text)
      index <- 1
      design_id_vec <- selected()
      for (matrix_text in matrices_text) {
        design_id <- design_id_vec[index]
        write(as.character(design_id), file, append = TRUE)
        write(matrix_text, file, append = TRUE)
        index <- index + 1
      }
      write("-1", file, append = TRUE)
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
  
  # Warning for large 128 runs designs
  #Create the warning text - warning if TRUE, empty string if FALSE
  warning_text <- reactive({
    ifelse(dim(dataInput())[1] == 100 & input$runsize == 128,
           'Too many designs available to show. A subset of the 100 best designs according to generalized aberration is shown.',
           '')
  })
  output$LargeDesignsWarning <- renderText(warning_text()) 
}


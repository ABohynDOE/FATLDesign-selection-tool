library(reactable)
# Contents tab ----
information_tab <- tabPanel(
  title = "Contents",
  p(),
  withMathJax(
    p("The table below shows all the design cases with \\(N\\) runs, \\(m\\) four-level factors and \\(n\\) two-level factors covered in the catalog.")
  ),

  # Data table with the coverage of the catalog
  reactableOutput("coverage"),

  # Info on how to use the catalog
  p(
    "To explore the catalog, select the design characteristics of interest in the",
    tags$b("Design characteristics"),
    "section of the side panel and click on the",
    span("Generate table", class = "in-text-button"),
    "button. The table will then be displayed in the 'Output' tab of this panel."
  ),
  p(
    "You can choose which information is shown in the table.",
    "There are four options:"
  ),
  withMathJax(
    tags$ul(
      tags$li(
        tags$b("Columns:"),
        "The column numbers of the effects in a full factorial two-level design in Yates ordering with
                  \\(N\\) runs that define the added factors in the four-and-two-level
                  design. See the tab 'Effect ordering' for further explanation."
      ),
      tags$li(
        tags$b("GWLP:"),
        "The generalized word length pattern \\((A_{3},A_4,\\ldots,A_{m+n})\\)
                of the design"
      ),
      tags$li(
        tags$b("Word counts:"),
        "Counts \\(A_l\\) of words with lengths \\(3 \\leq L \\leq 5\\), allowing
                the user to sort the designs based on these counts. "
      ),
      tags$li(
        tags$b("Type-specific word counts:"),
        "Type-specific counts \\(A_{l.t}\\) of words with lengths \\(3 \\leq l \\leq 5\\)
                and type \\(0 \\leq t \\leq m\\) allowing the user to sort the
                designs based on these counts. "
      )
    )
  )
)

# Output tab ----
catalog_tab <- tabPanel(
  title = "Output",
  h3("Further design selection"),
  p(
    "The interactive table below shows the characteristics for the designs with the run size, number of four-level factors and number of two-level factors you specified in the left panel.",
    "You can click on the column headers of the ID, the word count and the type-specific word count to sort the designs, and the boxes below the header to specify values to filter the table.",
    "To sort using a second column, press `Shift` while clicking on the column header."
  ),
  p(
    "Using the tick boxes, you can indicate designs of particular interest.",
    "You can use the 'Download table' button below to download a table with the characteristics of these designs as an excel file.",
    "The designs in the Table will be ordered according to their ID."
  ),
  downloadButton(
    outputId = "downloadTable",
    label = "Download table",
    style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
  ),
  p(),
  reactableOutput("table"),
  htmlOutput("designs_selected"),
  p(
    "To download the designs, click on the 'Download designs' button below.",
    "In the file, the designs are ordered by ID and the ID of the design is mentionned before the design matrix"
  ),
  downloadButton(
    outputId = "downloadDesigns",
    label = "Download selected designs",
    style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
  )
)

# Effect coding tab ----
effect_coding_tab <- tabPanel(
  title = "Effect ordering",
  h3("Representing factors as numbers"),
  withMathJax(
    p(
      "A two-level design with \\(N\\) runs has \\(k = log_2(N)\\) basic factors.",
      "These factors specify all the treatment combinations of a \\(2^k\\) full factorial design.",
      "Assuming that the factor levels are -1 and +1, additional factors are generated as products of the basic factors.",
      "If we represent the basic factors with individual lowercase letters starting with \\(\\bf{a}\\), then a product of basic factors can be written by combining the letters of the basic factors.",
      "Such products are called",
      tags$span("generators", style = "font-weight: bold"),
      ".",
      "For example, a factor created as the product of the first, third and fourth basic factors would have \\(\\bf{acd}\\) as generator."
    ),
    p(
      "When a large number of basic factors is involved, the letter notation of the generators can be cumbersome.",
      "The solution is to store them as numbers instead of words.",
      "Since every number can be uniquely decomposed into powers of 2, each generator can be associated with a combination of powers of 2.",
      "To do this, each basic factor is assigned to a specific power of 2.",
      "For example, \\(\\bf{a}\\) is represented by 1,  \\(\\bf{b}\\) by 2, and \\(\\bf{c}\\) by 4.",
      "The sum of these powers creates the number defining the generator",
      "The figure below show that process for the generator \\(\\bf{acd}\\)."
    )
  ),
  img(
    src = "column_numbering.png", align = "center", width = 500
  ),
  withMathJax(
    p(
      "With this notation, basic factors are represented by numbers that are powers of 2."
    )
  ),
  h3("Constructing a design from its column numbers"),
  p(
    "When constructing a design with four-level factors and two-level factors, the four-level factors are always constructed from pairs of basic factors.",
    "The two-level factors in the design include the remaining basic factors (if any) and the added factors.",
    "The figure below details this process for a 64-run design with 2 four-level factors, 2 basic two-level factors and 5 added two-level factors."
  ),
  img(
    src = "design_generation.png", align = "center", alt = "Design generation diagram",
    width = 500
  ),
  withMathJax(
    p(
      "Only the column numbers of the added factors are given in the catalog.",
      "But, as the figure shows, it is simple to reconstruct any design only from the added factors, given its run size."
    )
  )
)

# Contact ----
contact_tab <- tabPanel(
  title = "Contact",
  h3("Contact us"),
  p(
    "If you have a question or need more specific information, please contact us
    by mail at alexandre [dot] bohyn [at] kuleuven [dot] be"
  ),
  h3("Bug report"),
  p("If there is a bug with the application or you would like to contribute,
    contact us or create an issue on Github using the button below."),
  actionButton(
    inputId = "bugReport",
    label = "Bug report",
    icon = icon("bug"),
    style = "color: #fff; background-color: #337ab7; border-color: #2e6da4",
    onclick = "window.open('https://github.com/ABohynDOE/FATLDesign-selection-tool/issues/new')"
  )
)

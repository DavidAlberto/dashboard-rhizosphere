# Filter Panel UI
##  Define the UIX subset taxa ranks
filterpage <- fluidPage(
  headerPanel("Data Filtering"),
  fluidRow(
    sidebarPanel(
      actionButton("actionb_filter", "Execute Filter", icon("filter")),
      h4("Subset Taxa"),
      fluidRow(column(width = 12,
                      div(class = "col-md-6",
                          uiOutput("filter_uix_subset_taxa_ranks")),
                      div(class = "col-md-6",
                          uiOutput("filter_uix_subset_taxa_select"))
      )),
      h4("Subset Samples"),
      fluidRow(column(width = 12,
                      div(class = "col-md-6",
                          uiOutput("filter_uix_subset_sample_vars")),
                      div(class = "col-md-6",
                          uiOutput("filter_uix_subset_sample_select"))
      )),
      h4("Total Sums Filtering"),
      fluidRow(column(width = 12,
                      div(class = "col-md-6",
                          numericInputRow(inputId = "filter_sample_sums_threshold",
                                          label = "Sample Min.",
                                          value = SampleSumDefault,
                                          min = 0,
                                          step = 100,
                                          class = "col-md-12")),
                      div(class = "col-md-6",
                          numericInputRow(inputId = "filter_taxa_sums_threshold",
                                          label = "Taxa Min.",
                                          value = OTUSumDefault,
                                          min = 0,
                                          step = 1,
                                          class = "col-md-12"))
      )),
      h4("kOverA OTU Filtering"),
      fluidRow(column(width = 12,
                      div(class = "col-md-3",
                          numericInputRow(inputId = "filter_kOverA_count_threshold",
                                          label = "A",
                                          value = kovera_A,
                                          min = 0,
                                          step = 1,
                                          class = "col-md-12")),
                      div(class = "col-md-3",
                          uiOutput("filter_ui_kOverA_k"))
      ))
    ),
    # Main Panel
    column(
      width = 8,
      offset = 0,
      h4("Histograms Before and After Filtering"),
      plotOutput("filter_summary_plot"),
      h4("Data Overview"),
      fluidRow(
        column(width = 6,
               div(class = "panel panel-default",
                   div(class = "panel-heading", "Original Data"),
                   div(class = "panel-body", htmlOutput("filtered_contents0")))
        ),
        column(width = 6,
               div(class = "panel panel-default",
                   div(class = "panel-heading", "Filtered Data"),
                   div(class = "panel-body", htmlOutput("filtered_contents")))
        )),
      h4("Component Table, Filtered Data"),
      fluidRow(column(width = 12,
                      div(class = "col-md-8", uiOutput("uix_available_components_filt")),
                      div(class = "col-md-4", numericInputRow(inputId = "component_table_colmax_filt",
                                                              label = "Max. Columns",
                                                              value = 25L,
                                                              min = 1L,
                                                              step = 5L,
                                                              class = "col-md-12"))
      )),
      DT::dataTableOutput("physeqComponentTable")
    )
  ),
  # fluidRow(
  #   column(width = 12, includeMarkdown("panels/paneldoc/filter.md"))
  # )
)

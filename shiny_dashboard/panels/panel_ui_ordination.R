# Ordination Panel UI
## Define the variables category that should be shown in UIX
ordtypelist <- as.list(phyloseq::plot_ordination("list"))
names(ordtypelist) <- c("Samples", "Species", "Biplot",
                        "Split Plot", "Scree Plot")

## Define the UIX display
sbp_ord <- sidebarPanel(
  h4("Structure"),
  fluidRow(column(
    width = 12,
    div(class = "col-md-4", selectInput(inputId = "ord_plot_type",
                                        label = "Display",
                                        choices = ordtypelist)),
    div(class = "col-md-4", selectInput(inputId = "ord_method",
                                        label = "Method",
                                        choices = ordlist,
                                        selected = "DCA")),
    div(class = "col-md-4", uiOutput("ord_uix_dist"))
  )),
  fluidRow(column(
    width = 12,
    div(class = "col-md-4", selectInput(inputId = "transform_ord",
                                        label = "Transform",
                                        choices = c("Counts", "Prop",
                                                    "RLog", "CLR"))),
    div(class = "col-md-4", uiOutput("ord_uix_constraint")),
    div(class = "col-md-2", numericInputRow("axis_x_ord", "AesMap X", 1L, 1L,
                                            step = 1L, class = "col-md-12")),
    div(class = "col-md-2", numericInputRow("axis_y_ord", "AesMap Y", 2L, 1L,
                                            step = 1L, class = "col-md-12"))
  )),
  fluidRow(column(
    width = 12,
    div(class = "col-md-4", uiOutput("ord_uix_color")),
    div(class = "col-md-4", uiOutput("ord_uix_shape")),
    div(class = "col-md-4", uiOutput("ord_uix_facetrow")),
  )),
  fluidRow(column(
    div(class = "col-md-4", uiOutput("ord_uix_facetcol")),
    div(class = "col-md-4", uiOutput("ord_uix_label")),
    div(class = "col-md-2",
        numericInputRow(inputId = "label_size_ord",
                        label = "Lab Sz", value = 3, min = 0.5,
                        step = 0.5, class = "col-md-12")),
    div(class = "col-md-2",
        numericInputRow(inputId = "label_vjust_ord", label = "V-Just",
                        value = 2, min = 0, class = "col-md-12"))
  )),
  theme_ui_details("_ord", ptsz = TRUE, alpha = TRUE),
  dim_and_down("_ord")
)

## Ordination Server
ordpage <- fluidPage(theme = shinytheme("cosmo"),
  headerPanel("Ordination Plot"),
  fluidRow(sbp_ord,
           column(width = 8, div(class = "col-md-12", plotOutput("ordination")),
                  div(class = "col-md-12", br()))),
  fluidRow(column(width = 12, includeMarkdown("panels/paneldoc/ordination.md")
  ))
)

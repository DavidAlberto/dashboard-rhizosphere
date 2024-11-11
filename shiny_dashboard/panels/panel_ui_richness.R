# Richness Panel UI
## Define the UIX alpha measures
richmeasvars <- c("Observed", "Chao1", "ACE", "Shannon",
                  "Simpson", "InvSimpson", "Fisher")

## Define the UIX display
sbp_rich <- sidebarPanel(
  h4("Aesthetic Mapping"),
  fluidRow(column(width = 12,
                  div(class = "col-md-6", uiOutput("rich_uix_x")),
                  div(class = "col-md-6", uiOutput("rich_uix_color")),
                  div(class = "col-md-6", uiOutput("rich_uix_shape")),
                  div(class = "col-md-6", uiOutput("rich_uix_label")),
                  div(class = "col-md-6",
                      selectInput(inputId = "measures_rich",
                                  label = "Alpha Measures",
                                  choices = richmeasvars,
                                  selected = c("Shannon", "Chao1"),
                                  multiple = TRUE)),
                  div(class = "col-md-3",
                      numericInputRow(inputId = "label_size_rich",
                                      label = "Lab Sz", value = 3, min = 0.5,
                                      step = 0.5, class = "col-md-12")),
                  div(class = "col-md-3",
                      numericInputRow(inputId = "label_vjust_rich",
                                      label = "V-Just", value = 2, min = 0,
                                      class = "col-md-12"))
  )),
  h4("Details"),
  fluidRow(column(width = 12,
                  div(class = "col-md-4", uipal("pal_rich")),
                  div(class = "col-md-4", uitheme("theme_rich")),
                  div(class = "col-md-2", uiptsz("size_rich", class = "col-md-12")),
                  div(class = "col-md-2", uialpha("alpha_rich", class = "col-md-12")))),
  fluidRow(column(width = 12,
                  div(class = "col-md-4",
                    numericInputRow(inputId = "label_max_rich",
                                    label = "Max. Labels",
                                    value = 30L, min = 0L,
                                    step = 1L, class = "col-md-12")),
                  div(class = "col-md-4",
                    numericInputRow(inputId = "x_axis_angle_rich",
                                    label = "Angle",
                                    value = 90, min = 0, max = 360,
                                    step = 45, class = "col-md-12")),
                  div(class = "col-md-4",
                    radioButtons(inputId = "uicttype_rich",
                                 label = "Source Data",
                                 choices = c("Original", "Filtered"),
                                 selected = "Original",
                                 inline = TRUE))
                  )),
  dim_and_down("_rich")
)

## Richness Server
richpage <- fluidPage(theme = shinytheme("cosmo"),
  headerPanel("Alpha Diversity Estimates", "windowTitle"),
  fluidRow(
    sbp_rich,
    column(width = 8, plotOutput("richness"), offset = 0)
  ),
  fluidRow(
    column(width = 12, includeMarkdown("panels/paneldoc/richness.md"))
  )
)

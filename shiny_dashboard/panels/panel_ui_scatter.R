# Scatter Panel UI
## sbp of Scatter
sbp_scat <- sidebarPanel(
  h4("Aesthetic Mapping"),
  fluidRow(column(width = 12,
    div(class = "col-md-4", uiOutput("scat_uix_x")),
    div(class = "col-md-4", uiOutput("scat_uix_y")),
    div(class = "col-md-4", uiOutput("scat_uix_color"))
  )),
  fluidRow(column(width = 12,
    div(class = "col-md-4", uiOutput("scat_uix_shape")),
    div(class = "col-md-4", uiOutput("scat_uix_facetrow")),
    div(class = "col-md-4", uiOutput("scat_uix_facetcol"))
  )),
  fluidRow(column(width = 12,
    div(class = "col-md-3", selectInput(inputId = "transform_scat",
                                        label = "Transform",
                                        choices = c("Counts", "Prop",
                                                    "RLog", "CLR"))),
    div(class = "col-md-3", uiOutput("scat_uix_label")),
    div(class = "col-md-3",
        numericInputRow(inputId = "label_size_scat", label = "Lab Sz",
                        value = 3, min = 0.5,
                        step = 0.5, class = "col-md-12")),
    div(class = "col-md-3",
        numericInputRow(inputId = "label_vjust_scat", label = "V-Just",
                        value = 2, min = 0,
                        step = 1, class = "col-md-12"))
  )),
  theme_ui_details("_scat", ptsz = TRUE, alpha = TRUE),
  dim_and_down("_scat")
)

## Scatter Server
scatpage <- make_fluidpage(fptitle = "Flexible Scatter Plot",
                           sbp = sbp_scat,
                           outplotid = "scatter",
                           markdownDoc = "scatter.md")
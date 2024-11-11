# Bar Panel UI
## Bar_plot sbp definition
sbp_bar <- sidebarPanel(
  actionButton("actionb_bar", "(Re)Build Graphic", icon("refresh")),
  h4("Aesthetic Mapping"),
  fluidRow(column(width = 12,
    div(class = "col-md-6",
        uiOutput("bar_uix_xvar", inline = TRUE)),
    div(class = "col-md-6",
        uiOutput("bar_uix_colvar", inline = TRUE))
  )),
  fluidRow(column(width = 12,
    div(class = "col-md-4",
        uiOutput("bar_uix_facetrow", inline = TRUE)),
    div(class = "col-md-4",
        uiOutput("bar_uix_facetcol", inline = TRUE)),
    div(class = "col-md-4",
        selectInput(inputId = "uicttype_bar",
                    label = "Data",
                    choices = c("Counts", "Proportions")))
  )),
  theme_ui_details("_bar",
    addList = list(div(class = "col-md-3",
      numericInputRow(inputId = "x_axis_angle_bar",
                      label = "Angle", value = 90,
                      min = 0, max = 360,
                      step = 45, class = "col-md-12")))
  ),
  dim_and_down("_bar")
)

## Bar_plot Server
barpage <- make_fluidpage(fptitle = "Flexible Bar Plot",
                          sbp = sbp_bar,
                          outplotid = "bar",
                          markdownDoc = "bar.md")
# Heatmap Panel UI
## sbp of Heatmap
sbp_heat <- sidebarPanel(
  actionButton("actionb_heat", "(Re)Build Graphic", icon("refresh")),
  h4("Structure"),
  fluidRow(column(width = 12,
                  div(class = "col-md-4",
                      selectInput(inputId = "ord_method_heat",
                                  label = "Method",
                                  choices = ordlist,
                                  selected = "NMDS")),
                  div(class = "col-md-4", uidist("dist_heat")),
                  div(class = "col-md-4",
                      selectInput(inputId = "transform_heat",
                                  label = "Transform",
                                  choices = c("Counts", "Prop", "RLog", "CLR")))
  )),
  h4("Labels"),
  fluidRow(column(width = 12,
                  div(class = "col-md-6", uiOutput("heat_sample_label")),
                  div(class = "col-md-6", uiOutput("heat_taxa_label"))
  )),
  h4("Manual Ordering"),
  fluidRow(column(width = 12,
                  div(class = "col-md-6", uiOutput("heat_sample_order")),
                  div(class = "col-md-6", uiOutput("heat_taxa_order"))
  )),
  h4("Color Scale"),
  fluidRow(column(width = 12,
                  div(class = "col-md-4",
                      textInputRow(inputId = "locolor_heat",
                                   label = "Low",
                                   value = "#000033",
                                   class = "col-md-12")),
                  div(class = "col-md-4",
                      textInputRow(inputId = "hicolor_heat",
                                   label = "High",
                                   value = "#66CCFF",
                                   class = "col-md-12")),
                  div(class = "col-md-4",
                      textInputRow(inputId = "NAcolor_heat",
                                   label = "Missing",
                                   value = "black",
                                   class = "col-md-12"))
  )),
  dim_and_down("_heat")
)

## Heatmap Server
heatpage <- make_fluidpage(fptitle = "Microbiome Heatmap",
                           sbp = sbp_heat,
                           outplotid = "heatmap",
                           markdownDoc = "heatmap.md")
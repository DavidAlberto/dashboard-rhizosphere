# Network Panel UI
## Define UIX available layouts
uinetdistmax <- numericInputRow(inputId = "uinetdistmax",
                                label = "Max D",
                                min = 0.0,
                                max = 1.0,
                                value = netdist,
                                step = 0.1,
                                class = "col-md-12")

## sbp of Network
sbp_net <- sidebarPanel(
  h4("Network Structure"),
  fluidRow(column(width = 12,
                  div(class = "col-md-4",
                      selectInput(inputId = "type_net",
                                  label = "Type",
                                  selected = "samples",
                                  choices = list("Taxa" = "taxa",
                                                 "Samples" = "samples"))),
                  div(class = "col-md-4", uiOutput("net_uix_layout")),
                  div(class = "col-md-4", selectInput(inputId = "transform_net",
                                                      label = "Transform",
                                                      choices = c("Counts", "Prop", "RLog", "CLR"),
                                                      selected = "Counts"))
  )),
  fluidRow(column(width = 12,
                  div(class = "col-md-3", uidist("dist_net")),
                  div(class = "col-md-3", uinetdistmax),
                  div(class = "col-md-6", uiOutput("net_uix_edgeSlider"))
  )),
  h4("Aesthetic Mapping"),
  fluidRow(column(width = 12,
                  div(class = "col-md-6", uiOutput("net_uix_color")),
                  div(class = "col-md-6", uiOutput("net_uix_shape"))
  )),
  fluidRow(column(width = 12,
                  div(class = "col-md-6", uiOutput("net_uix_label")),
                  div(class = "col-md-3",
                      numericInputRow(inputId = "label_size_net",
                                      label = "Lab Sz",
                                      value = 3,
                                      min = 0.5,
                                      step = 0.5,
                                      class = "col-md-12")),
                  div(class = "col-md-3",
                      numericInputRow(inputId = "label_vjust_net",
                                      label = "V-Just",
                                      value = 2,
                                      min = 0,
                                      class = "col-md-12"))
  )),
  theme_ui_details(suffix = "_net",
                   them = FALSE,
                   ptsz = TRUE,
                   alpha = TRUE,
                   addList <- list(div(class = "col-md-3",
                                       numericInputRow(inputId = "RNGseed_net",
                                                       label = "R-Seed",
                                                       value = 711L,
                                                       min = 1L,
                                                       step = 1L,
                                                       class = "col-md-12"))
                   )),
  dim_and_down("_net")
)

## Network page
netpage <- make_fluidpage(fptitle = "Distance Threshold Network",
                          sbp = sbp_net,
                          outplotid = "network",
                          markdownDoc = "network.md")

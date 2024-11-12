# Provenance Panel UI
## Provenance Tracking Code Record, sbp definition
sbp_prov <- sidebarPanel(
  h4("Archive"),
  fluidRow(column(width = 9,
    div(class = "col-md-3",
        selectInput(inputId = "compress_prov",
                    label = "Compression",
                    choices = c("none", "gzip", "bzip2", "xz"),
                    selected = "gzip",
                    multiple = FALSE)),
    div(class = "col-md-6",
        div(style = "display:inline-block", tags$label(div(icon("archive"))),
            downloadButton("downloadProvenance",
                           tags$label("Download Archive"))))
  )),
  h4("Code Preview"),
  fluidRow(column(width = 9,
    div(class = "col-md-3",
        numericInputRow(inputId = "number_events_prov",
                        label = "# Events",
                        value = 5,
                        min = 1,
                        step = 1,
                        class = "col-md-12")),
    div(class = "col-md-6",
        div(style = "display:inline-block", tags$label(icon("code")),
            actionButton("actionb_prov", "Preview Code", icon("eye-open"))))
  ))
)

## Provenance Tracking Page
provpage <- fluidPage(
  fluidRow(h1("Provenance Tracking "), h2("Archive Your Session")),
  fluidRow(sbp_prov, column(width = 8, htmlOutput("provenance"))),
  fluidRow(column(width = 12, includeMarkdown("panels/paneldoc/provenance.md")))
)

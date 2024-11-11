# Color Palette Panel Server
## Color Palette sbp definition
sbp_pal <- sidebarPanel(
  uipal("pal_pal"),
  uitheme("theme_pal")
)

## Color Palette Server
palpage <- fluidPage(
  headerPanel("Palette and Theme Documentation Only"),
  sidebarLayout(
    sidebarPanel = sbp_pal,
    mainPanel = mainPanel(
      h4("Explore Different Palettes"),
      plotOutput("paletteExample"),
      fluidRow(column(width = 12,
        includeMarkdown("panels/paneldoc/palette.md")
      )),
      tags$hr(),
      plotOutput("paletteOptions"),
      h4("Palette Details:"),
      dataTableOutput("paletteTable")
    )
  )
)
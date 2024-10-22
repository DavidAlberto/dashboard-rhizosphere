# UI helper functions
## Plot format
graphicTypeUI <- function(inputId, label = "Format", choices = graphicFormats, selected = "pdf") {
  selectInput(inputId, label, choices, selected,
              multiple = FALSE, selectize = TRUE)
}

## Taxa and sample
uitype <- function(id = "type", selected = "taxa") {
  selectInput(inputId = id, label = "Type",
              selected = selected,
              choices = list("Taxa" = "taxa", "Samples" = "samples"))
}

## Plot Size
uiptsz <- function(id, ...) {
  numericInputRow(inputId = id, label = "Size",
                  min = 1, max = NA, value = 5, step = 1, ...)
}

## Opacity
uialpha <- function(id, ...) {
  numericInputRow(inputId = id, label = "Opacity",
                  min = 0, max = 1, value = 1, step = 0.1, ...)
}

## Color pallete
uipal <- function(id, default = "Set1") {
  selectInput(id, "Palette", choices = rownames(RColorBrewer::brewer.pal.info), selected = default
  )
}

## Plot theme
uitheme <- function(id, default="bl_wh"){
  selectInput(id, "Theme",
              choices = names(shiny_phyloseq_ggtheme_list),
              selected = default
  )
}

## Multi-widget definitions
dim_and_down <- function(suffix, secTitle = "Dimensions & Download") {
  fluidRow(
    column(width = 12,
      h4(secTitle),
      div(class = "col-md-3", numericInputRow(paste0("width", suffix), "Width", 8, 1, 100, 1, class = "col-md-12")),
      div(class = "col-md-3", numericInputRow(paste0("height", suffix), "Height", 8, 1, 100, 1, class = "col-md-12")),
      div(class = "col-md-3", graphicTypeUI(paste0("downtype", suffix))),
      div(class = "col-md-2", div(style = "display:inline-block", tags$label("DL"), downloadButton(paste0("download", suffix), "  ")))
    )
  )
}

## Select details of plots
theme_ui_details <- function(suffix, secTitle = "Details", pal = TRUE, them = TRUE, ptsz = FALSE, alpha = FALSE, addList = NULL) {
  elementList <- list(width = 12, h4(secTitle))
  if (pal) {
    elementList <- c(elementList, list(div(class = "col-md-4", uipal(paste0("pal", suffix)))))
  }
  if (them) {
    elementList <- c(elementList, list(div(class = "col-md-4", uitheme(paste0("theme", suffix)))))
  }
  if (ptsz) {
    elementList <- c(elementList, list(div(class = "col-md-3", uiptsz(paste0("size", suffix), class = "col-md-12"))))
  }
  if (alpha) {
    elementList <- c(elementList, list(div(class = "col-md-3", uialpha(paste0("alpha", suffix), class = "col-md-12"))))
  }
  elementList <- c(elementList, addList)
  return(fluidRow(do.call("column", args = elementList)))
}

# Generic distance UI stuff.
## NOTE: not all distance methods are supported if "taxa" selected for type.
uidist <- function(id, selected = "bray") {
  return(selectInput(id, "Distance", distlist, selected = selected))
}
## Whether to use proportions or counts
uicttype <- function(id = "uicttype") {
  selectInput(inputId = id, label = "Data",
              choices = c("Counts", "Proportions"),
              selected = "Counts")
}

# Generic Ordination UI stuff.
ordlist <- as.list(phyloseq::ordinate("list"))
names(ordlist) <- ordlist
ordlist <- ordlist[-which(ordlist %in% c("MDS", "PCoA"))]
ordlist <- c(list("MDS/PCoA" = "MDS"), ordlist)

# Define each fluid page
make_fluidpage <- function(fptitle = "", sbp, outplotid, markdownDoc = "") {
  mdRow <- fluidRow(column(width = 12, " "))
  if (nchar(markdownDoc) > 0) {
    mdRow <- fluidRow(column(width = 12, includeMarkdown(file.path("panels/paneldoc", markdownDoc))))
  }
  fluidPage(
    headerPanel(fptitle, "windowTitle"),
    fluidRow(sbp, column(width = 8, plotOutput(outplotid))),
    mdRow
  )
}

## Load panels UIs
source("panels/panel_ui_data.R", local = TRUE)
source("panels/panel_ui_filter.R", local = TRUE)
source("panels/panel_ui_richness.R", local = TRUE)
source("panels/panel_ui_net.R", local = TRUE)
source("panels/panel_ui_d3.R", local = TRUE)
source("panels/panel_ui_ordination.R", local = TRUE)
source("panels/panel_ui_heatmap.R", local = TRUE)
source("panels/panel_ui_tree.R", local = TRUE)
source("panels/panel_ui_scatter.R", local = TRUE)
source("panels/panel_ui_bar.R", local = TRUE)
source("panels/panel_ui_palette.R", local = TRUE)
source("panels/panel_ui_provenance.R", local = TRUE)

# Transform panel is only documentation
transpage <- fluidPage(
  headerPanel("Transform Widget Documentation"),
  fluidRow(column(width = 12, includeMarkdown("panels/paneldoc/transform.md")))
)

# Header tag list
# headerTagList <- list(
#  tags$style(type = "text/css", ".phyloseq-print { font-size: 10px; }"),
#  tags$base(target = "_blank")
#)
headerTagList <- list(
  tags$style(type = "text/css", "
    .phyloseq-print { font-size: 10px; }
    .navbar-default .navbar-brand { color: #18bc9c; } 
    .navbar-default { background-color: #2c3e50; }
  "),
  tags$base(target = "_blank")
)

# Shiny theme
my_theme <- bs_theme(
  bootswatch = "flatly",
  primary = "#2c3e50",
  secondary = "#18bc9c",
  base_font = font_google("Roboto"),
  heading_font = font_google("Lato")
)

# Principal UI function
ui <- navbarPage(
  title = h4(a(href = "http://joey711.github.io/shiny-phyloseq/",
               style = "color:#F0F0F0", "Shiny-phyloseq")),
  theme = my_theme,
  tabPanel("Select Dataset", datapage),
  tabPanel("Filter", filterpage),
  tabPanel("Alpha Diversity", richpage),
  tabPanel("Network", netpage),
  tabPanel("d3Network", d3netpage),
  tabPanel("Ordination", ordpage),
  tabPanel("Heatmap", heatpage),
  tabPanel("Tree", treepage),
  tabPanel("Scatter", scatpage),
  tabPanel("Bar", barpage),
  tabPanel("Palette", palpage),
  tabPanel("Transform", transpage),
  tabPanel("Provenance", provpage),
  header = headerTagList,
  collapsible = TRUE,
  windowTitle = "Shiny-phyloseq"
)
shinyUI(ui)
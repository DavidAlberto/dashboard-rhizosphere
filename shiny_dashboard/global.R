# Load packages, default parameters and ggsave custom
source("install.R", local = TRUE)
source("parameters_ggsave.R", local = TRUE)

# Load datasets
env_psdata <- new.env()
data(list = c("GlobalPatterns", "enterotype", "esophagus"), envir = env_psdata)
load("data/kostic.RData", envir = env_psdata)
load("data/1457_uparse.RData", envir = env_psdata)
load("data/agave.RData", envir = env_psdata)
attach(env_psdata)

## Define initial list of available datasets
datalist <- list(
  closed_1457_uparse = closed_1457_uparse,
  study_1457_Kostic = kostic,
  GlobalPatterns = GlobalPatterns,
  enterotype = enterotype,
  esophagus = esophagus,
  Agave = agave
)

# Utility functions
## For pasting times into things
simpletime <- function() {
  gsub("\\D", "_", Sys.time())
}

## Convert output phyloseq in HTML
output_phyloseq_print_html <- function(physeq) {
  HTML(
    paste(
      '<p class="phyloseq-print">',
      paste0(capture.output(print(physeq)), collapse = " <br/> "),
      "</p>"
    )
  )
}

## Create numeric input
numericInputRow <- function(inputId, label, value, min = NA, max = NA, step = NA, class="form-control", ...) {
  inputTag <- tags$input(id = inputId, type = "number", value = value, class=class, ...)
  if (!is.na(min))
    inputTag$attribs$min <- min
  if (!is.na(max))
    inputTag$attribs$max <- max
  if (!is.na(step))
    inputTag$attribs$step <- step
  div(style = "display:inline-block",
      tags$label(label, `for` = inputId),
      inputTag)
}

## Create text input
textInputRow <- function(inputId, label, value = "", class = "form-control", ...) {
  div(style = "display:inline-block",
      tags$label(label, `for` = inputId),
      tags$input(id = inputId, type = "text", value = value, class = class, ...))
}

# Plot customization
## ggplot2 themes
theme_blank_custom <- theme_bw() +
  theme(
    plot.title = element_text(size = 28),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_blank()
  )

## ggplot2 themes list
shiny_phyloseq_ggtheme_list <- list(
  bl_wh = theme_bw(),
  blank = theme_blank_custom,
  thin = theme_linedraw(),
  light = theme_light(),
  minimal = theme_minimal(),
  classic = theme_classic(),
  gray = theme_gray()
)

# Failed plots
## Plot of fail rendering
RstudioPNGsp <- png::readPNG("www/RStudio-logo-shiny-phyloseq.png")
RasterRstudio <- grid::rasterGrob(RstudioPNGsp, interpolate = TRUE)
fail_gen <- function(main = "Change settings and/or click buttons.", subtext = "", image = RasterRstudio) {
  qplot(x = 0, y = 0, main = main) +
    annotation_custom(image, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    annotate("text", 0, 0, size = 10, color = "black", hjust = 0.5, vjust = -1, label = subtext) +
    theme_blank_custom
}

## Print plot shiny conditional
shiny_phyloseq_print = function(p, f = fail_gen()) {
  if (inherits(p, "ggplot")) {
    printout <- NULL
    try(printout <- print(p), silent=TRUE)
    if(is.null(printout)){
      print(f)
    }
  } else {
    print(f)
  }
}

# Functions for handling variables or objects
## Null data processing
av = function(x) {
  if (isTRUE(all.equal(x, "")) | isTRUE(all.equal(x, "NULL"))) {
    return(NULL)
  }
  return(x)
}

## Faceted plost (subplots)
get_facet_grid <- function(facetrow=NULL, facetcol=NULL) {
  if (is.null(av(facetrow)) & is.null(av(facetcol))) {
    return(NULL)
  } else if (is.null(av(facetcol))) {
    formstring = paste(paste(facetrow, collapse = "+"), "~", ".")
  } else {
    formstring <- paste(paste(facetrow, collapse = "+"), "~",
                  paste(facetcol, collapse = "+"))
  }
  return(as.formula(formstring))
}

## Convert phyloseq object to table
tablify_phyloseq_component <- function(component, colmax=25L) {
  if (inherits(component, "sample_data")) {
    Table <- data.frame(component)
  }
  if (inherits(component, "taxonomyTable")) {
    Table <- component@.Data
  }
  if (inherits(component, "otu_table")) {
    if (!taxa_are_rows(component)) {
      component <- t(component)
    }
    Table <- component@.Data
  }
  return(Table[, 1:min(colmax, ncol(Table))])
}

## Filter components of phyloseq object
component_options <- function(physeq) {
  component_option_list <- list("NULL"="NULL")
  nonEmpty <- sapply(slotNames(physeq),
                     function(x, ps) { !is.null(access(ps, x)) }, ps = physeq)
  if (sum(nonEmpty)<1) { return(NULL) }
  nonEmpty <- names(nonEmpty)[nonEmpty]
  nonEmpty <- nonEmpty[!nonEmpty %in% c("phy_tree", "refseq")]
  if (length(nonEmpty)<1) { return(component_option_list) }
  compFuncString <- names(phyloseq:::get.component.classes()[nonEmpty])
  if ("sam_data" %in% compFuncString) { compFuncString[compFuncString == "sam_data"] <- "sample_data" }
  NiceNames <- c(otu_table="OTU Table", sample_data="Sample Data", tax_table = "Taxonomy Table")
  names(compFuncString) <- NiceNames[compFuncString]
  return(c(component_option_list, as.list(compFuncString)))
}

# Distance
## Distance methods
distlist <- as.list(unlist(phyloseq::distanceMethodList))
names(distlist) <- distlist
distlist <- distlist[which(!distlist %in% c("ANY"))]

## Distance matrix calculation
scaled_distance <- function(physeq, method, type, rescaled = TRUE){
  Dist = phyloseq::distance(physeq, method, type)
  if(rescaled){
    Dist <- Dist / max(Dist, na.rm=TRUE)
    Dist <- Dist - min(Dist, na.rm=TRUE)
  }
  return(Dist)
}

## Convert distance matrix to edge table
dist_to_edge_table <- function(Dist, MaxDistance = NULL, vnames = c("v1", "v2")){
  dmat <- as.matrix(Dist)
  dmat[upper.tri(dmat, diag = TRUE)] <- Inf
  LinksData <- data.table(reshape2::melt(dmat, varnames=vnames, as.is = TRUE))
  setnames(LinksData, old = "value", new = "Distance")
  LinksData <- LinksData[is.finite(Distance), ]
  if(!is.null(MaxDistance)){
    LinksData <- LinksData[Distance < MaxDistance, ]
  }
  return(LinksData)
}
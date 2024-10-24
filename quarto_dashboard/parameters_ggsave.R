# Default parameters
## Animation Parameters
interval <- 1000                             # Frame delay interval in milliseconds
loop <- TRUE                                 # Loop the value range or stop after one pass

## Filter Default Parameters
SampleSumDefault <- 1000                     # Threshold for sample sums filtering
OTUSumDefault <- 10                          # Threshold for OTU sums filtering
kovera_A <- 0                                # 'A' parameter for KOverA filtering
kovera_k <- 0                                # 'k' parameter for KOverA filtering

## Network Default Parameters
netdist <- 0.6                               # Maximum distance for network structure
animation_steps <- 20                        # Number of steps to include in an animation
default_netLabel <- "NULL"                   # Network label
netThreshColorVariableDefault <- "DIAGNOSIS" # Color var for network threshold
netThreshShapeVariableDefault <- "SEX"       # Shape var for network threshold
netThreshDistanceMethod <- "bray"            # Distance method for network threshold

## d3 Network Default Parameters
LinkDistThreshold <- 0.4                     # Link distance threshold for d3 network
d3DefaultLinkScaleFactor <- 40               # Link scale factor for d3 network
d3DefaultDistance <- "bray"                  # Distance method for d3 network
d3NetworkColorVar <- "Family"                # Color variable for d3 network
d3NodeLabelVar <- c("Phylum", "Order",       # Node label variables for d3 network
                    "Class", "Family", "OTU")

# Function ggsave custom
## Supported download format labels
vectorGraphicFormats <- c("emf", "eps", "pdf", "tex", "svg", "wmf")
rasterGraphicFormats <- c("bmp", "jpg", "png", "tiff")
graphicFormats <- c(vectorGraphicFormats, rasterGraphicFormats)

## Generate unique filenames
ggfilegen <- function(prefix, graphictype = "pdf") {
  return({
    function() {
      paste0(prefix, simpletime(), ".", graphictype)
    }
  })
}

## Custom ggsave2 function
ggsave2 <- function(filename = "ggplot2save2", plot = last_plot(),
                    device = "pdf", scale = 1, width = par("din")[1],
                    height = par("din")[2], units = c("in", "cm", "mm"),
                    dpi = 300L, limitsize = TRUE, ...) {
  if (!inherits(plot, "ggplot")) stop("plot should be a ggplot2 plot")
  if (!(device %in% graphicFormats)) {
    stop("Graphic device option not supported. Choose from: ",
         paste0(graphicFormats, collapse = ", "))
  }
  # Define device functions
  ggeps <- ggps <- function(..., width, height)
    grDevices::postscript(..., width = width, height = height, onefile = FALSE,
                          horizontal = FALSE, paper = "special")
  ggtex <- function(..., width, height)
    grDevices::pictex(..., width = width, height = height)
  ggpdf <- function(..., version = "1.4")
    grDevices::pdf(..., version = version)
  ggsvg <- function(...)
    grDevices::svg(...)
  ggwmf <- function(..., width, height)
    grDevices::win.metafile(..., width = width, height = height)
  ggemf <- function(..., width, height)
    grDevices::win.metafile(..., width = width, height = height)
  # Raster Graphics (dpi needed)
  ggpng <- function(..., width, height)
    grDevices::png(...,  width = width, height = height, res = dpi, units = "in")
  ggjpg <- jpeg <- function(..., width, height)
    grDevices::jpeg(..., width = width, height = height, res = dpi, units = "in")
  ggbmp <- function(..., width, height)
    grDevices::bmp(...,  width = width, height = height, res = dpi, units = "in")
  ggtiff <- function(..., width, height)
    grDevices::tiff(..., width = width, height = height, res = dpi, units = "in") 
  units <- match.arg(units)
  convert_to_inches <- function(x, units) {
    x <- switch(units,
                `in` = x,
                cm = x / 2.54,
                mm = x / 2.54 / 10)
  }
  convert_from_inches <- function(x, units) {
    x <- switch(units,
                `in` = x,
                cm = x * 2.54,
                mm = x * 2.54 * 10)
  }
  # Convert width and height into inches when they are specified
  if (!missing(width)) {
    width <- convert_to_inches(width, units)
  }
  if (!missing(height)) {
    height <- convert_to_inches(height, units)
  }
  if (missing(width) || missing(height)) {
    message("Saving ", prettyNum(convert_from_inches(width * scale, units), digits = 3),
            " x ", prettyNum(convert_from_inches(height * scale, units), digits = 3), " ", units, " image")
  }
  width <- width * scale
  height <- height * scale
  if (limitsize && (width >= 50 || height >= 50)) {
    stop("Dimensions exceed 50 inches (height and width are specified in inches/cm/mm, not pixels).",
         " If you are sure you want these dimensions, use 'limitsize=FALSE'.")
  }
  # Revised `device` interpretation for ggsave2
  graphicDevice <- get(paste0("gg", device))
  graphicDevice(file = filename, width = width, height = height, ...)
  on.exit(capture.output(dev.off()))
  print(plot)
  invisible()
}
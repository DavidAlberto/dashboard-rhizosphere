# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Check R version
r_min_version <- "4.3.0"
if (compareVersion(as.character(getRversion()), R_MIN_VERSION) < 0) {
  stop("R version ", r_min_version,
       " or higher is required. Please update R from http://cran.r-project.org/")
}

# Install or update BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(update = TRUE, ask = FALSE)

# Function to install or update packages
install_or_update_package <- function(pkg, version = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE) ||
        (is.null(version) &&
           !is.null(packageVersion(pkg)) &&
           packageVersion(pkg) < version)) {
    message("Installing/updating package: ", pkg)
    BiocManager::install(pkg, update = FALSE, ask = FALSE)
  }
}

# List of required packages with versions
required_packages <- c(
  shiny, shinythemes, DT, phyloseq, biomformat, ggplot2, data.table,
  networkD3, genefilter, grid, gridExtra, markdown, rmarkdown, bslib,
  png, RColorBrewer, scales
)

# Install or update required packages
invisible(mapply(install_or_update_package,
                 names(required_packages), required_packages))

# Load and display versions of installed packages
sapply(names(required_packages), function(pkg) {
  library(pkg, character.only = TRUE)
  message(pkg, " package version: ", packageVersion(pkg))
})
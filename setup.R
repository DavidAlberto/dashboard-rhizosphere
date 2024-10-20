# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Check R version
R_MIN_VERSION <- "4.3.0"
if (compareVersion(as.character(getRversion()), R_MIN_VERSION) < 0) {
  stop("R version ", R_MIN_VERSION, " or higher is required. Please update R from http://cran.r-project.org/")
}

# Install or update BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(update = TRUE, ask = FALSE)

# Function to install or update packages
install_or_update_package <- function(pkg, version = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE) ||
      (is.null(version) && !is.null(packageVersion(pkg)) && packageVersion(pkg) < version)) {
    message("Installing/updating package: ", pkg)
    BiocManager::install(pkg, update = FALSE, ask = FALSE)
  }
}

# List of required packages with versions
required_packages <- c(
  phyloseq = "1.16.0", biomformat = "1.0.0", shiny = "0.13.2",
  shinythemes = "1.0.1", ggplot2 = "2.1.0", data.table = "1.9.6",
  networkD3 = "0.2.10", genefilter = "1.54.0", grid = "3.3.0",
  gridExtra = "2.2.1", markdown = "0.7.7", rmarkdown = "0.9.6",
  png = "0.1.7", RColorBrewer = "1.1.2", scales = "0.4.0", DT = "0.33"
)

# Install or update required packages
invisible(mapply(install_or_update_package, names(required_packages), required_packages))

# Load and display versions of installed packages
sapply(names(required_packages), function(pkg) {
  library(pkg, character.only = TRUE)
  message(pkg, " package version: ", packageVersion(pkg))
})
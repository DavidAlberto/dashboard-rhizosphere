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
  phyloseq = "1.48.0", biomformat = "1.32.0", shiny = "1.9.1",
  shinythemes = "1.2.0", ggplot2 = "3.5.1", data.table = "1.16.2",
  networkD3 = "0.4", genefilter = "1.86.0", grid = "4.4.1",
  gridExtra = "2.3", markdown = "1.13", rmarkdown = "2.28",
  png = "0.1.8", RColorBrewer = "1.1.3", scales = "1.3.0", DT = "0.33"
)

# Install or update required packages
invisible(mapply(install_or_update_package, names(required_packages), required_packages))

# Load and display versions of installed packages
sapply(names(required_packages), function(pkg) {
  library(pkg, character.only = TRUE)
  message(pkg, " package version: ", packageVersion(pkg))
})
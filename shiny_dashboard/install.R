# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Check R version
r_min_version <- "4.3.0"
if (compareVersion(as.character(getRversion()), r_min_version) < 0) {
  stop("R version ", r_min_version,
       " or higher is required. Please update R from http://cran.r-project.org/")
}

#Install or update BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(update = TRUE, ask = FALSE)

# Function to install or update packages
install_or_update_package <- function(pkg, version = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE) ||
      (!is.null(version) && packageVersion(pkg) < version)) {
    message("Installing/updating package: ", pkg)
    BiocManager::install(pkg, ask = FALSE)
  }
}

# Install and load renv for environment management
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Initialize the environment with renv (this creates the project and initial settings)
renv::init()

# List of required packages
required_packages <- c(
  "shiny", "shinythemes", "DT", "phyloseq", "biomformat", "ggplot2",
  "data.table", "genefilter", "grid", "gridExtra", "markdown", 
  "rmarkdown", "bslib", "png", "RColorBrewer", "scales", "DESeq2"
)

# Install or update required packages
invisible(lapply(required_packages, install_or_update_package))

# Load and display versions of installed packages
for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    library(pkg, character.only = TRUE)
    message(pkg, " package version: ", packageVersion(pkg))
  } else {
    warning("Failed to load package: ", pkg)
  }
}

# Take a snapshot of the installed packages
renv::snapshot()

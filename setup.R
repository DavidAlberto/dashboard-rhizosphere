# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))
options(browser = "firefox")
Sys.setenv(R_BROWSER = "firefox")

# Check R version
r_min_version <- "4.3.0"
if (compareVersion(as.character(getRversion()), r_min_version) < 0) {
  stop("R version ", r_min_version,
       " or higher is required. Please update R from http://cran.r-project.org/")
}

# Install renv if not already installed
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Restore the environment from renv.lock
renv::restore()

# List of required packages (should match your install.R)
required_packages <- c(
  "shiny", "shinythemes", "DT", "phyloseq", "biomformat", "ggplot2",
  "data.table", "genefilter", "grid", "gridExtra", "markdown", 
  "rmarkdown", "bslib", "png", "RColorBrewer", "scales", "DESeq2"
)

# Function to check and install missing packages
check_and_install_packages <- function(packages) {
  # Install BiocManager if not available
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message("Package ", pkg, " is not installed. Installing...")
      tryCatch({
        BiocManager::install(pkg, ask = FALSE)
        if (!requireNamespace(pkg, quietly = TRUE)) {
          warning("Failed to install package: ", pkg)
        }
      }, error = function(e) {
        warning("Error installing package ", pkg, ": ", e$message)
      })
    }
  }
}

# Check and install any missing packages
check_and_install_packages(required_packages)

# Snapshot the environment to update renv.lock if there were changes
renv::snapshot(lockfile = "renv.lock", update = TRUE)

# Final message
message("Setup completed. Verify that all packages loaded correctly.")
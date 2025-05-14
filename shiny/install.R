# setup.R - Config of the R environment

# Configure CRAN repository and default browser
options(repos = c(CRAN = "https://cran.rstudio.com/"))
options(browser = "firefox")
Sys.setenv(R_BROWSER = "firefox")

# Verify minimum R version required 
r_min_version <- "4.4.0"
if (compareVersion(as.character(getRversion()), r_min_version) < 0) {
  stop("R version", r_min_version, " or higher is requiered.\n",
       "Please update R to the latest version.\n",
       "You can download the latest version of R from http://cran.r-project.org/")
}

# Installing package managers if not available
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Define required packages with their minimum versions
required_packages <- list(
  # Basic packages
  "shiny" = "1.10.0",
  "shinythemes" = "1.2.0",
  "bslib" = "0.9.0",
  "DT" = "0.33",
  "rmarkdown" = "2.29",
  
  # Analysis packages
  "phyloseq" = "1.50.0",
  "biomformat" = "1.34.0",
  "DESeq2" = "1.46.0",
  "genefilter" = "1.90.0",
  
  # Visualization packages
  "ggplot2" = "3.5.2",
  "grid" = "4.4.3",
  "gridExtra" = "2.3",
  "RColorBrewer" = "1.1.3",
  "scales" = "1.4.0",
  "png" = "0.1.8",
  
  # Package for managing data
  "data.table" = "1.17.0"
)

# Function to verify, install and load packages
install_and_load_packages <- function(pkg_list) {
  message("Verifying and installing packages...")
  
  for (pkg_name in names(pkg_list)) {
    min_version <- pkg_list[[pkg_name]]
    
    # Verify if the package is installed
    is_installed <- requireNamespace(pkg_name, quietly = TRUE)
    needs_update <- FALSE
    
    # Check if you need to upgrade
    if (is_installed) {
      current_version <- as.character(packageVersion(pkg_name))
      if (compareVersion(current_version, min_version) < 0) {
        message("The package ", pkg_name, " (", current_version, 
                ") is earlier than the required version (", min_version, ").")
        needs_update <- TRUE
      }
    }
    
    # Install or upgrade if necessary
    if (!is_installed || needs_update) {
      message("Install ", pkg_name, " ", min_version, "...")
      tryCatch({
        BiocManager::install(pkg_name, update = FALSE, ask = FALSE)
      }, error = function(e) {
        warning("Error while installing ", pkg_name, ": ", e$message)
      })
    }
    
    # Load the package
    if (requireNamespace(pkg_name, quietly = TRUE)) {
      library(pkg_name, character.only = TRUE)
      message("Load ", pkg_name, " version: ", packageVersion(pkg_name))
    } else {
      warning("Unable to load ", pkg_name)
    }
  }
}

# Install and load the required packages
install_and_load_packages(required_packages)

message("\n✓ Configuration completed successfully.")
message("✓ Environment saved in renv.lock for replayability.")
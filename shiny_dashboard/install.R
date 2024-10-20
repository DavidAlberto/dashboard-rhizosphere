# Check if BiocManager is installed and install it if it's missing
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

################################################################################
# Install basic required packages if not available/installed.
################################################################################
install_missing_packages = function(pkg, version = NULL, verbose = TRUE) {
  # Check if package is already installed
  if (requireNamespace(pkg, quietly = TRUE)) {
    current_version <- packageVersion(pkg)
    if (!is.null(version) && compareVersion(as.character(current_version), version) < 0) {
      if (verbose) {
        message("Current version of package ", pkg, " (", current_version, ") is less than required (", version, "). Update will be attempted.")
      }
      BiocManager::install(pkg, update = FALSE)
    } else {
      if (verbose) {
        message("Package ", pkg, " is already installed with version ", current_version)
      }
    }
  } else {
    if (verbose) {
      message("The following package is missing: ", pkg, ". Installation will be attempted...")
    }
    BiocManager::install(pkg, update = FALSE)
  }
}

################################################################################
# Define list of package names and required versions.
################################################################################
deppkgs = c(phyloseq = "1.48.0",
            biomformat = "1.32.0",
            shiny = "1.9.1",
            shinythemes = "1.2.0", 
            ggplot2 = "3.5.1", 
            data.table = "1.16.0",
            networkD3 = "0.4",
            genefilter = "1.86.0", 
            grid = "4.4.1",
            gridExtra = "2.3", 
            markdown = "1.13", 
            rmarkdown = "2.28",
            png = "0.1-8", 
            RColorBrewer = "1.1-3",
            scales = "1.3.0")

# Loop on package check, install, update
pkg1 = mapply(install_missing_packages,
              pkg = names(deppkgs), 
              version = deppkgs,
              MoreArgs = list(verbose = TRUE), 
              SIMPLIFY = FALSE,
              USE.NAMES = TRUE)

################################################################################
# Load packages that must be fully-loaded 
################################################################################
for (i in names(deppkgs)) {
  library(i, character.only = TRUE)
  message(i, " package version: ", packageVersion(i))
}
################################################################################
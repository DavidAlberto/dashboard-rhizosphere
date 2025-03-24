# Set CRAN repository
options(repos = c(CRAN = "https://cran.rstudio.com/"))
options(browser = "firefox")

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

# Snapshot the environment
renv::snapshot(lockfile = "renv.lock", update = TRUE)
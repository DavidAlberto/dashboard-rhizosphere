# Set Shiny options
options(shiny.maxRequestSize = 100 * 1024^2)
options(shiny.reactlog = TRUE)

# Set deafult ggplot2 theme
theme_set(theme_bw())

# Principal Server function
## Store the inventory of objects
shinyPhyloseqServerObjectsList <- ls()
shinyServer(function(input, output) {
  ## Data and filtering panels
  source("panels/panel_server_data.R", local = TRUE)
  source("panels/panel_server_filter.R", local = TRUE)
  ## Reactive UI definition of variables
  rankNames <- reactive({
    rankNames <- as.list(rank_names(physeq(), errorIfNULL = FALSE))
    names(rankNames) <- rankNames
    return(rankNames)
  })
  variNames <- reactive({
    variNames <- as.list(sample_variables(physeq(), errorIfNULL = FALSE))
    names(variNames) <- variNames
    return(variNames)
  })
  vars <- function(type = "both", withnull = TRUE, singles = FALSE){
    if(!type %in% c("both", "taxa", "samples")){
      stop("incorrect `type` specification when accessing variables for UI.")
    }
    returnvars <- NULL
    if (type == "samples") {
      if (singles) {
        returnvars <- c(list(Sample = "Sample"), variNames())
      } else {
        returnvars <- variNames()
      }
    }
    if (type == "taxa") {
      if (singles) {
        returnvars <- c(rankNames(), list(OTU = "OTU"))
      } else {
        returnvars <- rankNames()
      }
    }
    if (type == "both") {
      if (singles) {
        returnvars <- c(rankNames(), variNames(),
                        list(OTU = "OTU", Sample = "Sample"))
      } else {
        returnvars <- c(rankNames(), variNames())
      }
    }
    if (withnull) {
      returnvars <- c(list("NULL" = "NULL"), returnvars)
    }
    return(returnvars)
  }
  uivar <- function(id, label = "Variable:", choices, selected = "NULL") {
    selectInput(inputId = id, label = label,
                choices = choices, selected = selected)
  }
  # Load other panel modules
  source("panels/panel_server_bar.R", local = TRUE)
  source("panels/panel_server_tree.R", local = TRUE)
  source("panels/panel_server_heatmap.R", local = TRUE)
  source("panels/panel_server_richness.R", local = TRUE)
  source("panels/panel_server_ordination.R", local = TRUE)
  source("panels/panel_server_net.R", local = TRUE)
  source("panels/panel_server_d3.R", local = TRUE)
  source("panels/panel_server_scatter.R", local = TRUE)
  source("panels/panel_server_palette.R", local = TRUE)
  source("panels/panel_server_provenance.R", local = TRUE)
})
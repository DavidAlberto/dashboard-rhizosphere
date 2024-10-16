################################################################################
# Options, default settings, and load packages
################################################################################
# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 100*1024^2)
# Set Shiny Reaction Log to TRUE
options(shiny.reactlog=TRUE)
# Default ggplot2 theme (Only relevant if panel-specific theme missing or NULL)
theme_set(theme_bw())
################################################################################
# Begin Shiny Server definition.
################################################################################
# First store the inventory of objects (for provenance record)
shinyPhyloseqServerObjectsList = ls()

shinyServer(function(input, output){
  # Data panel
  source("panels/panel_server_data.R", local = TRUE)
  # Filtering
  source("panels/panel_server_filter.R", local = TRUE)
  ########################################
  # Reactive UI Definition of Variables
  ########################################
  # Define data-reactive variable lists
  rankNames = reactive({
    rankNames = as.list(rank_names(physeq(), errorIfNULL=FALSE))
    names(rankNames) <- rankNames
    return(rankNames)
  })
  variNames = reactive({
    variNames = as.list(sample_variables(physeq(), errorIfNULL=FALSE))
    names(variNames) <- variNames
    return(variNames)
  })
  vars = function(type="both", withnull=TRUE, singles=FALSE){
    if(!type %in% c("both", "taxa", "samples")){
      stop("incorrect `type` specification when accessing variables for UI.")
    }
    returnvars = NULL
    if(type=="samples"){
      if(singles){
        returnvars <- c(list(Sample="Sample"), variNames())
      } else {
        returnvars <- variNames()
      }
    }
    if(type=="taxa"){
      if(singles){
        returnvars <- c(rankNames(), list(OTU="OTU"))
      } else {
        returnvars <- rankNames()
      }
    } 
    if(type=="both"){
      # Include all variables
      if(singles){
        returnvars <- c(rankNames(), variNames(), list(OTU="OTU", Sample="Sample"))
      } else {
        returnvars <- c(rankNames(), variNames())
      }
    }
    if(withnull){
      # Put NULL first so that it is default when `select` not specified
      returnvars <- c(list("NULL"="NULL"), returnvars)
    }
    return(returnvars)
  }
  # A generic selectInput UI. Plan is to pass a reactive argument to `choices`.
  uivar = function(id, label="Variable:", choices, selected="NULL"){
    selectInput(inputId=id, label=label, choices=choices, selected=selected)
  }
  # Bar
  source("panels/panel_server_bar.R", local = TRUE)
  # Tree
  source("panels/panel_server_tree.R", local = TRUE)
  # Heatmap
  source("panels/panel_server_heatmap.R", local = TRUE)
  # Richness
  source("panels/panel_server_richness.R", local = TRUE)
  # Ordination
  source("panels/panel_server_ordination.R", local = TRUE)
  # Network
  source("panels/panel_server_net.R", local = TRUE)
  # d3
  source("panels/panel_server_d3.R", local = TRUE)
  # Scatter
  source("panels/panel_server_scatter.R", local = TRUE)
  # Palette
  source("panels/panel_server_palette.R", local = TRUE)
  # Provenance
  source("panels/panel_server_provenance.R", local = TRUE)
})
################################################################################

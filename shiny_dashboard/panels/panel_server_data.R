################################################################################
# Define the available phyloseq datasets for plotting.
################################################################################
## Import data from .Rdata
get_loaded_data = reactive({
  if(!is.null(input$file1$name)){
    # Add uploaded data, if provided, and it is phyloseq-class.
    # Load user-data into a new environment (essentially sandbox)
    env_userdata = new.env()
    objectNames = load(input$file1$datapath, envir = env_userdata)
    loadedObjects = mget(objectNames, envir = env_userdata)
    arePhyloseq = sapply(loadedObjects, inherits, "phyloseq")
    if(any(arePhyloseq)){
      loadedObjects <- loadedObjects[which(arePhyloseq)]
    } else {
      loadedObjects <- NULL
    }
    datalist <<- c(loadedObjects, datalist)
  }
  return(NULL)
})
## Import data from .biom
get_biom_data = reactive({
  if(!is.null(input$filebiom$name)){
    # Loop through each uploaded file
    # Added uploaded data, if provided, and it is phyloseq-class.
    importedBiom = NULL
    importedBiom <- sapply(input$filebiom$name, function(i, x){
      ib = NULL
      junk = try(ib <- import_biom(x$datapath[x$name==i]), silent = TRUE)
      return(ib)
    }, x=input$filebiom, simplify = FALSE, USE.NAMES = TRUE)
    arePhyloseq = sapply(importedBiom, inherits, "phyloseq")
    if(any(arePhyloseq)){
      importedBiom <- importedBiom[which(arePhyloseq)]
    } else {
      importedBiom <- NULL
    }
    datalist <<- c(importedBiom, datalist)
  }
  return(NULL)
})  

## Update UI
output$phyloseqDataset <- renderUI({
  # Expect the side-effect of these functions to be to add
  # elements to the datalist, if appropriate
  get_loaded_data()
  get_biom_data()
  # get_qiime_data()
  # Process tree (and in principle, other components) last
  # process_uploaded_tree()
  return(
    selectInput("physeqSelect", "Select Dataset", names(datalist))
  )
})

## Obtain phyloseq object
get_phyloseq_data = reactive({
  ps0 = NULL
  if(!is.null(input$physeqSelect)){
    if(input$physeqSelect %in% names(datalist)){
      ps0 <- datalist[[input$physeqSelect]]
    }
  }
  if(inherits(ps0, "phyloseq")){
    return(ps0)
  } else {
    return(NULL)
  }
})

## Make plots about library sizes
output$library_sizes <- renderPlot({
  if(inherits(get_phyloseq_data(), "phyloseq")){
    libtitle = "Library Sizes"
    p1 = lib_size_hist() + ggtitle(libtitle)
    otusumtitle = "OTU Totals"
    p2 = otu_sum_hist() + ggtitle(otusumtitle)
    gridExtra::grid.arrange(p1, p2, ncol=2)
  } else {
    fail_gen("")
  }
})

## Make menu about components
output$uix_available_components_orig <- renderUI({
  selectInput("available_components_orig", "Available Components",
              choices = component_options(get_phyloseq_data()))
})

## Render the user-selected data component using DataTables
output$ps0ComponentTable <- DT::renderDT({
  if(is.null(av(input$available_components_orig))){
    return(NULL)
  }
  component = do.call(what = input$available_components_orig, args = list(get_phyloseq_data()))
  return(tablify_phyloseq_component(component, input$component_table_colmax))
}, options = list(
  pageLength = 5 
))
################################################################################

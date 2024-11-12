# D3 Network Panel Server
## Define UIX Color
output$d3_uix_color <- renderUI({
  selectInput(inputId = "color_d3",
              label = "Color",
              choices = vars(input$type_d3, TRUE, TRUE),
              selected = d3NetworkColorVar)
})

## Define UIX Node label
output$d3_uix_node_label <- renderUI({
  selectInput(inputId = "d3_node_label",
              label =  "Label",
              choices = vars(input$type_d3, TRUE, TRUE),
              selected = d3NodeLabelVar,
              multiple = TRUE)
})

## Input phyloseq object
physeq_d3 <- reactive({
  return(
    switch({input$transform_d3},
      Counts = physeq(),
      Prop = physeqProp(),
      RLog = physeqRLog(),
      CLR = physeqCLR(),
      physeq()
    )
  )
})

## Define global reactive distance matrix
## Re-calc only if method or plot-type change
d3distReact <- reactive({
  idist <- NULL
  try({idist <- scaled_distance(physeq_d3(),
                                method = input$dist_d3,
                                type = input$type_d3,
                                rescaled = TRUE)},
      silent = TRUE)
  if (is.null(idist)) {warning("d3dist: Could not calculate distance matrix with these settings.")}
  return(idist)
})

## Calculate links data
calculate_links_data <- reactive({
  LinksData <- dist_to_edge_table(d3distReact(),
                                  input$dist_d3_threshold,
                                  c("Source", "target"))
  nodeUnion <- union(LinksData$Source, LinksData$target)
  d3lookup <- (0:(length(nodeUnion) - 1))
  names(d3lookup) <- nodeUnion
  LinksData[, Source := d3lookup[Source]]
  LinksData[, target := d3lookup[target]]
  setkey(LinksData, Source)
  if (input$type_d3 == "taxa") {
    NodeData <- data.frame(OTU = nodeUnion,
                           tax_table(physeq_d3())[nodeUnion, ],
                           stringsAsFactors = FALSE)
  } else {
    NodeData <- data.frame(Sample = nodeUnion,
                           sample_data(physeq_d3())[nodeUnion, ],
                           stringsAsFactors = FALSE)
  }
  NodeData$ShowLabels <- apply(NodeData[, input$d3_node_label, drop = FALSE], 1, paste0, collapse = "; ")
  return(list(link = data.frame(LinksData), node = NodeData))
})

## Default Source
default_Source <- function(x){
  if (is.null(av(x))) {
    if (input$type_d3 == "taxa") {
      return("OTU")
    } else {
      return("Sample")
    }
  } else {
    return(x)
  }
}

## Wrapper function for Shiny-phyloseq D3 Network definition.
output$D3Network <- renderForceNetwork({
  forceNetwork(Links = calculate_links_data()$link,
               Nodes = calculate_links_data()$node,
               Source = "Source",
               Target = "target",
               Value = "Distance",
               NodeID = "ShowLabels",
               Group = default_Source(input$color_d3),
               linkColour = input$d3_link_color,
               opacity = input$d3_opacity)
})
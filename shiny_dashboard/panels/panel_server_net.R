# Network Panel Server
## Define UIX available layouts
available_layouts_net <- list(
  auto = igraph::layout.auto,
  random = igraph::layout.random,
  circle = igraph::layout.circle,
  sphere = igraph::layout.sphere,
  fruchterman.reingold = igraph::layout.fruchterman.reingold,
  kamada.kawai = igraph::layout.kamada.kawai,
  spring = igraph::layout.spring,
  reingold.tilford = igraph::layout.reingold.tilford,
  fruchterman.reingold.grid = igraph::layout.fruchterman.reingold.grid,
  lgl = igraph::layout.lgl,
  graphopt = igraph::layout.graphopt,
  svd = igraph::layout.svd
)

## Define UIX Layout
output$net_uix_layout <- renderUI({
  selectInput(inputId = "layout_net",
              label = "Layout",
              choices = names(available_layouts_net),
              selected = "fruchterman.reingold")
})

## Define UIX Color
output$net_uix_color <- renderUI({
  uivar(id = "color_net",
        label = "Color",
        choices = vars(input$type_net))
})

## Define UIX Shape
output$net_uix_shape <- renderUI({
  uivar(id = "shape_net",
        label = "Shape",
        choices = vars(input$type_net))
})

## Define UIX Label
output$net_uix_label <- renderUI({
  selectInput(inputId = "label_net",
              label = "Label",
              choices = vars(input$type_net, TRUE, TRUE),
              selected = default_netLabel,
              multiple = TRUE)
})

## Define UIX Edge Slider
output$net_uix_edgeSlider <- renderUI({
  uinetdispdist <- sliderInput(inputId = "uinetdispdist",
                               label = "Draw Max.",
                               min = 0.0,
                               max = input$uinetdistmax,
                               value = input$uinetdistmax,
                               step = input$uinetdistmax / animation_steps,
                               animate = animationOptions(
                                playButton = "Play",
                                pauseButton = "Pause",
                                interval = interval,
                                loop = loop))
})

## Static Network Plot using ggplot2
## 0.Input phyloseq object
physeq_net <- reactive({
  return(
    switch({input$transform_net},
      Counts = physeq(),
      Prop = physeqProp(),
      RLog = physeqRLog(),
      CLR = physeqCLR(),
      physeq()
    )
  )
})

## 1.Calculate Distance
Distance_net <- reactive({
  idist <- NULL
  try({idist <- scaled_distance(physeq = physeq_net(),
                                method = input$dist_net,
                                type = input$type_net,
                                rescaled = TRUE)},
      silent = TRUE)
  if (is.null(idist)) {
    warning("Distance_net: Could not calculate distance matrix with these settings.")}
  return(idist)
})

## 2.Create edge table
LinksData0 <- reactive({
  dist_to_edge_table(Dist = Distance_net(),
                     MaxDistance = input$uinetdistmax)
})

## 3. Create vertex layout
vertex_layout <- function(LinksData, physeq = NULL, type = "samples",
                          laymeth = igraph::layout.fruchterman.reingold,
                          RNGseed = input$RNGseed_net, ...) {
  set.seed(as(RNGseed, "integer"))
  g <- igraph::graph.data.frame(LinksData, directed = FALSE)
  vertexDT <- data.table(laymeth(g, ...),
                         vertex = igraph::get.vertex.attribute(g, "name"))
  setkey(vertexDT, vertex)
  setnames(vertexDT, old = c(1, 2), new = c("x", "y"))
  extraData <- NULL
  if (type == "samples" & !is.null(sample_data(physeq, FALSE))) {
    extraData <- data.table(data.frame(sample_data(physeq)),
                            key = "rn", keep.rownames = TRUE)
  } else if (type == "taxa" & !is.null(tax_table(physeq, FALSE))) {
    extraData <- data.table(as(tax_table(physeq), "matrix"),
                            key = "rn", keep.rownames = TRUE)
  }
  if (!is.null(extraData)) {
    setnames(extraData, old = "rn", new = "vertex")
    vertexDT <- vertexDT[extraData]
    vertexDT <- vertexDT[!is.na(x), ]
  }
  return(vertexDT)
}

## Define vertexDT
vertexDT <- reactive({
  if (is.null(av(input$layout_net))) {
    return(vertex_layout(LinksData0(), physeq_net(), type = input$type_net))
  }
  return(
    vertex_layout(LinksData0(), physeq_net(),
                  type = input$type_net,
                  laymeth = available_layouts_net[[input$layout_net]])
  )
})
# 4.Update the links layout for ggplot, x, y, xend, yend
link_layout <- function(LinksData, vertexDT) {
  linkstart <- vertexDT[LinksData$v1, x, y]
  linkend <- vertexDT[LinksData$v2, x, y]
  setnames(linkend, old = c("y", "x"), new = c("yend", "xend"))
  LinksData <- cbind(LinksData, linkstart, linkend)
  return(LinksData)
}
LinksData <- reactive({
  link_layout(LinksData0(), vertexDT())
})

## 5.Define ggplot2 network plot
links_to_ggplot <- function(LinksData, vertexDT, vertmap = aes(x, y),
                            vert_size = NULL, vert_alpha = NULL){
  p0 <- ggplot(data = LinksData) +
    geom_segment(aes(x = x, y = y, xend = xend, yend = yend,
                     size = Distance, alpha = Distance)) +
    geom_point(mapping = vertmap,
               data = vertexDT,
               size = vert_size,
               alpha = vert_alpha) +
    scale_alpha(range = c(1, 0.1)) +
    scale_size(range = c(2, 0.25))
  net_theme <- theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_blank()
  )
  p0 <- p0 + net_theme
  return(p0)
}

## Define p_net
p_net <- reactive({
  vertmap <- aes_string(x = "x", y = "y", colour = av(input$color_net),
                        shape = av(input$shape_net))
  links_to_ggplot(LinksData(), vertexDT(), vertmap,
                  vert_size = av(input$size_net),
                  vert_alpha = av(input$alpha_net))
})

## Define p_net_label
p_net_label <- reactive({
  NodeData <- vertexDT()
  if (is.null(av(input$label_net)) |
        !all(input$label_net %in% colnames(NodeData))) {
    return(p_net())
  }
  NodeData$ShowLabels <- apply(NodeData[, input$label_net, with = FALSE],
                               1, paste0, collapse = "; ")
  return(p_net() + geom_text(aes(x = x, y = y, label = ShowLabels),
                             data = NodeData,
                             size = input$label_size_net,
                             vjust = input$label_vjust_net,
                             na.rm = TRUE))
})

## 6.Reactive update to ggplot
p_net_update <- reactive({
  p <- p_net_label()
  p$data <- LinksData()[Distance < input$uinetdispdist, ]
  return(p)
})

## 7.Finalize network plot
finalize_network_plot <- reactive({
  fpnet <- p_net_update()
  if (!is.null(av(input$color_net))) {
    if (plyr::is.discrete(fpnet$layers[[2]]$data[[input$color_net]])) {
      # Discrete brewer palette mapping
      fpnet <- fpnet + scale_colour_brewer(palette = input$pal_net)
    } else {
      # Continuous brewer palette mapping
      fpnet <- fpnet + scale_colour_distiller(palette = input$pal_net)
    }
  }
  return(fpnet)
})

## Render plot in panel
output$network <- renderPlot({
  shiny_phyloseq_print(finalize_network_plot())
},
width = function() {72 * input$width_net},
height = function() {72 * input$height_net})

## Downloadable file
output$download_net <- downloadHandler(
  filename = function() {paste0("Network_", simpletime(), ".", input$downtype_net)},
  content = function(file) {
    ggsave2(filename = file,
            plot = finalize_network_plot(),
            device = input$downtype_net,
            width = input$width_net,
            height = input$height_net,
            dpi = 300L,
            units = "in")
  }
)
# Scatter Panel Server
## Input phyloseq object
physeq_scat <- reactive({
  return(
    switch({input$transform_scat},
      Counts = physeq(),
      Prop = physeqProp(),
      RLog = physeqRLog(),
      CLR = physeqCLR(),
      physeq()
    )
  )
})

## Convert phyloseq object to data.frame
scatdf <- reactive({
  return(psmelt(physeq_scat()))
})

## Define UIX Metadata X
output$scat_uix_x <- renderUI({
  selectInput(inputId = "x_scat",
              label = "Metadata X",
              choices = as.list(c("NULL", names(scatdf()))),
              selected = "Sample")
})

## Define UIX Metadata Y
output$scat_uix_y <- renderUI({
  selectInput(inputId = "y_scat",
              label = "Metadata Y",
              choices = as.list(c("NULL", names(scatdf()))),
              selected = "Abundance")
})

## Define UIX Color
output$scat_uix_color <- renderUI({
  selectInput(inputId = "color_scat",
              label = "Color",
              choices = as.list(c("NULL", names(scatdf()))))
})

## Define UIX Shape
output$scat_uix_shape <- renderUI({
  selectInput(inputId = "shape_scat",
              label = "Shape",
              choices = as.list(c("NULL", names(scatdf()))))
})

## Define UIX Facet Row
output$scat_uix_facetrow <- renderUI({
  selectInput(inputId = "facetrow_scat",
              label = "Facet Row",
              choices = vars("both"),
              selected = "NULL",
              multiple = TRUE)
})

## Define UIX Facet Col
output$scat_uix_facetcol <- renderUI({
  selectInput(inputId = "facetcol_scat",
              label = "Facet Col",
              choices = vars("both"),
              selected = "NULL",
              multiple = TRUE)
})

## Define UIX Label
output$scat_uix_label <- renderUI({
  selectInput(inputId = "label_scat",
              label = "Label",
              choices = vars("both"),
              selected = "NULL")
})

## Flexible Scatter plot
make_scatter_plot <- reactive({
  pscat <- NULL
  try({
    scatmap <- aes_string(x = av(input$x_scat),
                          y = av(input$y_scat),
                          color = av(input$color_scat),
                          shape = av(input$shape_scat))
    pscat <- ggplot(data = scatdf(),
                    mapping = scatmap) + geom_point()
    pscat <- pscat + theme(axis.text.x = element_text(angle = -90, vjust = 0.5, hjust = 0))
    pscat_facet_form <- get_facet_grid(input$facetrow_scat, input$facetcol_scat)
    if (!is.null(pscat_facet_form)) {
      pscat <- pscat + facet_grid(pscat_facet_form)
    }
  }, silent = TRUE)
  return(pscat)
})

## Finalize scatter plot
finalize_scatter_plot <- reactive({
  pscat <- make_scatter_plot()
  if (inherits(pscat, "ggplot")) {
    if (!is.null(av(input$label_scat))) {
      pscat <- pscat + geom_text(aes_string(label = input$label_scat),
                                 size = input$label_size_scat,
                                 vjust = input$label_vjust_scat)
    }
    pscat$layers[[1]]$geom_params$size <- input$size_scat
    pscat$layers[[1]]$geom_params$alpha <- input$alpha_scat
    if (!is.null(av(input$color_scat))) {
      if (plyr::is.discrete(pscat$data[[input$color_scat]])) {
        # Discrete brewer palette mapping
        pscat <- pscat + scale_colour_brewer(palette = input$pal_scat)
      } else {
        # Continuous brewer palette mapping
        pscat <- pscat + scale_colour_distiller(palette = input$pal_scat)
      }
    }
    pscat <- pscat + shiny_phyloseq_ggtheme_list[[input$theme_scat]]
    return(pscat)
  } else {
    return(fail_gen())
  }
})

## Render plot
output$scatter <- renderPlot({
  shiny_phyloseq_print(finalize_scatter_plot())
},
width = function() {72 * input$width_scat},
height = function() {72 * input$height_scat})

## Downloadable file
output$downloadScatter <- downloadHandler(
  filename = function(){paste0("Scatter_", simpletime(), ".", input$downtype_scat)},
  content = function(file) {
    ggsave2(filename = file,
            plot = finalize_scatter_plot(),
            device = input$downtype_scat,
            width = input$width_scat,
            height = input$height_scat,
            dpi = 300L,
            units = "in")
  }
)
# Bar Panel Server
## Define UIX X-Axis
output$bar_uix_xvar <- renderUI({
  selectInput(inputId = "x_bar",
              label = "X-Axis",
              choices = vars("both", TRUE, TRUE),
              selected = "Sample")
})

## Define UIX Color
output$bar_uix_colvar <- renderUI({
  selectInput(inputId = "color_bar",
              label = "Color",
              choices = vars("both"))
})

## Define UIX Facet Row
output$bar_uix_facetrow <- renderUI({
  selectInput(inputId = "facetrow_bar",
              label = "Facet Row",
              choices = vars("both"),
              multiple = TRUE)
})

## Define UIX Facet Col
output$bar_uix_facetcol <- renderUI({
  selectInput(inputId = "facetcol_bar",
              label = "Facet Col",
              choices = vars("both"),
              multiple = TRUE)
})

## Bar plot definition
physeq_bar <- reactive({
  return(switch({input$uicttype_bar},
                Counts = physeq(),
                Prop = physeqProp()))
})

## Make bar plot
make_bar_plot <- reactive({
  p0 <- NULL
  try(p0 <- plot_bar(physeq_bar(),
                     x = input$x_bar,
                     y = "Abundance",
                     fill = av(input$color_bar),
                     facet_grid = get_facet_grid(input$facetrow_bar,
                                                 input$facetcol_bar)),
      silent = TRUE)
  if (!inherits(p0, "ggplot")) {
    warning("Could not render bar plot, attempting without faceting...")
    try(p0 <- plot_bar(physeq_bar(),
                       x = xvar,
                       y = "Abundance",
                       fill = av(input$color_bar)),
        silent = TRUE)
  }
  return(p0)
})

## Finalize bar plot
finalize_bar_plot <- reactive({
  if (input$actionb_bar < 1) {
    p0 <- fail_gen("Change settings and/or click '(Re)Build Graphic' Button")
  }
  isolate({
    p0 <- make_bar_plot()
  })
  p0 <- p0 + scale_fill_brewer(palette=input$pal_bar) +
    shiny_phyloseq_ggtheme_list[[input$theme_bar]]
  p0 <- p0 +
    theme(axis.text.x = element_text(angle = input$x_axis_angle_bar,
                                     vjust = 0.5,
                                     hjust = 1)
    )
  return(p0)
})

## Render plot in panel
output$bar <- renderPlot({
  shiny_phyloseq_print(finalize_bar_plot())
},
width = function() {72 * input$width_bar},
height = function() {72 * input$height_bar})

## Downloadable file
output$download_bar <- downloadHandler(
  filename = function(){paste0("Barplot_", simpletime(), ".", input$downtype_bar)},
  content = function(file) {
    ggsave2(filename = file,
            plot = finalize_bar_plot(),
            device = input$downtype_bar,
            width = input$width_bar,
            height = input$height_bar,
            dpi = 300L,
            units = "in")
  }
)
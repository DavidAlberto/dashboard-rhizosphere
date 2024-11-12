# Richness Panel Server
## Define the UIX metadata
output$rich_uix_x <- renderUI({
  selectInput(inputId = "x_rich",
              label = "Metadata",
              choices = c(list("samples"), vars("samples")),
              selected = "samples")
})

## Define the UIX color
output$rich_uix_color <- renderUI({
  selectInput(inputId = "color_rich",
              label = "Color",
              choices = c(list("samples"), vars("samples")),
              selected = "NULL")
})

## Define the UIX shape
output$rich_uix_shape <- renderUI({
  selectInput(inputId = "shape_rich",
              label = "Shape",
              choices = c(list("samples"), vars("samples")),
              selected = "NULL")
})

## Define the UIX label
output$rich_uix_label <- renderUI({
  selectInput(inputId = "label_rich",
              label = "Label",
              choices = c(list("samples"), vars("samples")),
              selected = "NULL")
})

# Alpha Diversity plot definition
physeq_rich <- reactive({
  return(switch(input$uicttype_rich,
                Original = get_phyloseq_data(),
                Filtered = physeq()))
})

# Make richness plot
make_richness_plot <- reactive({
  p4 <- NULL
  try(p4 <- plot_richness(physeq_rich(), measures = input$measures_rich),
      silent = TRUE)
  return(p4)
})

# Finalize richness plot
finalize_richness_plot <- reactive({
  p4 <- make_richness_plot()
  if (inherits(p4, "ggplot")) {
    p4$layers[[1]]$geom_params$size <- input$size_rich
    p4$layers[[1]]$geom_params$alpha <- input$alpha_rich
    if (length(p4$layers) >= 2) {
      p4$layers[[2]]$geom_params$alpha <- input$alpha_rich
    }
    if (!is.null(av(input$x_rich))) {
      p4$mapping$x <- as.symbol(input$x_rich)
      p4 <- update_labels(p4, list(x = input$x_rich))
    }
    if (!is.null(av(input$shape_rich))) {
      p4$mapping$shape <- as.symbol(input$shape_rich)
      p4 <- update_labels(p4, list(shape = input$shape_rich))
    }
    if (!is.null(av(input$color_rich))) {
      p4$mapping$colour <- as.symbol(input$color_rich)
      p4 <- update_labels(p4, list(colour = input$color_rich))
      if (plyr::is.discrete(p4$data[[input$color_rich]])) {
        p4 <- p4 + scale_colour_brewer(palette = input$pal_rich)
      } else {
        p4 <- p4 + scale_colour_distiller(palette = input$pal_rich)
      }
    }
    if (!is.null(av(input$label_rich))) {
      p4 <- p4 + geom_text(aes_string(label = input$label_rich),
                           size = input$label_size_rich,
                           vjust = input$label_vjust_rich)
    }
    p4 <- p4 + shiny_phyloseq_ggtheme_list[[input$theme_rich]]
    p4 <- p4 + theme(axis.text.x = element_text(angle = input$x_axis_angle_rich, vjust = 0.5))
    if (!is.null(av(input$x_rich))) {
      if (plyr::is.discrete(p4$data[[input$x_rich]])) {
        if (length(unique(p4$data[[input$x_rich]])) > input$label_max_rich) {
          p4 <- p4 + theme(axis.text.x = element_blank(),
                           axis.ticks.x = element_blank())
        }
      }
    }
    return(p4)
  } else {
    return(fail_gen())
  }
})

# Render plot and downloadable file
output$richness <- renderPlot({
  shiny_phyloseq_print(finalize_richness_plot())
  },
width = function() {72 * input$width_rich},
height = function() {72 * input$height_rich}
)

# Downloadable file
output$download_rich <- downloadHandler(
  filename <- function() {paste0("Richness_", simpletime(), ".", input$downtype_rich)},
  content <- function(file) {
    ggsave2(filename = file,
            plot = finalize_richness_plot(),
            device = input$downtype_rich,
            width = input$width_rich,
            height = input$height_rich,
            dpi = 300L, units = "in")
  }
)
# Ordination Panel Server
## Define the variables category that should be shown in UIX
get_type_vars <- reactive({
  switch({input$ord_plot_type},
         sites = "samples",
         species = "taxa",
         biplot = "both",
         split = "both",
         selected = "samples")
})

## Define the UIX color
output$ord_uix_color <- renderUI({
  selectInput(inputId = "color_ord",
              label = "Color",
              choices = vars(get_type_vars()),
              selected = "NULL")
})

## Define the UIX shape
output$ord_uix_shape <- renderUI({
  selectInput(inputId = "shape_ord",
              label = "Shape",
              choices = vars(get_type_vars()),
              selected = "NULL")
})

## Define the UIX constraint
output$ord_uix_constraint <- renderUI({
  selectInput(inputId = "constraint_ord",
              label = "Constraint",
              choices = vars(get_type_vars()),
              selected = "NULL",
              multiple = TRUE)
})

## Define the UIX facetrow
output$ord_uix_facetrow <- renderUI({
  selectInput(inputId = "facetrow_ord",
              label = "Facet Row",
              choices = vars(get_type_vars()),
              selected = "NULL",
              multiple = TRUE)
})

## Define the UIX facetcol
output$ord_uix_facetcol <- renderUI({
  selectInput(inputId = "facetcol_ord",
              label = "Facet Col",
              choices = vars(get_type_vars()),
              selected = "NULL",
              multiple = TRUE)
})

## Define the UIX label
output$ord_uix_label <- renderUI({
  selectInput(inputId = "label_ord",
              label = "Label",
              choices = vars(get_type_vars()),
              selected = "NULL")
})

## Define the UIX distance
output$ord_uix_dist <- renderUI({
  if (input$ord_method %in% c("DCA", "CCA", "RDA", "DPCoA")) {
    return(selectInput(inputId = "dist_ord",
                       label = tags$del("Distance"),
                       selected = "NULL"))
  }
  return(selectInput(inputId = "dist_ord",
                     label = "Distance",
                     choices = distlist,
                     selected = "bray"))
})

## Input phyloseq object
physeq_ord <- reactive({
  return(
    switch({input$transform_ord},
      Counts = physeq(),
      Prop = physeqProp(),
      RLog = physeqRLog(),
      CLR = physeqCLR(),
      physeq()
    )
  )
})

## Define the formula for the constraint
get_formula_ord <- reactive({
  if (is.null(av(input$constraint_ord))) {
    return(NULL)
  } else {
    formstring <- paste("~", paste(input$constraint_ord, collapse = "+"))
    return(as.formula(formstring))
  }
})

## Define the "type" argument passed to ordinate function,
## then to distance function, if applicable
get_type_ord <- reactive({
  switch(input$ord_plot_type,
         species = "taxa",
         selected = "samples")
})

## Define the ordination
get_ord <- reactive({
  ord <- try(ordinate(physeq_ord(),
                      method = input$ord_method,
                      distance = input$dist_ord,
                      formula = get_formula_ord(),
                      type = get_type_ord()),
             silent = TRUE)
  if (inherits(ord, "try-error")) {
    ord <- try(ordinate(physeq_ord(),
                        method = input$ord_method,
                        distance = input$dist_ord,
                        formula = get_formula_ord()),
               silent = TRUE)
  }
  if (inherits(ord, "try-error")) {
    ord <- try(ordinate(physeq_ord(),
                        method = input$ord_method,
                        distance = input$dist_ord),
               silent = TRUE)
  }
  if (inherits(ord, "try-error")) {
    warning(ord)
    ord <- NULL
  }
  return(ord)
})

## Make ordination plot
make_ord_plot <- reactive({
  p1 <- NULL
  try(p1 <- plot_ordination(physeq = physeq_ord(),
                            ordination = get_ord(),
                            type = input$ord_plot_type,
                            axes = c(as.integer(input$axis_x_ord),
                                     as.integer(input$axis_y_ord)),
                            color = av(input$color_ord),
                            shape = av(input$shape_ord)),
      silent = TRUE)
  return(p1)
})

## Finalize Ordination Plot (for download and panel)
finalize_ordination_plot <- reactive({
  p1 <- make_ord_plot()
  if (inherits(p1, "ggplot")) {
    p1$layers[[1]] <- NULL
    p1 <- p1 + geom_point(size = av(input$size_ord),
                          alpha = av(input$alpha_ord))
    if (!is.null(av(input$color_ord))) {
      if (plyr::is.discrete(p1$data[[input$color_ord]])) {
        # Discrete brewer palette mapping
        p1 <- p1 + scale_colour_brewer(palette = input$pal_ord)
      } else {
        # Continuous brewer palette mapping
        p1 <- p1 + scale_colour_distiller(palette = input$pal_ord)
      }
    }
    if (!is.null(av(input$label_ord))) {
      p1 <- p1 + geom_text(aes_string(label = input$label_ord),
                           size = input$label_size_ord,
                           vjust = input$label_vjust_ord)
    }
    p1ord_facet_form <- get_facet_grid(input$facetrow_ord, input$facetcol_ord)
    if (!is.null(p1ord_facet_form)) {
      p1 <- p1 + facet_grid(p1ord_facet_form)
    }
    p1 <- p1 + shiny_phyloseq_ggtheme_list[[input$theme_ord]]
  }
  return(p1)
})

## Render plot
output$ordination <- renderPlot({
  pscree <- NULL
  try(pscree <- plot_ordination(physeq = physeq_ord(),
                                ordination = get_ord(),
                                type = "scree",
                                title = "Scree Plot"),
      silent = TRUE)
  pOrd <- finalize_ordination_plot()
  arglist <- list(pOrd, pscree, ncol = 1, heights = c(5, 2))
  arglist <- arglist[!sapply(arglist, is.null,
                             simplify = TRUE, USE.NAMES = FALSE)]
  do.call("grid.arrange", args = arglist)
},
width = function() {72 * input$width_ord},
height = function() {72 * input$height_ord})

## Downloadable file
output$download_ord <- downloadHandler(
  filename = function() {
    paste0("Ordination_", simpletime(), ".", input$downtype_ord)},
  content = function(file) {
    ggsave2(filename = file,
            plot = finalize_ordination_plot(),
            device = input$downtype_ord,
            width = input$width_ord,
            height = input$height_ord,
            dpi = 300L,
            units = "in")
  }
)
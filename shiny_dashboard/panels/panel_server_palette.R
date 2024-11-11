# Color Palette Panel Server
## Define UIX Palette
output$paletteOptions <- renderPlot({
  ColBrewTypes <- levels(RColorBrewer::brewer.pal.info$category)
  names(ColBrewTypes) <- c("Diverging", "Qualitative", "Sequential")
  par(mfcol = c(1, 3))
  for (i in ColBrewTypes) {
    RColorBrewer::display.brewer.all(type = i)
    title(names(ColBrewTypes)[ColBrewTypes == i])
  }
})

## Define example dataset
palExData <- ggplot2::diamonds[sample(nrow(ggplot2::diamonds), 1000), ]
output$paletteExample <- renderPlot({
  dpal <- ggplot(data = palExData, aes(x = carat,
                                       y = price,
                                       colour = clarity)) +
    geom_point(size = 10) +
    ggtitle(paste("Example Output,", input$pal_main, "Palette"))
  dpal <- dpal + scale_colour_brewer(palette = input$pal_pal)
  dpal <- dpal + shiny_phyloseq_ggtheme_list[[input$theme_pal]]
  print(dpal)
})
output$paletteTable <- DT::renderDT({
  SupportedPalTab <- RColorBrewer::brewer.pal.info
  SupportedPalTab <- data.frame(Palette = rownames(SupportedPalTab), SupportedPalTab)
  colnames(SupportedPalTab)[2:3] <- c("Max_Colors", "Category")
  return(SupportedPalTab)
})

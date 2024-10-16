# Heatmap Panel Details

This panel provides an interface to 
[phyloseq](http://joey711.github.io/phyloseq)'s
[plot_heatmap function](http://joey711.github.io/phyloseq/plot_heatmap-examples.html).

### Structure

This top section defines key aspects of 
the ordination calculation that determines axis ordering.
This includes the distance used in the ordination (if applicable),
and the method used to decompose that distance into axes.

- **Method** - The Ordination Method to use. This is an interface to
phyloseq's [ordinate function](http://joey711.github.io/phyloseq/ordinate).
- **Distance** - The distance method. This is a direct interface to phyloseq's
[distance function](http://joey711.github.io/phyloseq/distance).
- **Transform** - This option is very important.
It determines whether to use filtered-counts, 
or some transformation of the filtered count values
in both the ordination and in the color-scale transformation shown in the graphic.
See the `Transform` panel for the definition of each available option.

### Labels

This provides you with the option of selecting an alternative label from among sample variables and taxonomic ranks.

- **Samples** - Choose from among sample variables, if available, that will replace the index name for each sample.
- **Taxa** - Choose from among taxonomic ranks, if available, that will replace the index name for each OTU.

### Manual Ordering

This provides you with the option of selecting an alternative ordering
of one or both indices based on available variables.

- **Samples** - Choose from among sample variables, if available, that will be used to re-order the sample columns.
- **Taxa** - Choose from among taxonomic ranks, if available, that will be used to re-order the OTU rows.

### Color Scale

These widgets define the Low, High, and Missing-Value colors in the heatmap.
Standard R color names and hexadecimal colors are supported.

### Dimensions and Downloads

Figure dimensions (in inches), file format, and download button (`DL`).



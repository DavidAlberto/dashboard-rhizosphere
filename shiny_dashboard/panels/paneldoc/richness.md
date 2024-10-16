# Richness Panel

This panel is based on phyloseq's 
[plot_richness function](http://joey711.github.io/phyloseq/plot_richness-examples.html).

Although the function name includes the word *richness*, 
which usually refers to the total number of species/OTUs
in a sample or environment -- either observed or estimated -- 
this panel and its underlying function are intended for
estimating and plotting alpha diversity in general.

## Sidebar Widget Details

### Aesthetic Mapping

The aesthetic mapping is intended to help annotate and organize
the alpha-diversity results for easier comprehension.

- **X-Axis** - The variable selected here is mapped to the horizontal ("X") axis.
The default selection is `"Sample"`,
which means every sample gets a separate discrete position on the horizontal axis.
The "Y" axis is always mapped to the respective alpha-diversity value.
- **Color** - The variable selected here is mapped to the color shade of points.
Take care that selected discrete variables
do not surpass the number of available aesthetic categories
(e.g. more categories in data than you have color shades).
- **Shape** - The variable selected here is mapped to point shape.
Use the same care as for `Color`, but note that there are only 6 different shapes.
- **Alpha Measures** - Select one or more alpha-diversity measures.
They will be plotted as separate panels side-by-side.
- **Label** - A variable to map to point label.
The text at each point will reflect the value of the chosen variable.
The small numeric widgets to the right adjust
label size (`Lab Sz`) and vertical justification (`V-Just`).

### Details

`Palette`, `Size`, and `Opacity` - refer to the way points are drawn.

- **Palette** - Refers to color palette.
Only applicable if you have selected a `Color` variable
in the Aesthetic Mapping section.
Explore the `Palette` panel within Shiny-phyloseq,
or more details about color palettes at [ColorBrewer](http://colorbrewer2.org/).
- **Theme** - For the most part these refer to
[ggplot2 themes](http://docs.ggplot2.org/0.9.2.1/theme.html),
which generally encompass stylistic graphical features,
such as axis line types, axis label fonts and spacing, background color, etc.
- **Size** - This refers to point size.
- **Opacity** - The transparency of points in the graphic,
on a `[0, 1]` scale;
with zero meaning so transparent points are invisible,
and one meaning points are perfectly opaque (the default).
- **Max. Labels** - Maximum number of X-axis labels. Discrete-variable only.
If number of X-axis discrete categories exceeds this value,
then no axis labels are shown.
- **Angle** - This refers to the label angle for the horizontal X-axis.
- **Source Data** - What stage of data to include. Original unfiltered counts are recommended.

### Dimensions and Downloads

Figure dimensions (in inches), file format, and download button (`DL`).

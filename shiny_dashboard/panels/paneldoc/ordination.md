# Ordination Panel Details

This panel provides an interface to 
[phyloseq](http://joey711.github.io/phyloseq)'s
[plot_ordination function](http://joey711.github.io/phyloseq/plot_ordination-examples.html).

## Widget Sections

### Structure

This top section defines key aspects of 
the ordination calculation.
This includes the distance on which it is based,
the method used to decompose that distance
into axes for graphical exploration,
and which features of the ordination result to display.

- **Type** - Toggle between a network with Samples or Taxa as nodes. 
- **Method** - The Ordination Method to use. This is an interface to
phyloseq's [ordinate function](http://joey711.github.io/phyloseq/ordinate).
- **Distance** - The distance method. This is a direct interface to phyloseq's
[distance function](http://joey711.github.io/phyloseq/distance).
- **Display** - The ordination display type.
This is equivalent to the `type` argument in 
the [plot_ordination function](http://joey711.github.io/phyloseq/plot_ordination-examples.html).
- **Constraint** - The variables to include for constrained ordination.
Multiple non-`NULL` variables are combined in a formula.
e.g. `~ Var1 + Var2 + Var3`.
Not that for ordination constraints only the right-hand side is relevant.
Generally speaking, this is less flexible than a full
[formula interface](http://cran.r-project.org/doc/manuals/r-release/R-intro.html#Formulae-for-statistical-models).
For conditioning variables, explicit interaction terms,
and other features of R formulae, please use phyloseq/R directly.
- **Transform** - This option is very important.
It determines whether to use filtered-counts, 
or some transformation of the filtered count values.
See the `Transform` panel for the definition of each available option.

### Aesthetic Mapping

- **X, Y** - Select the ordination axes to map to the
`X` (horizontal) and `Y` (vertical) axes. Default is first and second ordination axes, respectively.
- **Color** - The variable selected here is mapped to point color.
- **Shape** - The variable selected here is mapped to point shape.
- **Facet Row** - This is an interface to
[ggplot2's facet_grid function](http://docs.ggplot2.org/0.9.3.1/facet_grid.html).
Faceting is a means of splitting the data into separate panels
according to one or more variables in the data.
This can have many advantages, especially to alleviate overplotting,
and to clarify key comparisons.
In this case, the `Facet Row` widget provides available variables
that will be mapped to panel-rows in the resulting grid of facets panels.
You can select more than one variable.
You should delete/unselect NULL when selecting facets.
- **Facet Col** - This is the same as `Facet Row` above,
but this widget controls the variables that will arrange the data
into panel columns.
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

### Dimensions and Downloads

Figure dimensions (in inches), file format, and download button (`DL`).



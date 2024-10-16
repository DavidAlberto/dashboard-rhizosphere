# [D3](http://d3js.org/) Network Panel Details

This panel provides a special [D3](http://d3js.org/) interactive interface to 
[phyloseq](http://joey711.github.io/phyloseq)'s
[plot_net function](http://joey711.github.io/phyloseq/plot_network-examples.html).
You can hover over node points to reveal a label,
and you can grab nodes and drag them around 
to your desired orientation. 
Different subnetworks attempt to avoid overlapping one another
via a slow repulsion-like algorithm.

Calculation time depends a lot on the size of your data (number of OTUs/samples)
and the distance method chosen.

## Widget Sections

### Network Structure

This top section defines key aspects of the network structure. 

- **Type** - Toggle between a network with Samples or Taxa as nodes. 
- **Distance** - The distance method. This is a direct interface to phyloseq's
[distance function](http://joey711.github.io/phyloseq/distance).
- **Max D** - Maximum Distance.
The graphic includes an edge if two nodes have a smaller distance than this value.
This is exactly the same as the `Max D` variable in the static Network panel.
- **Transform** - This option is very important.
It determines whether to use filtered-counts, 
or some transformation of the filtered count values.
See the `Transform` panel for the definition of each available option.

### Aesthetic Mapping

These widgets correspond to aesthetic mappings on nodes.
`Color` map code-color to a particular single variable.
`Label` allows labeling of nodes with text that
**only appears after hovering over the node/point** of interest.
If multiple non-`NULL` variables are selected,
their values are concatenated together
in selected order as a single hover-actuated label for each node.


### Details

- `Opacity` - The transparency of node points.
- `Scale` - The scaling factor that maps node-distance to edge line width.
- `Shade` - The edge line color shade.

### Dimensions and Downloads

This sections includes the figure dimensions
scaling in pixels rather than inches,
as well as a download button (`DL`).
There is no file-format button because the format
is always a stand-alone HTML that should be sharable as an interactive graphic.

### Acknowledgements

Big thanks to Christopher Gandrud for
[networkD3](http://christophergandrud.github.io/networkD3/)
and also to the team at 
[Shiny and RStudio](http://shiny.rstudio.com).



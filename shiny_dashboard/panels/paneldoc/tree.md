# Tree Panel Details

This panel provides an interface to 
[phyloseq](http://joey711.github.io/phyloseq)'s
[plot_tree function](http://joey711.github.io/phyloseq/plot_tree-examples.html).

### Structure

This top section defines key aspects of 
the tree layout structure.

- **Points** - Whether to include points next to tips in the tree, or just draw the "naked" tree.
- **Justify** - Whether to justify points, or pile them next to tree tips (only matters if you chose `points`, above).
- **Ladderize** - A branch rotating heuristic to make the tree easier to read and interpret.
- **Coordinates** - Whether to use radial or cartesian coordinates to render tree.
- **Min** - The minimum count/value threshold that determines whether a point is displayed on the graphic.
- **Margin** - The additional margin added to facilitate dodged points on the graphic.


### Aesthetic Mapping

- **Color** - A variable to map to a points color.
- **Shape** - A variable to map to a points shape.
- **Labels** - Tip labels, next to tree tips or to the right of points.

### Details

- **Palette** - Color Palette.
- **Size** - Point/label size
- **Theme** - Graphic (ggplot2) theme.

### Dimensions and Downloads

Figure dimensions (in inches), file format, and download button (`DL`).



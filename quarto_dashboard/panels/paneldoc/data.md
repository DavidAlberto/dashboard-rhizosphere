# Shiny-phyloseq Overview

[Shiny-phyloseq](http://joey711.github.io/shiny-phyloseq)
is a [Shiny](shiny.rstudio.com)-based graphical user interface (GUI)
to [the phyloseq package](http://joey711.github.io/phyloseq)
for [R](http://cran.r-project.org/),
hosted by [Bioconductor](http://bioconductor.org/).

Shiny-phyloseq is intended for the following purposes (among)

- (1) Rapid, reproducible, interactive exploration of microbiome data
- (2) Introduction to some of the functionality in the phyloseq package
- (3) An accessible tool for education of both microbiome data and its analysis
- (4) Easy exchange and demonstration of microbiome data analyses in R

Shiny-phyloseq is an open-source project with a modular design
based on the much more general Shiny project
for exposing R tools with custom web interfaces.
As a result it is easy to customize ---
for instance by the adding new dataset(s) to the default selection list,
adjusting default parameters to reflect experiment-specific choices,
or even by adding/subtracting panels with new or modified functionality.

[Shiny](http://rstudio.github.io/shiny/) is a fully-compliant
[CRAN-hosted](http://cran.r-project.org/web/packages/shiny/index.html)
R package
that provides an Application Program Interface (API) for building interactive web applications
that are based on Twitter's [Bootstrap](http://getbootstrap.com/2.3.2) front-end toolkit.
Shiny-phyloseq is almost entirely R code, 
but, like any Shiny app, can be further customized/extended
using HTML, CSS, and JavaScript.
Shiny-phyloseq is fully cross-platform and will launch locally from any R environment
(Console R, Rgui, RStudio, etc.),
but can also be ["hosted" by a web-server](http://shiny.rstudio.com) ---
this latter-case requiring only a web browser.
Shiny-phyloseq leverages Shiny's reactive programming framework 
to compartmentalize and cache expensive computational steps
so that they are not re-computed unnecessarily during an interactive session.

### Typical Workflow

A typical workflow in Shiny-phyloseq begins 
with data upload and selection,
followed by optional filtering of OTUs or samples.
A number of exploratory data analysis methods
are available in separate panels,
including alpha diversity estimates,
multivariate ordination methods,
and network and heatmap plots.
Some of these methods depend on provided
data transformations (e.g. regularized-log) or
ecological distances (e.g. weighted-UniFrac, Bray-Curtis),
which can be selected from a sidebar panel of parameter-input widgets
placed next to each graphic on each panel.
Graphics can be downloaded in user-specified format
by clicking the download button
at the bottom of each sidebar panel.
Lastly, a user can download a compressed file containing
the complete code and data necessary
to completely reproduce the steps that led to their graphical result.

The Shiny-phyloseq interface is organized into panels from left to right,
beginning with data selection (the first to appear), filtering/curation, 
graphic-specific panels, and ending with provenance-tracking.
User input widgets are consolidated in a lefthand sidebar of each panel.
The `Select Dataset` panel (the current panel)
begins each session.
Pre-loaded datasets are available by default,
and users can optionally specify public datasets
hosted on [QIIME-DB](http://www.microbio.me/qiime/),
or upload private dataset files that are in the
[biom file format](biom-format.org),
or even batch upload of binary `.RData`
that has been previously imported into phyloseq's data class in R.
See below for further details about data input and selection.

The Filter panel supports some common aspects of user-defined data filtering.
Shiny-phyloseq provides a separate panel
for each each major graphic function in phyloseq, including
alpha-diversity (`Richness`), 
sample- or OTU-networks (`Network` and `d3Network`), 
bar plot (`Bar`), 
heat map (`Heatmap`), 
phylogenetic tree (`Tree`), 
ordination (`Ordination`),
and scatter plot (`Scatter`).
All panels support custom figure dimensions,
usually at the bottom of the sidebar panel.
The ggplot2-based graphics further support custom 
color palettes and file format for download.

Among many new features not previously available in phyloseq, 
Shiny-phyloseq also records and makes available
your sequence of input choices 
and subsequent graphical results during your session,
allowing you to archive, share, and reproduce 
the sequence of steps you used to arrive at your result --
without writing any new code.
This can be achived at any waypoint or end of your
analysis in other panels
by clicking on the `Provenance` panel,
then clicking the `Render Code` button
(which initiates the archiving routine and data packaging).
Then click the download button,
and a compressed file will be downloaded that contains the data and code.

### Machine Requirements

If you are merely pointing your web browser
at a remote server that is hosting Shiny-phyloseq,
then your machine performance requirements are much less. 
Most modern desktops/laptops will do fine.
If you are launching your own locally-hosted session,
then you will need to install some things
and your system requirements are greater
because your own computer will be performing the "back end" computations
as well as rendering the graphics and user interface.
See [the Shiny-phyloseq installation page](http://joey711.github.io/shiny-phyloseq/Install.html)
for more details about requirements,
and detailed instructions for installing
and launching Shiny-phyloseq locally.

### Tips for Using Shiny-phyloseq

- **Filtering**. 
Most downstream analysis panels use the data 
that results from the latest filtering button-click as input data.
If the filtering step is skipped, the original dataset is used.
For most microbiome datasets filtering is a good idea.
- **Colors** and **Formats**. 
Most panels provide optional color palette selections 
defined by [Color Brewer](http://colorbrewer.org),
and all panels provide manual adjustment of the graphic's width and height,
which controls both the dimensions of the in-browser graphic
as well as downloadable graphic via a `Download` button.
For most panels (except D3 graphics) you can choose from
a large number of standard vector and raster graphics formats.
- **Errors**.
All panels produce some sort of plot. 
Most errors are "caught" silently without crashing the server-side R session,
but instead result in a generic graphic.
You should immediately consider why 
your data and parameter choices might have caused a logical error.
In some cases the generic graphic will include an informative label
that might help you find a solution, but not always.
When in doubt, turn parameters back to their default "vanilla" values,
and start again.
- **Large Data and Slow Computations**.
If you are analyzing a very large dataset
with so many microbiome samples and/or OTUs
that basic calculations run slowly in "command-line" phyloseq,
then there is no reason to expect that a GUI interactive
approach will perform any better... unless 
you have hosted Shiny-phyloseq on a much-improved server
from your original sluggish experience.
Your happiness of the speed and responsiveness of Shiny-phyloseq
depends a lot upon what machine is running the "back end", 
and how large your dataset is.
Common datasets with 1000 or fewer OTUs after filtering,
and a 100 or fewer samples,
should perform well when hosted on zippy computers
with sufficient (>4GB) RAM.
There are no clear boundaries as it depends mostly on dataset size.
Computers with <=2GB RAM are probably too old
to expect satisfying responsiveness in this application.

### Customizing Shiny-phyloseq

If you've downloaded the Shiny-phyloseq code and intend to tinker with it,
a good place to start might be to modify `core/default-parameters.R` 
and change certain default settings.
The default filtering parameters are especially ripe
for tuning to a specific dataset that you intend to present.

It is also possible to modify any aspect of Shiny-phyloseq,
as the complete source code is available not only
for Shiny-phyloseq, but also [the Shiny package](https://github.com/rstudio/shiny) itself.
For example, you can borrow one or more panel modules
of the Shiny-phyloseq codebase
and embed them as a Shiny widget within an HTML slideshow 
generated from the [R markdown](http://rmarkdown.rstudio.com/authoring_shiny.html).

### Posting Issues

Shiny-phyloseq is openly [developed on GitHub](https://github.com/joey711/shiny-phyloseq/).
This openness includes a so-called
"[Issues Tracker](http://en.wikipedia.org/wiki/Issue_tracking_system)"
where bug reports,
feature requests,
documentation revisions,
and suggestions for improvement
can be posted by anyone with a GitHub account,
and visible/Google-searchable by all.

The [Shiny-phyloseq issue tracker](https://github.com/joey711/shiny-phyloseq/issues)
can be found at this link:

https://github.com/joey711/shiny-phyloseq/issues

### Contributing Code

If you're a programmer with skil in R, JavaScript, or CSS,
you may be able to contribute to Shiny-phyloseq. 
Contributions are preferred
through the standard git/GitHub
[Pull Request](https://help.github.com/articles/using-pull-requests)
system.
Outstanding pull requests appear here:

https://github.com/joey711/shiny-phyloseq/pulls

but in most cases you will "Fork and Pull" through your own account
and locally originated changes.


### Data Privacy

For those worried about maintaining data privacy,
it is important to note that for locally-launched/served sessions
the file is not actually being transmitted anywhere outside your local machine.
The terms "Upload" and "Download" are referring
to the data transmission between your browser front-end
and your server back-end
(as opposed to pointing your browser
to an externally-hosted instance of Shiny-phyloseq,
in which case you are uploading and downloading in the usual sense).
We have not included any infrastructure in Shiny-phyloseq
to archive uploaded data,
and any storage of such data is intentionally ephemeral,
and only as necessary for the proper functioning of the application.
Any deviation from this is by accident,
or by a modification of Shiny-phyloseq that is beyond our intent or permission.
By design, the `Provenance` panel provides a means of
downloading the complete code **and data** necessary to completely
reproduce the set of figures created during a user session.
After successful download/transmission,
this stored code and data is deleted from the server-side file system.

### Acknowledgements

Big thanks to [Shiny web apps team](http://shiny.rstudio.com/) and Rstudio in general.


---

# Data Input Panel Details

This current panel is a limited but hopefully useful interface
to phyloseq's [Data Import Infrastructure](http://joey711.github.io/phyloseq/import-data.html).

Filtering can be done on the next panel to the right
after the data has been uploaded and selected.

### Select Dataset

This is the first and most-critical selection widget in Shiny-phyloseq.
It determines which dataset to use as the starting point of an analysis.
Changing or resetting the name displayed in this widget
to a new value will cause a cascading reset
of most other widgets in the rest of the app,
because many refer to annotation elements 
that are specific to the selected dataset.
Only one dataset can be selected at a time.
The list of available datasets shown in this widget
will update instantly after any new datasets are loaded.
The most recently provided dataset is selected by default,
therefore uploading a new dataset will automatically
make it the selected "live" dataset displayed
in every subsequent panel and graphic.

There are many default datasets included in the app
and available for selection.

- **closed_1457_uparse** - Kostic et al 
*Genomic analysis identifies association of Fusobacterium with colorectal carcinoma*
(2012)
[Genome research 22(2) 292-298](http://genome.cshlp.org/content/22/2/292.long).
In this case closed-reference OTU-clustering
of the publicly available 16S rRNA sequences
has been re-performed using [UPARSE](http://drive5.com/uparse/)
and each OTU has been taxonomically classified by its match in
[the GreenGenes reference database](http://greengenes.secondgenome.com/downloads) `ver13_8`.
- **study_1457_kostic** - This is the same experimental data as above,
but the original publicly available counts
corresponding to the default OTU-clustering and classification procedure of the QIIME-DB
- **GlobalPatterns** - Caporaso et al. (2011). 
*Global patterns of 16S rRNA diversity at a depth of millions of sequences per sample*.
[PNAS 108 4516-4522. PMCID: PMC3063599](http://www.pnas.org/content/108/suppl.1/4516.short)
- **enterotype** - Arumugam et al. (2011). *Enterotypes of the human gut microbiome*.
[Nature, 473(7346), 174-180](http://www.nature.com/doifinder/10.1038/nature09944).
OTU-clustered data was downloaded from
[this publicly-accessible link](http://www.bork.embl.de/Docu/Arumugam_et_al_2011/downloads.html)
- **esophagus** - Pei et al (2004).
*Bacterial biota in the human distal esophagus*
[PNAS 101(12), 4250-4255](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC384727). 
This data is derived from [mothur](http://www.mothur.org/)-processed files.
The sequence data can be downloaded from a zip-file,
along with additional description at
[this link URL](http://www.mothur.org/wiki/Esophageal_community_analysis).


### Upload Biom-Format File

Click the `Choose Files` button to upload a biom-format file from your local system.
Behind the scenes it will be processed into a native phyloseq data structure in R.
If successfully processed, its name will be made available as the selected dataset
in the `Select Dataset` list, as described above.

### Upload ".RData" File

This is the same concept as for the previous biom-file upload,
except in this case the file is a binary [.RData]() format
that contains one or more datasets that are already in native phyloseq data structure.
This is useful for the following scenarios

- You already imported your data in R using a relevant `import_*` function in phyloseq,
either because you already use phyloseq 
or because you needed to make some subtle modifications prior to Shiny-phyloseq
- You want to "batch" upload many datasets at once

### Upload Tree File

This is a special file-upload option
that will attempt to read/process a Newick or Nexus format
phylogenetic tree.
If successful, it will attempt
to add (if missing) or replace (if present)
the phylogenetic tree component of the currently-selected dataset.
It is essential that the tip labels encoded in the tree file
match exactly their respective OTUs
in the currently-selected dataset.
Tree file processing will be conducted
using phyloseq's `read_tree` function,
and then merged with the currently-selected dataset
using `merge_phyloseq`.
See phyloseq's [import_data](http://joey711.github.io/phyloseq/import-data.html)
page for further details.

Note that the other upload/load widgets in this data selection panel
add new whole datasets for selection,
whereas this upload will result in adding/replacing the tree,
provided that the initial tree file processing is successful.

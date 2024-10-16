# Filter Panel Details

This panel is a limited but hopefully useful interface
to phyloseq's [Preprocessing infrastructure](http://joey711.github.io/phyloseq/preprocess.html).
It is intended for some of the simpler filtering tasks supported by phyloseq.
For more advanced filtering consider manipulating your data
via R/phyloseq directly, prior to uploading it to the Shiny-phyloseq app.
See the data tab for further info about importing/saving/uploading data. 

**No filter calculations are performed until the** `Execute Filter` **button is clicked**

Most downstream analyses will use the data 
that results from the most-recent click of this panel's button.

Filtering is always performed in the order
displayed in the sidebar panel (top to bottom, left to right).
Steps with zero/null parameter values are skipped.

In summary

- (1) The data is subsetted 
by specific taxonomic ranks or sample covariates,
if any such subsetting arguments are provided.
- (2) Second, minimum thresholds for 
library size or cross-dataset taxa-counts
are evaluated and the data filtered accordingly.
- (3) Third, an interface for
[genefilter's kOverA filtering](http://www.bioconductor.org/packages/release/bioc/manuals/genefilter/man/genefilter.pdf)
is evaluated on the result of any other filtering up to this. 

After clicking the button to execute the filtering parameters,
a set of histograms of taxa and library count totals are displayed
for comparing raw (original) and filtered results.

In addition, the `Available Components` widget
allows you to select form available data components,
and render an interactive table of the selected component.
This is identical to the components-table display on the data panel,
but in this case it displays the filtered data.

### Subset sections

This section of the sidebar panel 
is for subsetting the microbiome data
through dynamic pairs of variable selection widgets.
The first/left widget allows you to select a variable in the dataset
(a sample variable or taxonomic rank),
and the second widget allows you to select 
one or more classes of the just-selected variable.
Upon execution, only the samples (or taxa) 
with the selected classes (or taxa) 
will remain in the dataset.

- **Subset Taxa**
**Left**. Select a particular taxonomic rank by which to filter (if available).
**Right**. Select one or more taxa within this rank that you want to keep in the filtered data.
The rest will be discarded.
- **Subset Samples** - **Left**. Select a sample variable with categories you want to select amongst.
**Right**. Select Classes within the selected variable that you want to keep.
The rest will be discarded.
Currently only categorical variables are supported for sample subsetting.

### Total Sums Filtering

After any subsetting, total sums filtering is applied.
The `Sample Min.` and `Taxa Min.` widgets specify minimum thresholds.
Only samples or taxa that have count totals above the displayed values
will be retained in the filtered data after clicking the `Execute Filter` button.

### kOverA Taxa Filtering

This is a useful and commonly-used heuristic.
It is applied last, after other filtering steps
have been applied to the data.

- `A` -- The count value minmum threshold
- `k` -- The number of samples in which a taxa exceeded `A`

An taxa is retained in the dataset iff it exceeds the value `A` in at least `k` samples.

In phyloseq code, this filtering step has the form

```r
flist = filterfun(kOverA(k, A))
physeq <- filter_taxa(ps0, flist, prune=TRUE)
```
where `physeq` and `ps0` are the filtered and unfiltered data, respectively.
`filterfun` and `kOverA` are from
[the genefilter package](http://www.bioconductor.org/packages/release/bioc/html/genefilter.html).

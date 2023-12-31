% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analyze.R
\name{clusterData}
\alias{clusterData}
\title{Hierarchical cluster analysis}
\usage{
clusterData(data, annotation_row = NULL, annotation_col = NULL,
annotation_colors = NULL, main = NA, legend = TRUE,
clustering_distance_rows = "euclidean",
clustering_distance_cols = "euclidean", display_numbers = FALSE,
number_format = "\%.0f", num_clusters_row = NULL,
num_clusters_col = NULL, cluster_rows = TRUE, cluster_cols = TRUE,
border_color = "gray60", annotate_new_clusters_col = FALSE,
zero_white = FALSE, color_low = '#006699', color_mid = 'white',
color_high = 'red',color_palette = NULL, show_rownames = FALSE,
show_colnames = FALSE, min_data = min(data, na.rm = TRUE),
max_data = max(data, na.rm = TRUE),
treeheight_row = ifelse(methods::is(cluster_rows, "hclust") ||
cluster_rows, 50, 0), treeheight_col = ifelse(methods::is(cluster_cols,
"hclust") || cluster_cols, 50, 0))
}
\arguments{
\item{data}{an object of log2-normalized protein (or gene) expressions,
containing markers in rows and samples in columns.}

\item{annotation_row}{data frame that specifies the annotations shown on
left side of the heat map. Each row defines the features for a specific
row. The rows in the data and in the annotation are matched using
corresponding row names. Note that color schemes takes into account if
variable is continuous or discrete.}

\item{annotation_col}{similar to annotation_row, but for columns.}

\item{annotation_colors}{list for specifying annotation_row and
annotation_col track colors manually. It is possible to define the colors
for only some of the features.}

\item{main}{character string, an overall title for the plot.}

\item{legend}{logical, to determine if legend should be drawn or not.}

\item{clustering_distance_rows}{distance measure used in clustering rows.
Possible values are "correlation" for Pearson correlation and all the
distances supported by dist, such as "euclidean", etc. If the value is
none of the above it is assumed that a distance matrix is provided.}

\item{clustering_distance_cols}{distance measure used in clustering
columns. Possible values the same as for clustering_distance_rows.}

\item{display_numbers}{logical, determining if the numeric values are also
printed to the cells. If this is a matrix (with same dimensions as original
matrix), the contents of the matrix are shown instead of original values.}

\item{number_format}{format strings (C printf style) of the numbers shown in
cells. For example "\%.2f" shows 2 decimal places and "\%.1e" shows
exponential notation (see more in sprintf).}

\item{num_clusters_row}{number of clusters the rows are divided into, based
on the hierarchical clustering (using cutree), if rows are not clustered,
the argument is ignored.}

\item{num_clusters_col}{similar to num_clusters_row, but for columns.}

\item{cluster_rows}{logical, determining if the rows should be clustered;
or a hclust object.}

\item{cluster_cols}{similar to cluster_rows, but for columns.}

\item{border_color}{color of cell borders on heatmap, use NA if no border
should be drawn.}

\item{annotate_new_clusters_col}{logical, to annotate cluster IDs (column)
that will be identified.}

\item{zero_white}{logical, to display 0 values as white in the colormap.}

\item{color_low}{color code for the low intensity values in the colormap.}

\item{color_mid}{color code for the medium intensity values in the colormap.}

\item{color_high}{color code for the high intensity values in the colormap.}

\item{color_palette}{vector of colors used in heatmap.}

\item{show_rownames}{boolean, specifying if row names are be shown.}

\item{show_colnames}{boolean, specifying if column names are be shown.}

\item{min_data}{numeric, data value corresponding to minimum intensity in
the color_palette}

\item{max_data}{numeric, data value corresponding to maximum intensity in
the color_palette}

\item{treeheight_row}{the height of a tree for rows, if these are clustered.
Default value is 50 points.}

\item{treeheight_col}{the height of a tree for columns, if these are
clustered. Default value is 50 points.}
}
\value{
tree, the hierarchical tree structure.

cluster_IDs_row, the (row) cluster identities of the markers.

cluster_IDs_col, the (column) cluster identities of the samples.
}
\description{
Displays the hierarchically clustered data by the "pheatmap"
package.
The numbers of clusters along the markers/samples can be set by the user,
then the cluster structures are estimated by pair-wise analysis.
}
\examples{
set.seed(1)
dat = setNames(as.data.frame(matrix(runif(10*10),10,10),
row.names = paste('marker',1:10,sep='')), paste('sample',1:10,sep=''))
result = clusterData(dat)
}

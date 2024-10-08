% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/harmony_option.R
\name{harmony_options}
\alias{harmony_options}
\title{Set advanced parameters for RunHarmony}
\usage{
harmony_options(
  alpha = 0.2,
  tau = 0,
  block.size = 0.05,
  max.iter.cluster = 20,
  epsilon.cluster = 0.001,
  epsilon.harmony = 0.01
)
}
\arguments{
\item{alpha}{When setting lambda = NULL and use lambda estimation mode, 
lambda would be determined by the expected number of cells assuming 
idependece between batches and clusters. i.e., lambda = alpha * expected
number of cells, default 0.2 and alpha should be 0 < alpha < 1}

\item{tau}{Protection against overclustering small datasets with 
large ones. `tau` is the expected number of cells per cluster.}

\item{block.size}{What proportion of cells to update during clustering. 
Between 0 to 1, default 0.05. Larger values may be faster but less 
accurate.}

\item{max.iter.cluster}{Maximum number of rounds to run clustering 
at each round of Harmony.}

\item{epsilon.cluster}{Convergence tolerance for clustering round 
of Harmony. Set to -Inf to never stop early.}

\item{epsilon.harmony}{Convergence tolerance for Harmony. Set to -Inf to
never stop early. When `epsilon.harmony` is set to not NULL, then
user-supplied values of `early_stop` is ignored.}
}
\value{
Return a list for `.options` argument of `RunHarmony`
}
\description{
Set advanced parameters for RunHarmony
}
\examples{
## If want to set max.iter.cluster to be 100, do
\dontrun{
RunHarmony(data_meta, meta_data, vars_use,
              .options = harmony_options(max.iter.cluster = 100))
}

}

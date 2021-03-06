% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprogs.R
\name{runDE}
\alias{runDE}
\title{runDE}
\usage{
runDE(data = NULL, columns = NULL, conds = NULL, pars = NULL)
}
\arguments{
\item{data, }{A matrix that includes all the expression raw counts,
rownames has to be the gene, isoform or region names/IDs}

\item{columns, }{is a vector that includes the columns that are going
to be analyzed. These columns has to match with the given data.}

\item{conds, }{experimental conditions. The order has to match
with the column order}

\item{pars, }{all params for the de methods}
}
\value{
de results
}
\description{
Run DE algorithms on the selected parameters.  Output is
to be used for the interactive display.
}
\examples{
    x <- runDE()

}


% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/volcano.R
\name{volcanoZoom}
\alias{volcanoZoom}
\title{volcanoZoom}
\usage{
volcanoZoom(dat = NULL, data_tooltip = NULL, domains = NULL,
  colors = NULL)
}
\arguments{
\item{dat, }{dataframe that has log2FoldChange and log10padj values}

\item{data_tooltip, }{toolstip specific to this plot}

\item{domains, }{the domains to be colored}

\item{colors, }{colors for each domain}
}
\value{
zoomed volcano plot
}
\description{
Prepares the zoomed in version of the volcano plot to be used
within the Debrowser.
}
\examples{
    x <- volcanoZoom()

}


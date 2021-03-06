% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/QCSection.R
\name{getQCPlots}
\alias{getQCPlots}
\title{getQCPlots}
\usage{
getQCPlots(dataset = NULL, input = NULL, metadata = NULL,
  inputQCPlot = NULL)
}
\arguments{
\item{dataset, }{the dataset to use}

\item{input, }{user input}

\item{metadata, }{coupled samples and conditions}

\item{inputQCPlot, }{input QC params}
}
\value{
the panel for QC plots
}
\description{
Gathers the plot data to be displayed within the
quality checks panel.
}
\note{
\code{getQCPlots}
}
\examples{
    x <- getQCPlots()

}


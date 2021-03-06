% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/uifuncs.R
\name{actionButton}
\alias{actionButton}
\title{Buttons including Action Buttons and Event Buttons}
\usage{
actionButton(inputId, label, styleclass = "", size = "", block = FALSE,
  icon = NULL, css.class = "", ...)
}
\arguments{
\item{inputId}{Specifies the input slot that will be used to access the 
value.}

\item{label}{The contents of the button--usually a text label, but you could 
also use any other HTML, like an image.}

\item{styleclass}{The Bootstrap styling class of the button--options are 
primary, info, success, warning, danger, inverse, link or blank}

\item{size}{The size of the button--options are large, small, mini}

\item{block}{Whehter the button should fill the block}

\item{icon}{Display an icon for the button}

\item{css.class}{Any additional CSS class one wishes to add to the action 
button}

\item{...}{Other argument to feed into shiny::actionButton}
}
\description{
Creates an action button whose value is initially zero, and increments by one
each time it is pressed.
}
\examples{
    actionButton("goDE", "Go to DE Analysis!")

}


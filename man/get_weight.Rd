% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/attribs.R
\docType{methods}
\name{get_weight}
\alias{get_weight}
\alias{get_weight,ANY-method}
\alias{ANY-method}
\alias{get_weight,Isoval-method}
\alias{Isoval-method}
\alias{get_weight,Isosys-method}
\alias{Isosys-method}
\title{Retrieve isotope object's weights}
\usage{
get_weight(iso)

\S4method{get_weight}{ANY}(iso)

\S4method{get_weight}{Isoval}(iso)

\S4method{get_weight}{Isosys}(iso)
}
\value{
In the case of a single isotope object (Isoval), returns the numeric
vector of weights stored in the object. In the case of an isotope system (Isosys),
returns the data frame underlying the object with all its isotope value
objects replaced with their weight values.
}
\description{
This function returns an isotope object's weight values.
}
\seealso{
\code{\link{as.data.frame}}, \code{\link[base]{as.data.frame}} (base method)

Other data type attributes: \code{\link{get_name}},
  \code{\link{get_value}},
  \code{\link{get_weighted_value}},
  \code{\link{set_attrib}}, \code{\link{switch_notation}},
  \code{\link{weight}}
}
\concept{data type attributes}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VCF_to_catalog_functions.R
\name{ReadStrelkaIDVCF}
\alias{ReadStrelkaIDVCF}
\title{Read in the data lines of an ID VCF created by Strelka version 1}
\usage{
ReadStrelkaIDVCF(file, name.of.VCF = NULL)
}
\arguments{
\item{file}{The name/path of the VCF file, or a complete URL.}

\item{name.of.VCF}{Name of the VCF file. If \code{NULL}(default), this
function will remove all of the path up to and including the last path
separator (if any) in \code{file} and file path without extensions (and the
leading dot) will be used as the name of the VCF file.}
}
\value{
A data frame storing data lines of the VCF file.
}
\description{
Read in the data lines of an ID VCF created by Strelka version 1
}
\section{Note}{

In ID (small insertions and deletions) catalogs, deletion repeat sizes range
from 0 to 5+, but for plotting and end-user documentation deletion repeat
sizes range from 1 to 6+.
}

\keyword{internal}

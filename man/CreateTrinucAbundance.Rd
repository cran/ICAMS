% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utility_functions.R
\name{CreateTrinucAbundance}
\alias{CreateTrinucAbundance}
\title{Create trinucleotide abundance}
\usage{
CreateTrinucAbundance(file)
}
\arguments{
\item{file}{Path to the file with the nucleotide abundance information with 3
base pairs.}
}
\value{
A numeric vector whose names indicate 32 different types of 3 base pairs
  combinations while its values indicate the occurrences of each type.
}
\description{
Create trinucleotide abundance
}
\keyword{internal}

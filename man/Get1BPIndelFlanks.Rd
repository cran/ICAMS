% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sequence_context_functions.R
\name{Get1BPIndelFlanks}
\alias{Get1BPIndelFlanks}
\title{Get all the sequence contexts of the indels in a given 1 base-pair indel
class}
\usage{
Get1BPIndelFlanks(sequence, ref, alt, indel.class, flank.length = 5)
}
\arguments{
\item{sequence}{A string from \code{seq.context} column from in-memory
\code{data.frame} or similar table containing "VCF" (variant call format)
data as created by \code{\link{AnnotateIDVCF}}.}

\item{ref}{A string from \code{REF} column from in-memory \code{data.frame}
or similar table containing "VCF" (variant call format) data as created by
\code{\link{AnnotateIDVCF}}.}

\item{alt}{A string from \code{ALT} column from in-memory \code{data.frame}
or similar table containing "VCF" (variant call format) data as created by
\code{\link{AnnotateIDVCF}}.}

\item{indel.class}{A single character string that denotes a 1 base pair
insertion or deletion, as taken from \code{ICAMS::catalog.row.order$ID}.
Insertions or deletions into / from 5+ base-pair homopolymers are not
supported.}

\item{flank.length}{The length of flanking bases around the position or
homopolymer targeted by the indel.}
}
\value{
A string for the specified \code{sequence} and \code{indel.class}.
}
\description{
Get all the sequence contexts of the indels in a given 1 base-pair indel
class
}
\keyword{internal}

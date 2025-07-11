% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ID_functions.R
\name{Canonicalize1Del}
\alias{Canonicalize1Del}
\title{Given a deletion and its sequence context, categorize it}
\usage{
Canonicalize1Del(context, del.seq, pos, trace = 0)
}
\arguments{
\item{context}{The deleted sequence plus ample surrounding
sequence on each side (at least as long as \code{del.seq}).}

\item{del.seq}{The deleted sequence in \code{context}.}

\item{pos}{The position of \code{del.sequence} in \code{context}.}

\item{trace}{If > 0, then generate messages tracing
how the computation is carried out.}
}
\value{
A string that is the canonical representation
 of the given deletion type. Return \code{NA} 
 and raise a warning if
 there is an un-normalized representation of
 the deletion of a repeat unit.
 See \code{FindDelMH} for details.
 (This seems to be very rare.)
}
\description{
This function is primarily for internal use, but we export it
to document the underlying logic.
}
\details{
See \url{https://github.com/steverozen/ICAMS/blob/v3.0.9-branch/data-raw/PCAWG7_indel_classification_2021_09_03.xlsx}
for additional information on deletion mutation classification.

This function first handles deletions in homopolymers, then
handles deletions in simple repeats with
longer repeat units, (e.g. \code{CACACACA}, see
\code{\link{FindMaxRepeatDel}}),
and if the deletion is not in a simple repeat,
looks for microhomology (see \code{\link{FindDelMH}}).

See the code for unexported function \code{\link{CanonicalizeID}}
and the functions it calls for handling of insertions.
}
\examples{
Canonicalize1Del("xyAAAqr", del.seq = "A", pos = 3) # "DEL:T:1:2"
Canonicalize1Del("xyAAAqr", del.seq = "A", pos = 4) # "DEL:T:1:2"
Canonicalize1Del("xyAqr", del.seq = "A", pos = 3)   # "DEL:T:1:0"

}

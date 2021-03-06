% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VCF_to_catalog_functions.R
\name{SplitListOfMutectVCFs}
\alias{SplitListOfMutectVCFs}
\title{Split each Mutect VCF into SBS, DBS, and ID VCFs (plus
VCF-like data frame with left-over rows)}
\usage{
SplitListOfMutectVCFs(
  list.of.vcfs,
  suppress.discarded.variants.warnings = TRUE
)
}
\arguments{
\item{list.of.vcfs}{List of VCFs as in-memory data.frames.}

\item{suppress.discarded.variants.warnings}{Logical. Whether to suppress
warning messages showing information about the discarded variants. Default
is TRUE.}
}
\description{
Split each Mutect VCF into SBS, DBS, and ID VCFs (plus
VCF-like data frame with left-over rows)
}
\section{Value}{
 A list containing the following objects:
\itemize{
\item \code{SBS}: List of VCFs with only single base substitutions.
\item \code{DBS}: List of VCFs with only doublet base substitutions as called
by Mutect.
\item \code{ID}: List of VCFs with only small insertions and deletions.
\item \code{discarded.variants}: \strong{Non-NULL only if} there are variants
that were excluded from the analysis. See the added extra column
\code{discarded.reason} for more details.
}
}

\keyword{internal}

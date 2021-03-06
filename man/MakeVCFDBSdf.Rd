% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VCF_to_catalog_functions.R
\name{MakeVCFDBSdf}
\alias{MakeVCFDBSdf}
\title{MakeVCFDBSdf Take DBS ranges and the original VCF and generate a VCF with
dinucleotide REF and ALT alleles.}
\usage{
MakeVCFDBSdf(DBS.range.df, SBS.vcf.dt)
}
\arguments{
\item{DBS.range.df}{Data frame with columns CHROM, LOW, HIGH}

\item{SBS.vcf.dt}{A data table containing the VCF from which
\code{DBS.range.df} was computed.}
}
\value{
A minimal VCF with only the columns \code{CHROM}, \code{POS},
  \code{ID}, \code{REF}, \code{ALT}, \code{VAF}, \code{read.depth}.
}
\description{
MakeVCFDBSdf Take DBS ranges and the original VCF and generate a VCF with
dinucleotide REF and ALT alleles.
}
\keyword{internal}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chromosome_name_functions.R
\name{CheckAndFixChrNames}
\alias{CheckAndFixChrNames}
\title{Check and, if possible, correct the chromosome names in a VCF \code{data.frame}.}
\usage{
CheckAndFixChrNames(vcf.df, ref.genome, name.of.VCF = NULL)
}
\arguments{
\item{vcf.df}{A VCF as a \code{data.frame}. Check the names in column
\code{CHROM}.}

\item{ref.genome}{The reference genome with the chromosome names to check
\code{vcf.df$CHROM} against; must be a Bioconductor
\code{BSgenome}, e.g.
\code{BSgenome.Hsapiens.UCSC.hg38}.}

\item{name.of.VCF}{Name of the VCF file.}
}
\value{
If the \code{vcf.df$CHROM} values are correct or
can be corrected, then a vector of chromosome names
that can be used as a replacement for \code{vcf.df$CHROM}.
If the names in \code{vcf.df$CHROM} cannot be made to
be consistent with the chromosome names in \code{ref.genome},
then \code{stop}.
}
\description{
Check and, if possible, correct the chromosome names in a VCF \code{data.frame}.
}
\keyword{internal}

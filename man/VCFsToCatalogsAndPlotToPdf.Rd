% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VCF_to_catalog_functions.R
\name{VCFsToCatalogsAndPlotToPdf}
\alias{VCFsToCatalogsAndPlotToPdf}
\title{Create SBS, DBS and Indel catalogs from VCFs and plot them to PDF}
\usage{
VCFsToCatalogsAndPlotToPdf(
  files,
  output.dir,
  ref.genome,
  variant.caller = "unknown",
  num.of.cores = 1,
  trans.ranges = NULL,
  region = "unknown",
  names.of.VCFs = NULL,
  tumor.col.names = NA,
  filter.status = DefaultFilterStatus(variant.caller),
  get.vaf.function = NULL,
  ...,
  max.vaf.diff = 0.02,
  base.filename = "",
  return.annotated.vcfs = FALSE,
  suppress.discarded.variants.warnings = TRUE,
  chr.names.to.process = NULL
)
}
\arguments{
\item{files}{Character vector of file paths to the VCF files.}

\item{output.dir}{The directory where the PDF files will be saved.}

\item{ref.genome}{A \code{ref.genome} argument as described in
\code{\link{ICAMS}}.}

\item{variant.caller}{Name of the variant caller that produces the VCF, can
be either \code{"strelka"}, \code{"mutect"}, \code{"freebayes"} or
\code{"unknown"}. This information is needed to calculate the VAFs (variant
allele frequencies). If variant caller is \code{"unknown"}(default) and
\code{get.vaf.function} is NULL, then VAF and read depth will be NAs. If
variant caller is \code{"mutect"}, do \strong{not} merge SBSs into DBS.}

\item{num.of.cores}{The number of cores to use. Not available on Windows
unless \code{num.of.cores = 1}.}

\item{trans.ranges}{Optional. If \code{ref.genome} specifies one of the
\code{\link[BSgenome]{BSgenome}} object
\enumerate{
\item \code{BSgenome.Hsapiens.1000genomes.hs37d5}
\item \code{BSgenome.Hsapiens.UCSC.hg38}
\item \code{BSgenome.Mmusculus.UCSC.mm10}
}
then the function will infer \code{trans.ranges} automatically. Otherwise,
user will need to provide the necessary \code{trans.ranges}. Please refer to
\code{\link{TranscriptRanges}} for more details.
If \code{is.null(trans.ranges)} do not add transcript range
information.}

\item{region}{A character string designating a genomic region;
see \code{\link{as.catalog}} and \code{\link{ICAMS}}.}

\item{names.of.VCFs}{Optional. Character vector of names of the VCF files.
The order of names in \code{names.of.VCFs} should match the order of VCF
file paths in \code{files}. If \code{NULL}(default), this function will
remove all of the path up to and including the last path separator (if any)
in \code{files} and file paths without extensions (and the leading dot)
will be used as the names of the VCF files.}

\item{tumor.col.names}{Optional. Only applicable to \strong{Mutect} VCFs.
Vector of column names or column indices in \strong{Mutect} VCFs which
contain the tumor sample information. The order of elements in
\code{tumor.col.names} should match the order of \strong{Mutect} VCFs
specified in \code{files}. If \code{tumor.col.names} is equal to
\code{NA}(default), this function will use the 10th column in all the
\strong{Mutect} VCFs to calculate VAFs. See \code{\link{GetMutectVAF}} for
more details.}

\item{filter.status}{The character string in column \code{FILTER} of the VCF
that indicates that a variant has passed all the variant caller's filters.
Variants (lines in the VCF) for which the value in column \code{FILTER}
does not equal \code{filter.status} are silently excluded from the output.
The internal function \code{DefaultFilterStatus} tries to infer
\code{filter.status} based on \code{variant.caller}. If
\code{variant.caller} is "unknown", user must specify \code{filter.status}
explicitly. If \code{filter.status = NULL}, all variants are retained. If
there is no \code{FILTER} column in the VCF, all variants are retained with
a warning.}

\item{get.vaf.function}{Optional. Only applicable when \code{variant.caller} is
\strong{"unknown"}. Function to calculate VAF(variant allele frequency) and read
depth information from original VCF. See \code{\link{GetMutectVAF}} as an example.
If \code{NULL}(default) and \code{variant.caller} is "unknown", then VAF
and read depth will be NAs.}

\item{...}{Optional arguments to \code{get.vaf.function}.}

\item{max.vaf.diff}{\strong{Not} applicable if \code{variant.caller =
  "mutect"}. The maximum difference of VAF, default value is 0.02. If the
absolute difference of VAFs for adjacent SBSs is bigger than
\code{max.vaf.diff}, then these adjacent SBSs are likely to be "merely"
asynchronous single base mutations, opposed to a simultaneous doublet
mutation or variants involving more than two consecutive bases. Use
negative value (e.g. -1) to suppress merging adjacent SBSs to DBS.}

\item{base.filename}{Optional. The base name of the PDF files to be produced;
multiple files will be generated, each ending in \eqn{x}\code{.pdf}, where
\eqn{x} indicates the type of catalog plotted in the file.}

\item{return.annotated.vcfs}{Logical. Whether to return the annotated VCFs
with additional columns showing mutation class for each variant. Default is
FALSE.}

\item{suppress.discarded.variants.warnings}{Logical. Whether to suppress
warning messages showing information about the discarded variants. Default
is TRUE.}

\item{chr.names.to.process}{A character vector specifying the chromosome
names in VCF whose variants will be kept and processed, other chromosome
variants will be discarded. If NULL(default), all variants will be kept
except those on chromosomes with names that contain strings "GL", "KI",
"random", "Hs", "M", "JH", "fix", "alt".}
}
\description{
Create 3 SBS catalogs (96, 192, 1536), 3 DBS catalogs (78, 136, 144) and
Indel catalog from the VCFs specified by \code{files} and plot them to
PDF
}
\details{
This function calls \code{\link{VCFsToCatalogs}} and
\code{\link{PlotCatalogToPdf}}
}
\section{Value}{

A list containing the following objects:
\itemize{
\item \code{catSBS96}, \code{catSBS192}, \code{catSBS1536}: Matrix of
3 SBS catalogs (one each for 96, 192, and 1536).
\item \code{catDBS78}, \code{catDBS136}, \code{catDBS144}: Matrix of
3 DBS catalogs (one each for 78, 136, and 144).
\item \code{catID}: Matrix of ID (small insertions and deletions) catalog.
\item \code{discarded.variants}: \strong{Non-NULL only if} there are variants
that were excluded from the analysis. See the added extra column
\code{discarded.reason} for more details.
\item \code{annotated.vcfs}:
\strong{Non-NULL only if} \code{return.annotated.vcfs} = TRUE.
A list of elements:
\itemize{
\item \code{SBS}: SBS VCF annotated by \code{\link{AnnotateSBSVCF}} with
three new columns \code{SBS96.class}, \code{SBS192.class} and
\code{SBS1536.class} showing the mutation class for each SBS variant.
\item \code{DBS}: DBS VCF annotated by \code{\link{AnnotateDBSVCF}} with
three new columns \code{DBS78.class}, \code{DBS136.class} and
\code{DBS144.class} showing the mutation class for each DBS variant.
\item \code{ID}: ID VCF annotated by \code{\link{AnnotateIDVCF}} with one
new column \code{ID.class} showing the mutation class for each
ID variant.
}
}

If \code{trans.ranges} is not provided by user and cannot be inferred by
ICAMS, SBS 192 and DBS 144 catalog will not be generated. Each catalog has
attributes added. See \code{\link{as.catalog}} for more details.
}

\section{ID classification}{

See \url{https://github.com/steverozen/ICAMS/blob/v3.0.9-branch/data-raw/PCAWG7_indel_classification_2021_09_03.xlsx}
for additional information on ID (small insertions and deletions) mutation
classification.

See the documentation for \code{\link{Canonicalize1Del}} which first handles
deletions in homopolymers, then handles deletions in simple repeats with
longer repeat units, (e.g. \code{CACACACA}, see
\code{\link{FindMaxRepeatDel}}), and if the deletion is not in a simple
repeat, looks for microhomology (see \code{\link{FindDelMH}}).

See the code for unexported function \code{\link{CanonicalizeID}}
and the functions it calls for handling of insertions.
}

\section{Note}{

SBS 192 and DBS 144 catalogs include only mutations in transcribed regions.
In ID (small insertions and deletions) catalogs, deletion repeat sizes range
from 0 to 5+, but for plotting and end-user documentation deletion repeat
sizes range from 1 to 6+.
}

\section{Comments}{

To add or change attributes of the catalog, you can use function
\code{\link[base]{attr}}. \cr For example, \code{attr(catalog, "abundance")
<- custom.abundance}.
}

\examples{
file <- c(system.file("extdata/Mutect-vcf",
                      "Mutect.GRCh37.s1.vcf",
                      package = "ICAMS"))
if (requireNamespace("BSgenome.Hsapiens.1000genomes.hs37d5", quietly = TRUE)) {
  catalogs <-
    VCFsToCatalogsAndPlotToPdf(file, ref.genome = "hg19",
                               output.dir = tempdir(),
                               variant.caller = "mutect",
                               region = "genome",
                               base.filename = "Mutect")}
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utility_functions.R
\name{TransformCatalog}
\alias{TransformCatalog}
\title{Transform between counts and density spectrum catalogs
and counts and density signature catalogs}
\usage{
TransformCatalog(
  catalog,
  target.ref.genome = NULL,
  target.region = NULL,
  target.catalog.type = NULL,
  target.abundance = NULL
)
}
\arguments{
\item{catalog}{An SBS or DBS catalog as described in \code{\link{ICAMS}};
must \strong{not} be an ID (small insertions and deletions) catalog.}

\item{target.ref.genome}{A \code{ref.genome} argument as described in
\code{\link{ICAMS}}. If \code{NULL}, then defaults to the
\code{ref.genome} attribute of \code{catalog}.}

\item{target.region}{A \code{region} argument; see \code{\link{as.catalog}}
and \code{\link{ICAMS}}. If \code{NULL}, then defaults to the
  \code{region} attribute of \code{catalog}.}

\item{target.catalog.type}{A character string acting as a catalog type
identifier, one of "counts", "density", "counts.signature",
"density.signature"; see \code{\link{as.catalog}}. If \code{NULL}, then defaults to the
\code{catalog.type} attribute of \code{catalog}.}

\item{target.abundance}{A vector of counts, one for each source K-mer for mutations (e.g. for
strand-agnostic single nucleotide substitutions in trinucleotide -- i.e.
3-mer -- context, one count each for ACA, ACC, ACG, ... TTT). See
\code{\link{all.abundance}}. If \code{NULL}, the function tries to infer
\code{target.abundace} from the class of \code{catalog} and the value of
the \code{target.ref.genome}, \code{target.region}, and
\code{target.catalog.type}.}
}
\value{
A catalog as defined in \code{\link{ICAMS}}.
}
\description{
Transform between counts and density spectrum catalogs
and counts and density signature catalogs
}
\details{
Only the following transformations are legal:

\enumerate{

\item \code{counts -> counts} (deprecated, generates a warning;
we strongly suggest that you work with densities if comparing
spectra or signatures generated from data with
different underlying abundances.)

\item \code{counts -> density}

\item \code{counts -> (counts.signature, density.signature)}

\item \code{density -> counts} (the semantics are to
infer the genome-wide or exome-wide counts based on the
densities)

\item \code{density -> density} (a null operation, generates
a warning)

\item \code{density -> (counts.signature, density.signature)}

\item \code{counts.signature -> counts.signature} (used to transform
   between the source abundance and \code{target.abundance})

\item \code{counts.signature -> density.signature}

\item \code{counts.signature -> (counts, density)} (generates an error)

\item \code{density.signature -> density.signature} (a null operation,
generates a warning)

\item \code{density.signature -> counts.signature}

\item \code{density.signature -> (counts, density)} (generates an error)

}
}
\section{Rationale}{
  
The \code{\link{TransformCatalog}}
function transforms catalogs of mutational spectra or
signatures to account for differing abundances of the source
sequence of the mutations in the genome.

For example, mutations from
ACG are much rarer in the human genome than mutations from ACC
simply because CG dinucleotides are rare in the genome.
Consequently, there are two possible representations of
mutational spectra or signatures. One representation is
based on mutation counts as observed in a given genome
or exome,
and this approach is widely used, as, for example, at
https://cancer.sanger.ac.uk/cosmic/signatures, which
presents signatures based on observed mutation counts
in the human genome. We call these "counts-based spectra"
or "counts-based signatures".

Alternatively,
mutational spectra or signatures can be represented as
mutations per source sequence, for example
the number of ACT > AGT mutations occurring at all
ACT 3-mers in a genome. We call these "density-based
spectra" or "density-based signatures".

This function can also transform spectra
based on observed genome-wide counts to "density"-based
catalogs. In density-based catalogs
mutations are expressed as mutations per
source sequences. For example,
a density-based catalog represents
the proportion of ACCs mutated to
ATCs, the proportion of ACGs mutated to ATGs, etc.
This is
different from counts-based mutational spectra catalogs, which
contain the number of ACC > ATC mutations, the number of
ACG > ATG mutations, etc.

This function can also transform observed-count based
spectra or signatures from genome to exome based counts,
or between different species (since the abundances of
source sequences vary between genome and exome and between
species).
}

\examples{
file <- system.file("extdata",
                    "strelka.regress.cat.sbs.96.csv",
                    package = "ICAMS")
if (requireNamespace("BSgenome.Hsapiens.1000genomes.hs37d5", quietly = TRUE)) {
  catSBS96.counts <- ReadCatalog(file, ref.genome = "hg19", 
                                 region = "genome",
                                 catalog.type = "counts")
  catSBS96.density <- TransformCatalog(catSBS96.counts,
                                       target.ref.genome = "hg19",
                                       target.region = "genome",
                                       target.catalog.type = "density")}
}

#' Standard order of row names in a catalog.
#'
#' This data is designed for those
#' who need to create their own catalogs from formats not
#' supported by this package. The rownames denote the mutation
#' types.  For example, for SBS96 catalogs, the rowname
#'  AGAT represents a mutation from AGA > ATA.
#'
#' @format A list of character vectors indicating the standard
#'   orders of row names in catalogs.
#'
#' @note In ID (insertion and deletion) catalogs, deletion repeat sizes
#'   range from 0 to 5+, but for plotting and end-user documentation
#'   deletion repeat sizes range from 1 to 6+.
#'
#' @name CatalogRowOrder
#' 
#' @examples 
#' catalog.row.order$SBS96
#' # "ACAA" "ACCA" "ACGA" "ACTA" "CCAA" "CCCA" "CCGA" "CCTA" ...
#' # There are altogether 96 row names to denote the mutation types
#' # in SBS96 catalog.
#' 
"catalog.row.order"

#' Transcript ranges data
#'
#' Transcript ranges and strand information for a particular reference genome.
#'
#' @details 
#' 
#' This information is needed to generate catalogs that
#' depend on transcriptional
#' strand information, for example catalogs of 
#' class \code{SBS192Catalog}. 
#' 
#' \code{trans.ranges.GRCh37}:  \strong{Human} GRCh37. 
#' 
#' \code{trans.ranges.GRCh38}:  \strong{Human} GRCh38. 
#' 
#' \code{trans.ranges.GRCm38}:  \strong{Mouse} GRCm38. 
#' 
#' For these two tables, only genes that are associated with a CCDS ID are kept for transcriptional
#' strand bias analysis. 
#' 
#' This information is needed for \code{\link{StrelkaSBSVCFFilesToCatalog}}, \cr
#' \code{\link{StrelkaSBSVCFFilesToCatalogAndPlotToPdf}}, 
#' \code{\link{MutectVCFFilesToCatalog}}, \cr
#' \code{\link{MutectVCFFilesToCatalogAndPlotToPdf}},
#' \code{\link{VCFsToSBSCatalogs}} and \code{\link{VCFsToDBSCatalogs}}.
#'
#' @format A \code{\link[data.table]{data.table}} which contains transcript
#'   range and strand information for a particular reference genome.
#'   \code{colname}s are \code{chrom}, \code{start}, \code{end}, \code{strand},
#'   \code{gene.name}. It uses one-based coordinates.
#' 
#' @source \url{ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/GRCh37_mapping/gencode.v30lift37.annotation.gff3.gz}
#' 
#' @source \url{ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_30/gencode.v30.annotation.gff3.gz}
#' 
#' @source \url{ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M21/gencode.vM21.annotation.gff3.gz}
#' 
#' @name TranscriptRanges
#' 
#' @examples 
#' trans.ranges.GRCh37
#' # chrom    start      end strand gene.name
#' #     1    65419    71585      +     OR4F5
#' #     1   367640   368634      +    OR4F29
#' #     1   621059   622053      -    OR4F16
#' #     1   859308   879961      +    SAMD11
#' #     1   879583   894689      -     NOC2L
#' #   ...      ...      ...    ...       ...
#' 
NULL

#' @rdname TranscriptRanges
"trans.ranges.GRCh37"

#' @rdname TranscriptRanges
"trans.ranges.GRCh38"

#' @rdname TranscriptRanges
"trans.ranges.GRCm38"

#' K-mer abundances.
#'
#' An R list with one element each for 
#' \code{BSgenome.Hsapiens.1000genomes.hs37d5}, \cr
#' \code{BSgenome.Hsapiens.UCSC.hg38} and \code{BSgenome.Mmusculus.UCSC.mm10}.
#' Each element is in turn a sub-list keyed by 
#' \code{exome}, \code{transcript}, 
#' and \code{genome}. Each element of the sub list
#' is keyed by the number of rows in the catalog class (as a string, e.g. 
#' \code{"78"}, not \code{78}). The keys are:
#' 78 (\code{DBS78Catalog}), 96 (\code{SBS96Catalog}), 136 (\code{DBS136Catalog}),
#' 144 (\code{DBS144Catalog}), 192 (\code{SBS192Catalog}),
#'  and 1536 (\code{SBS1536Catalog}). So, for example to get the exome
#'  abundances for SBS96 catalogs for \code{BSgenome.Hsapiens.UCSC.hg38} exomes
#'  one would reference \cr
#'  \code{all.abundance[["BSgenome.Hsapiens.UCSC.hg38"]][["exome"]]["96"]} \cr
#'  or \code{all.abundance$BSgenome.Hsapiens.UCSC.hg38$exome$"96"}.
#'  The value of the abundance is an integer vector with the K-mers
#'  as names and each value being the count of that K-mer.
#'  
#' @format See Description.
#' 
#' @examples
#' all.abundance$BSgenome.Hsapiens.UCSC.hg38$transcript$`144` 
#' #        AA        AC        AG        AT        CA        CC ... 
#' #  90769160  57156295  85738416  87552737  83479655  63267896 ...
#' # There are 90769160 AAs on the sense strands of transcripts in
#' # this genome.

"all.abundance"

# Quiets concerns of R CMD check about no visible binding for global variable
if(getRversion() >= "2.15.1") {
  utils::globalVariables(c("all.abundance",
                           "BSgenome.Mmusculus.UCSC.mm10",
                           "POS2", "POS", 
                           "bothstrand", "strand", ".", "CHROM",
                           "ALT", "count", "rn", "occurrences", "type", "strand",
                           "bothstrand", "chrom", "exome.start", "exome.end",
                           "count", "REF", "seq.21bases", "N", "pyr.mut", "nrn",
                           "mutation", "LOW", "ID", "REF.x", "REF.y", "ALT.x",
                           "ALT.y", "ref2alt", "minus1bs", "minus2bs", "plus1bs",
                           "plus2bs", "POS.plus.one", "HIGH", "POS.y", "VAF.x",
                           "VAF.y", "delete.flag", "trans.ranges.GRCh37", "cols"))
}
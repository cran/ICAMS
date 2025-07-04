#' @title Return the number of repeat units in which a deletion is embedded
#'
#' @param context A string that embeds \code{rep.unit.seq} at position
#'  \code{pos}
#'
#' @param rep.unit.seq A substring of \code{context} at \code{pos}
#'  to \code{pos + nchar(rep.unit.seq) - 1}, which is the repeat
#'   unit sequence.
#'
#' @param pos The position of \code{rep.unit.seq} in \code{context}.
#'
#' @return The number of repeat units in which \code{rep.unit.seq} is
#' embedded, not including
#' the input \code{rep.unit.seq} in the count.
#'
#' @details
#' 
#' This function is primarily for internal use, but we export it
#' to document the underlying logic.
#'
#' For example \code{FindMaxRepeatDel("xyaczt", "ac", 3)}
#' returns 0.
#'
#' If
#' \code{substr(context, pos, pos + nchar(rep.unit.seq) - 1) != rep.unit.seq}
#'  then stop.
#'
#' If this functions returns 0, then it is necessary to
#'   look for microhomology using the function
#'   \code{\link{FindDelMH}}.
#'   
#' \strong{Warning}\cr
#' This function depends on the variant caller having 
#' "aligned" the deletion within the context of the
#' repeat.
#' 
#' For example, a deletion of \code{CAG} in the repeat
#' \preformatted{
#' GTCAGCAGCATGT
#' }
#' can have 3 "aligned" representations as follows:
#'  \preformatted{
#' CT---CAGCAGGT
#' CTCAG---CAGGT
#' CTCAGCAG---GT
#' }
#' In these cases this function will return 2. (Please
#' not that the return value does not include the
#' \code{rep.uni.seq} in the count.)
#' 
#' However, the same deletion can also have an "unaligned" representation, such as
#'  \preformatted{
#' CTCAGC---AGGT
#' }
#' (a deletion of \code{AGC}).
#' 
#' In this case this function will return 1 (a deletion of \code{AGC}
#' in a 2-element repeat of \code{AGC}).
#' 
#' @inheritSection VCFsToCatalogsAndPlotToPdf ID classification
#' 
#' @examples 
#' FindMaxRepeatDel("xyACACzt", "AC", 3) # 1
#' FindMaxRepeatDel("xyACACzt", "CA", 4) # 0
#'
#' @export
FindMaxRepeatDel <- function(context, rep.unit.seq, pos) {
  n <- nchar(rep.unit.seq)
  stopifnot(substring(context, pos, pos + n - 1) == rep.unit.seq)

  # Look left
  i <- pos - n
  left.count <- 0
  while (i > 0) {
    if (substr(context, i, i + n - 1) == rep.unit.seq) {
      left.count <- left.count + 1
      i <- i - n
    } else break
  }

  # Look right
  right.count <- 0
  i <- pos + n
  tot.len <- nchar(context)
  while ((i + n - 1) <= tot.len) {
    if (substr(context, i, i + n - 1) == rep.unit.seq) {
      right.count <- right.count + 1
      i <- i + n
    } else break
  }

  # IMPORTANT - in the catalog version of the the mutation class we exclude the
  # deleted unit from the count, but in plotting we include it.
  return(left.count + right.count)
}

#' @title Return the length of microhomology at a deletion
#'
#' @details
#'
#' This function is primarily for internal use, but we export it
#' to document the underlying logic.
#'
#' Example:
#'
#' \code{GGCTAGTT} aligned to \code{GGCTAGAACTAGTT} with
#' a deletion represented as:
#' \preformatted{
#'
#' GGCTAGAACTAGTT
#' GG------CTAGTT GGCTAGTT GG[CTAGAA]CTAGTT
#'                            ----   ----
#' }
#'
#' Presumed repair mechanism leading to this:
#'
#' \preformatted{
#'   ....
#' GGCTAGAACTAGTT
#' CCGATCTTGATCAA
#'
#' =>
#'
#'   ....
#' GGCTAG      TT
#' CC      GATCAA
#'         ....
#'
#' =>
#'
#' GGCTAGTT
#' CCGATCAA
#'
#' }
#'
#' Variant-caller software can represent the
#' same deletion in several
#' different, but completely equivalent, ways.
#'
#' \preformatted{
#'
#' GGC------TAGTT GGCTAGTT GGC[TAGAAC]TAGTT
#'                           * ---  * ---
#'
#' GGCT------AGTT GGCTAGTT GGCT[AGAACT]AGTT
#'                           ** --  ** --
#'
#' GGCTA------GTT GGCTAGTT GGCTA[GAACTA]GTT
#'                           *** -  *** -
#'
#' GGCTAG------TT GGCTAGTT GGCTAG[AACTAG]TT
#'                           ****   ****
#' }
#' 
#' This function finds:
#'
#' \enumerate{
#'
#' \item The maximum match of undeleted sequence to the left
#' of the deletion that is
#' identical to the right end of the deleted sequence, and
#'
#' \item The maximum match of undeleted sequence to the right
#' of the deletion that
#' is identical to the left end of the deleted sequence.
#'}
#'
#' The microhomology sequence is the concatenation of items
#' (1) and (2).
#'
#' \strong{Warning}\cr
#' A deletion in a \emph{repeat} can also be represented
#' in several different ways. A deletion in a repeat
#' is abstractly equivalent to a deletion with microhomology that
#' spans the entire deleted sequence. For example;
#'
#' \preformatted{
#' GACTAGCTAGTT
#' GACTA----GTT GACTAGTT GACTA[GCTA]GTT
#'                         *** -*** -
#' }
#'
#' is really a repeat
#'
#' \preformatted{
#' GACTAG----TT GACTAGTT GACTAG[CTAG]TT
#'                         **** ----
#'
#' GACT----AGTT GACTAGTT GACT[AGCT]AGTT
#'                         ** --** --
#' }
#'
#' \strong{This function only flags these
#' "cryptic repeats" with a -1 return; it does not figure
#' out the repeat extent.}
#'
#' @param context The deleted sequence plus ample surrounding
#'   sequence on each side (at least as long as \code{del.sequence}).
#'
#' @param deleted.seq The deleted sequence in \code{context}.
#'
#' @param pos The position of \code{del.sequence} in \code{context}.
#'
#' @param trace If > 0, then generate various 
#' messages showing how the computation is carried out.
#' 
#' @param warn.cryptic if \code{TRUE} generating a warning
#'  if there is a cryptic repeat (see the example).
#' 
#' @return The length of the maximum microhomology of \code{del.sequence}
#'   in \code{context}.
#'   
#' @inheritSection VCFsToCatalogsAndPlotToPdf ID classification
#'
#' @export
#' 
#' @examples 
#' # GAGAGG[CTAGAA]CTAGTT
#' #        ----   ----
#' FindDelMH("GGAGAGGCTAGAACTAGTTAAAAA", "CTAGAA", 8, trace = 0)  # 4
#' 
#' # A cryptic repeat
#' # 
#' # TAAATTATTTATTAATTTATTG
#' # TAAATTA----TTAATTTATTG = TAAATTATTAATTTATTG
#' # 
#' # equivalent to
#' #
#' # TAAATTATTTATTAATTTATTG
#' # TAAAT----TATTAATTTATTG = TAAATTATTAATTTATTG 
#' # 
#' # and
#' #
#' # TAAATTATTTATTAATTTATTG
#' # TAAA----TTATTAATTTATTG = TAAATTATTAATTTATTG  
#' 
#' FindDelMH("TAAATTATTTATTAATTTATTG", "TTTA", 8, warn.cryptic = FALSE) # -1

FindDelMH <- 
  function(context, deleted.seq, pos, trace = 0, warn.cryptic = TRUE) {
  n <- nchar(deleted.seq)

  if (substr(context, pos, pos + n - 1) != deleted.seq) {
    stop("substr(context, pos, pos + n - 1) != deleted.seq\n",
         substr(context, pos, pos + n - 1), " ", deleted.seq, "\n")
  }
  # The context on the left has to be longer then deleted.seq
  stopifnot((pos - 1) > n)
  # The context on the right as to be longer than deleted.seq
  stopifnot(nchar(context) - (pos + n - 1) > n)

  ds <- unlist(strsplit(deleted.seq, ""))

  # Look for microhomology to the left in context.
  left.context <- substr(context, pos - n, pos - 1)
  left <- unlist(strsplit(x = left.context, ""))
  for (i in n:1) {
    if (ds[i] != left[i]) break
    if (i == 1) {
      stop("There is a repeated ", deleted.seq,
           " to the left of the deleted ",
           deleted.seq)
    }
  }
  left.len <- n - i
  if (trace > 0 ) {
    message("Left break", i, "\nleft.len =", left.len, "\n")
  }

  # Look for microhomology to the right in context.
  right.context <- substr(context, pos + n, (pos + 2 * n) - 1)
  right <- unlist(strsplit(x = right.context, ""))
  for (i2 in 1:n) {
    if (ds[i2] != right[i2]) break
    if (i2 == n) {
      stop("There is a repeated ", deleted.seq,
           " to the right of the deleted ",
           deleted.seq)
    }
  }
  right.len <- i2 - 1
  if (trace > 0) {
    message("Right break", i2, "\nright.len =", right.len, "\n")
    message(paste0(left.context, "[",
               deleted.seq, "]",
               right.context, "\n"))
    # Print out strings of ** and -- to indicated the sequences involved in the
    # microhomology; left.context and right.context are the same length as
    # deleted.seq
    message(
      paste(c(
      rep(" ", n - left.len),
      rep("*", left.len),
      " ",
      rep("-", right.len),
      rep(" ", n - (left.len + right.len)),
      rep("*", left.len),
      " ",
      rep("-", right.len),
      "\n"
    ), collapse = ""))

  }
  if (left.len + right.len >= n) {
    if (warn.cryptic) warning("There is unhandled cryptic repeat, returning -1")
    return(-1)
  }
  return(left.len + right.len)
}

#' @title Return the number of repeat units in which an insertion
#' is embedded.
#'
#' @param context A string into which \code{rep.unit.seq} was
#'  inserted at position \code{pos}.
#'
#' @param rep.unit.seq The inserted sequence and candidate repeat unit
#' sequence.
#'
#' @param pos \code{rep.unit.seq} is understood to be inserted between
#'   positions \code{pos} and \code{pos + 1}.
#'
#' @return If same sequence as \code{rep.unit.seq} occurs ending at
#'   \code{pos} or starting at \code{pos + 1} then the number of
#'   repeat units before the insertion, otherwise 0.
#'
#'
#' @details
#' For example
#'
#' \preformatted{
#'
#' rep.unit.seq = ac
#' pos = 2
#' context = xyaczt
#' return 1
#'
#' rep.unit.seq = ac
#' pos = 4
#' context = xyaczt
#' return 1
#'
#' rep.unit.seq = cgct
#' pos = 2
#' rep.unit.seq = at
#' return 0
#'
#' context = gacacacacg
#' rep.unit.seq = ac
#' pos = any of 1, 3, 5, 7, 9
#' return 4
#' }
#'
#' If 
#' \code{substr(context, pos, pos + nchar(rep.unit.seq) - 1) != rep.unit.seq},
#' then stop.
#'
#' @keywords internal
FindMaxRepeatIns <- function(context, rep.unit.seq, pos) {
  n <- nchar(rep.unit.seq)

  # If rep.unit.seq is in context adjacent to pos, it might start at 
  # pos + 1 - len(rep.unit.seq), so look left
  left.count <- 0
  p <- pos + 1 - n
  while (p > 0) {
    if (substring(context, p, p + n - 1) == rep.unit.seq) {
      left.count <- left.count + 1
    } else break
    p <- p - n
  }

  # If rep.unit.seq is repeated in context it might start at pos + 1,
  # so look right.
  right.count <- 0
  p <- pos + 1
  tot.len <- nchar(context)
  while ((p + n - 1) <= tot.len) {
    if (substr(context, p, p + n - 1) == rep.unit.seq) {
      right.count <- right.count + 1
    } else break
    p <- p + n
  }

  return(left.count + right.count)
}


#' Given a deletion and its sequence context, categorize it
#' 
#' This function is primarily for internal use, but we export it
#' to document the underlying logic.
#' 
#' See \url{https://github.com/steverozen/ICAMS/blob/v3.0.9-branch/data-raw/PCAWG7_indel_classification_2021_09_03.xlsx}
#' for additional information on deletion mutation classification.
#' 
#' This function first handles deletions in homopolymers, then
#' handles deletions in simple repeats with
#' longer repeat units, (e.g. \code{CACACACA}, see
#' \code{\link{FindMaxRepeatDel}}),
#' and if the deletion is not in a simple repeat,
#' looks for microhomology (see \code{\link{FindDelMH}}).
#' 
#' See the code for unexported function \code{\link{CanonicalizeID}}
#' and the functions it calls for handling of insertions.
#'
#' @param context The deleted sequence plus ample surrounding
#'   sequence on each side (at least as long as \code{del.seq}).
#'
#' @param del.seq The deleted sequence in \code{context}.
#'
#' @param pos The position of \code{del.sequence} in \code{context}.
#'
#' @param trace If > 0, then generate messages tracing
#' how the computation is carried out.
#
#' @return A string that is the canonical representation
#'  of the given deletion type. Return \code{NA} 
#'  and raise a warning if
#'  there is an un-normalized representation of
#'  the deletion of a repeat unit.
#'  See \code{FindDelMH} for details.
#'  (This seems to be very rare.)
#'
#' @examples 
#' Canonicalize1Del("xyAAAqr", del.seq = "A", pos = 3) # "DEL:T:1:2"
#' Canonicalize1Del("xyAAAqr", del.seq = "A", pos = 4) # "DEL:T:1:2"
#' Canonicalize1Del("xyAqr", del.seq = "A", pos = 3)   # "DEL:T:1:0"
#'
#' @export

Canonicalize1Del <- function(context, del.seq, pos, trace = 0) {
  # Is the deletion involved in a repeat?
  rep.count <- FindMaxRepeatDel(context, del.seq, pos)

  rep.count.string <- ifelse(rep.count >= 5, "5+", as.character(rep.count))
  deletion.size <- nchar(del.seq)
  deletion.size.string <- 
    ifelse(deletion.size >= 5, "5+", as.character(deletion.size))

  # Category is "1bp deletion"
  if (deletion.size == 1) {
    if (del.seq == "G") del.seq <- "C"
    if (del.seq == "A") del.seq <- "T"
    return(paste0("DEL:", del.seq, ":1:", rep.count.string))
  }

  # Category is ">2bp deletion"
  if (rep.count > 0) {
    return(
      paste0("DEL:repeats:", deletion.size.string, ":", rep.count.string))
  }

  # We have to look for microhomology
  microhomology.len <- FindDelMH(context, del.seq, pos, trace = trace)
  if (microhomology.len == -1) {
    warning("Non-normalized deleted repeat ignored:",
            "\ncontext: ", context,
            "\ndeleted sequence: ", del.seq,
            "\nposition of deleted sequence: ", pos)
    return(NA)
  }

  if (microhomology.len == 0) {
    stopifnot(rep.count.string == 0)
    # Categorize and return non-repeat, non-microhomology deletion
    return(paste0("DEL:repeats:", deletion.size.string, ":0"))
  }

  microhomology.len.str <-
    ifelse(microhomology.len >= 5, "5+", as.character(microhomology.len))

  return(paste0(
    "DEL:MH:", deletion.size.string, ":", microhomology.len.str))
}

#' @title Given an insertion and its sequence context, categorize it.
#'
#' @param context The deleted sequence plus ample surrounding
#'   sequence on each side (at least as long as \code{ins.sequence} * 6).
#'
#' @param ins.sequence The deleted sequence in \code{context}.
#'
#' @param pos The position of \code{ins.sequence} in \code{context}.
#'
#' @param trace If > 0, then generate
#' messages tracing how the computation is carried out.
#
#' @return A string that is the canonical representation of 
#' the given insertion type.
#'
#' @keywords internal
Canonicalize1INS <- function(context, ins.sequence, pos, trace = 0) {
  if (trace > 0) {
   message("Canonicalize1ID(", context, ",", ins.sequence, ",", pos, "\n")
  }
  rep.count <- FindMaxRepeatIns(context, ins.sequence, pos)
  rep.count.string <- ifelse(rep.count >= 5, "5+", as.character(rep.count))
  insertion.size <- nchar(ins.sequence)
  insertion.size.string <-
    ifelse(insertion.size >= 5, "5+", as.character(insertion.size))

  if (insertion.size == 1) {
    if (ins.sequence == "G") ins.sequence <- "C"
    if (ins.sequence == "A") ins.sequence <- "T"
    retval <-
      paste0("INS:", ins.sequence, ":1:", rep.count.string)
    if (trace > 0) message(retval)
    return(retval)
  }
  retval <-
    paste0("INS:repeats:", insertion.size.string, ":", rep.count.string)
  if (trace > 0) message(retval)
  return(retval)
}

#' @title Given a single insertion or deletion in context categorize it.
#'
#' @param context Ample surrounding
#'   sequence on each side of the insertion or deletion.
#'
#' @param ref The reference allele (vector of length 1)
#'
#' @param alt The alternative allele (vector of length 1)
#'
#' @param pos The position of \code{ins.or.del.seq} in \code{context}.
#'
#' @param trace If > 0, then generate messages tracing
#' how the computation is carried out.
#
#' @return A string that is the canonical representation
#'  of the type of the given
#'  insertion or deletion.
#'  Return \code{NA} 
#'  and raise a warning if
#'  there is an un-normalized representation of
#'  the deletion of a repeat unit.
#'  See \code{FindDelMH} for details.
#'  (This seems to be very rare.)
#'
#' @keywords internal
Canonicalize1ID <- function(context, ref, alt, pos, trace = 0) {
  if (trace > 0) {
    message("Canonicalize1ID(", context, ",", ref, ",", alt, ",", pos, "\n")
  }
  if (nchar(alt) < nchar(ref)) {
    # A deletion
    return(Canonicalize1Del(context, ref, pos + 1, trace))
  } else if (nchar(alt) > nchar(ref)) {
    # An insertion
    return(Canonicalize1INS(context, alt, pos, trace))
  } else {
    stop("Non-insertion / non-deletion found: ", ref, " ", alt, " ", context)
  }
}

#' @title Determine the mutation types of insertions and deletions.
#'
#' @param context A vector of ample surrounding
#'   sequence on each side the variants
#'
#' @param ref Vector of reference alleles
#'
#' @param alt Vector of alternative alleles
#'
#' @param pos Vector of the positions of the insertions and deletions in
#'  \code{context}.
#'
#' @return A vector of strings that are the canonical representations
#'  of the given insertions and deletions.
#'
#' @importFrom utils head
#'
#' @keywords internal
CanonicalizeID <- function(context, ref, alt, pos) {

  if (all(substr(ref, 1, 1) == substr(alt, 1, 1))) {
    ref <- substr(ref, 2, nchar(ref))
    alt <- substr(alt, 2, nchar(alt))
  } else {
    stopifnot(ref != "" | alt != "")
  }

  ret <- mapply(Canonicalize1ID, context, ref, alt, pos, 0)
  return(ret)
}

#' Check and return the ID mutation matrix
#'
#' @param annotated.vcf An annotated ID VCF with additional column
#'   \code{ID.class} showing ID classification for each variant.
#'   
#' @param discarded.variants A \code{data.frame} which contains rows of ID
#'   variants which are excluded in the analysis.
#'   
#' @param ID.mat The ID mutation count matrix.
#' 
#' @param ID166.mat The ID166 mutation count matrix.
#' 
#' @param return.annotated.vcf Whether to return \code{annotated.vcf}. Default is
#'   FALSE.
#'
#' @inheritSection CreateOneColIDMatrix Value
#' 
#' @keywords internal
CheckAndReturnIDMatrix <- 
  function(annotated.vcf, discarded.variants, ID.mat, ID166.mat,
           return.annotated.vcf = FALSE) {
    if (nrow(discarded.variants) == 0) {
      if (return.annotated.vcf == FALSE) {
        return(list(catalog = ID.mat, catID166 = ID166.mat))
      } else {
        return(list(catalog = ID.mat, catID166 = ID166.mat, annotated.vcf = annotated.vcf))
      }
    } else {
      if (return.annotated.vcf == FALSE) {
        return(list(catalog = ID.mat, catID166 = ID166.mat,
                    discarded.variants = discarded.variants))
      } else {
        return(list(catalog = ID.mat, catID166 = ID166.mat,
                    discarded.variants = discarded.variants,
                    annotated.vcf = annotated.vcf))
      }
    }
  }
  
#' @title Create one column of the matrix for an indel catalog from *one* in-memory VCF.
#'
#' @param ID.vcf An in-memory VCF as a data.frame annotated by the
#'   \code{\link{AnnotateIDVCF}} function. It must only
#'   contain indels and must \strong{not} contain SBSs
#'   (single base substitutions), DBSs, or triplet
#'   base substitutions, etc.
#'
#'   One design decision for variant callers is the representation of "complex
#'   indels", e.g. mutations e.g. CAT > GC. Some callers represent this as C>G,
#'   A>C, and T>_. Others might represent it as CAT > CG. Multiple issues can
#'   arise. In PCAWG, overlapping indel/SBS calls from different callers were
#'   included in the indel VCFs.
#'
#' @param SBS.vcf This argument defaults to \code{NULL} and
#'   is not used. Ideally this should be an in-memory SBS VCF 
#'   as a data frame. The rational is that for some data,
#'   complex indels might be represented as an indel with adjoining
#'   SBSs. 
#'   
#' @param sample.id Usually the sample id, but defaults to "count".
#'
#' @section Value: A list of two 1-column ID matrices containing the mutation catalog
#'   information and the annotated VCF with ID categories information added. If
#'   some ID variants were excluded in the analysis, an additional element
#'   \code{discarded.variants} will appear in the return list.
#'   
#' @keywords internal
CreateOneColIDMatrix <- function(ID.vcf, SBS.vcf = NULL, sample.id = "count",
                                 return.annotated.vcf = FALSE) {
  
  CheckForEmptyIDVCF <- function(ID.vcf, return.annotated.vcf) {
    if (nrow(ID.vcf) == 0) {
      # Create 1-column matrix with all values being 0 and the correct row labels.
      catID <- matrix(0, nrow = length(ICAMS::catalog.row.order$ID), ncol = 1,
                      dimnames = list(ICAMS::catalog.row.order$ID, sample.id))
      catID166 <- 
        matrix(0, nrow = length(ICAMS::catalog.row.order$ID166), ncol = 1,
               dimnames = list(ICAMS::catalog.row.order$ID166, sample.id))
      if (return.annotated.vcf == FALSE) {
        return(list(catalog = catID, catID166 = catID166))
      } else {
        return(list(catalog = catID, catID166 = catID166, 
                    annotated.vcf = ID.vcf))
      }
    } else {
      return(FALSE)
    }
  }
  
  ret1 <- CheckForEmptyIDVCF(ID.vcf = ID.vcf, 
                             return.annotated.vcf = return.annotated.vcf)
  if (!is.logical(ret1)) {
    return(ret1)
  }
  
  # Create an empty data frame for discarded variants
  discarded.variants <- ID.vcf[0, ]
  
  if (!is.null(SBS.vcf)) 
    warning("Argument SBS.vcf in CreateOneColIDMatrix is always ignored")

  canon.ID <- CanonicalizeID(ID.vcf$seq.context,
                             ID.vcf$REF,
                             ID.vcf$ALT,
                             ID.vcf$seq.context.width + 1)
  
  out.ID.vcf <- cbind(ID.vcf, ID.class = canon.ID)
  
  idx <- which(is.na(out.ID.vcf$ID.class))
  if (length(idx) > 0) {
    warning("Variants with NA ID.class are discarded, see element ",
            "discarded.variants in the return value for more details")
    out.ID.vcf.to.remove <- out.ID.vcf[idx, ]
    out.ID.vcf.to.remove$discarded.reason <- 
      paste0("ID variant has an un-normalized representation of the deletion ",
             "of a repeat unit. See ICAMS::Canonicalize1Del for more details")
    discarded.variants <- 
      dplyr::bind_rows(discarded.variants, out.ID.vcf.to.remove)
    out.ID.vcf <- out.ID.vcf[-idx, ]
  }
  
  idx1 <- which(!out.ID.vcf$ID.class %in% ICAMS::catalog.row.order$ID)
  if (length(idx1) > 0) {
    warning("ID variants which cannot be categorized according to the ",
            "canonical representation are discarded, see element ",
            "discarded.variants in the return value for more details")
    out.ID.vcf.to.remove <- out.ID.vcf[idx1, ]
    out.ID.vcf.to.remove$discarded.reason <- 
      paste0("ID variant cannot be categorized according to the canonical ", 
             "representation. See ICAMS::catalog.row.order$ID for more details")
    discarded.variants <- 
      dplyr::bind_rows(discarded.variants, out.ID.vcf.to.remove)
    out.ID.vcf <- out.ID.vcf[-idx1, ]
  }
  
  ret2 <- CheckForEmptyIDVCF(ID.vcf = out.ID.vcf, 
                             return.annotated.vcf = return.annotated.vcf)
  if (!is.logical(ret2)) {
    return(ret2)
  }
  
  # Create the ID catalog matrix (83 rows)
  
  # One ID mutation can be represented by more than 1 row in out.ID.vcf if the mutation
  # position falls into the range of multiple transcripts. When creating the
  # ID83 catalog, we only need to count these mutations once.
  tmp <- out.ID.vcf %>% dplyr::group_by(CHROM, POS) %>%
    dplyr::summarise(REF = REF[1], ALT = ALT[1], ID.class = ID.class[1])
  
  ID.class <- tmp$ID.class
  tab.ID <- table(ID.class)

  row.order <- data.table(rn = ICAMS::catalog.row.order$ID)

  ID.dt <- as.data.table(tab.ID)
  # ID.dt has two columns, names ID.class (from the table() function)
  # and N (the count)

  ID.dt2 <-
    merge(row.order, ID.dt, by.x = "rn", by.y = "ID.class", all.x = TRUE)
  ID.dt2[ is.na(N) , N := 0]
  if (!setequal(unlist(ID.dt2$rn), ICAMS::catalog.row.order$ID)) {
    stop("\nThe set of ID categories generated from sample ", sample.id,
         " is not the same as the catalog row order for ID used in ICAMS.",
         "\nSee catalog.row.order$ID for more details.")
  }

  ID.mat <- as.matrix(ID.dt2[ , 2])
  rownames(ID.mat) <- ID.dt2$rn
  colnames(ID.mat) <- sample.id
  ID.mat <- ID.mat[ICAMS::catalog.row.order$ID, , drop = FALSE]
  
  # Create the ID166 catalog matrix (genic-intergenic indel catalog, 166 rows)
  
  # Add a column showing which DNA region a mutation falls into
  # "G" stands for genic region, "I" stands for intergenic region
  out.ID.vcf2 <- out.ID.vcf %>% 
    dplyr::mutate(dna.region = ifelse(trans.strand %in% c("+", "-"), "G", "I"))
  
  out.ID.vcf3 <- out.ID.vcf2 %>% 
    dplyr::mutate(ID166.class = paste0(dna.region, ":", ID.class))
  
  # One ID mutation can be represented by more than 1 row in out.ID.vcf3 if the mutation
  # position falls into the range of multiple transcripts. When creating the
  # ID166 catalog, we only need to count these mutations once.
  out.ID.vcf4 <- out.ID.vcf3 %>% dplyr::group_by(CHROM, POS) %>%
    dplyr::summarise(REF = REF[1], ALT = ALT[1], ID166.class = ID166.class[1])
  
  ID166.class <- out.ID.vcf4$ID166.class
  tab.ID166 <- table(ID166.class)
  
  row.order.ID166 <- data.table(rn = ICAMS::catalog.row.order$ID166)
  
  ID166.dt <- as.data.table(tab.ID166)
  # ID.dt has two columns, names ID166.class (from the table() function)
  # and N (the count)
  
  ID166.dt2 <-
    merge(row.order.ID166, ID166.dt, by.x = "rn", by.y = "ID166.class", all.x = TRUE)
  ID166.dt2[ is.na(N) , N := 0]
  if (!setequal(unlist(ID166.dt2$rn), ICAMS::catalog.row.order$ID166)) {
    stop("\nThe set of ID166 categories generated from sample ", sample.id,
         " is not the same as the catalog row order for ID166 used in ICAMS.",
         "\nSee catalog.row.order$ID166 for more details.")
  }
  
  ID166.mat <- as.matrix(ID166.dt2[ , 2])
  rownames(ID166.mat) <- ID166.dt2$rn
  colnames(ID166.mat) <- sample.id
  ID166.mat <- ID166.mat[ICAMS::catalog.row.order$ID166, , drop = FALSE]
  
  CheckAndReturnIDMatrix(annotated.vcf = out.ID.vcf3, 
                         discarded.variants = discarded.variants, 
                         ID.mat = ID.mat, ID166.mat = ID166.mat, 
                         return.annotated.vcf = return.annotated.vcf)
                         
}
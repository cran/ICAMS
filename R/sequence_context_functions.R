#' Create position probability matrix (PPM) for *one* sample from
#' a Variant Call Format (VCF) file.
#'
#' @param vcf One in-memory data frame of pure SBS mutations -- no DBS or 3+BS
#'   mutations.
#'
#' @param ref.genome A \code{ref.genome} argument as described in
#'   \code{\link{ICAMS}}.
#'
#' @param seq.context.width The number of preceding and following bases to be
#'   extracted around the mutated position from \code{ref.genome}.
#'
#' @importFrom utils tail
#'
#' @return A position probability matrix (PPM). 
#'
#' @keywords internal
CreateOnePPMFromSBSVCF <- function(vcf, ref.genome, seq.context.width) {
  stopifnot(nrow(vcf) != 0)
  vcf <- AddSeqContext(vcf, ref.genome = ref.genome,
                       seq.context.width = seq.context.width)
  dt <- data.table(vcf)

  # Map the sequence context column in dt to strand-agnostic category
  idx <- substr(dt[[tail(names(dt), 1)]], seq.context.width + 1,
                seq.context.width + 1) %in% c("A", "G")
  dt[[tail(names(dt), 1)]][idx] <- revc(dt[[tail(names(dt), 1)]][idx])

  # Create the position probability matrix (PPM)
  GetPPM <- function(idx, seq.context) {
    base <- substr(seq.context, idx, idx)
    count <- table(factor(base, levels = c("A", "C", "G", "T")))
    return(as.matrix(count / sum(count)))
  }
  mat <- sapply(1:nchar(dt[[tail(names(dt), 1)]][1]), FUN = GetPPM,
                seq.context = dt[[tail(names(dt), 1)]])
  rownames(mat) <- c("A", "C", "G", "T")
  colnames(mat) <- c(paste0(seq.context.width:1, "bp 5'"), "target",
                     paste0(1:seq.context.width, "bp 3'"))
  return(mat)
}

#' Create position probability matrices (PPM) from a list of SBS vcfs
#'
#' @param list.of.SBS.vcfs List of in-memory data frames of pure SBS mutations
#'   -- no DBS or 3+BS mutations.
#'
#' @param ref.genome A \code{ref.genome} argument as described in
#'   \code{\link{ICAMS}}.
#'
#' @param seq.context.width The number of preceding and following bases to be
#'   extracted around the mutated position from \code{ref.genome}.
#'
#' @return A list of position probability matrices (PPM).
#'
#' @keywords internal
CreatePPMFromSBSVCFs <-
  function(list.of.SBS.vcfs, ref.genome, seq.context.width) {
    list.of.PPM <- lapply(list.of.SBS.vcfs, FUN = CreateOnePPMFromSBSVCF,
                          ref.genome = ref.genome,
                          seq.context.width = seq.context.width)
    return(list.of.PPM)
  }

#' Get all the sequence contexts of the indels in a given 1 base-pair indel
#' class from a VCF
#'
#' @param annotated.vcf An in-memory \code{data.frame} or similar table
#'  containing "VCF" (variant call format) data as created by
#'  \code{\link{VCFsToIDCatalogs}}
#'   with argument \code{return.annotated.vcfs = TRUE}.
#'
#' @param indel.class A single character string that denotes a 1 base pair
#'   insertion or deletion, as taken from \code{ICAMS::catalog.row.order$ID}.
#'   Insertions or deletions into or from 5+ base-pair homopolymers are not
#'   supported.
#'
#' @param flank.length The length of flanking bases around the position or
#'   homopolymer targeted by the indel.
#'
#' @return A list of all sequence contexts for the specified \code{indel.class}.
#'
#' @keywords internal
#'
SymmetricalContextsFor1BPIndel <-
  function(annotated.vcf, indel.class, flank.length = 5){
    
    if(!indel.class %in% ICAMS::catalog.row.order$ID[c(1:5, 7:11, 13:17, 19:23)]){
      stop("Argument indel.class value ", indel.class, " not supported")
    }
    
    if (!"ID.class" %in% colnames(annotated.vcf)) {
      stop("Argument annotated.vcf does not have columnn ID.class; ",
           "use ICAMS::VCFsToIDCatalogs with argument return.annotated.vcfs = TRUE")
    }
    
    
    annotated.vcf.this.class <-
      annotated.vcf[annotated.vcf$ID.class %in% indel.class, ]
    
    extended_sequence_context <-
      apply(annotated.vcf.this.class, 1,
            function(x){
              Get1BPIndelFlanks(sequence     = x["seq.context"],
                                ref          = x["REF"],
                                alt          = x["ALT"],
                                indel.class  = indel.class,
                                flank.length = flank.length)})
    
    return(extended_sequence_context)
  }

#' Get all the sequence contexts of the indels in a given 1 base-pair indel
#' class
#'
#' @param sequence A string from \code{seq.context} column from in-memory
#'   \code{data.frame} or similar table containing "VCF" (variant call format)
#'   data as created by \code{\link{AnnotateIDVCF}}.
#'
#' @param ref A string from \code{REF} column from in-memory \code{data.frame}
#'   or similar table containing "VCF" (variant call format) data as created by
#'   \code{\link{AnnotateIDVCF}}.
#'
#' @param alt A string from \code{ALT} column from in-memory \code{data.frame}
#'   or similar table containing "VCF" (variant call format) data as created by
#'   \code{\link{AnnotateIDVCF}}.
#'
#' @param indel.class A single character string that denotes a 1 base pair
#'   insertion or deletion, as taken from \code{ICAMS::catalog.row.order$ID}.
#'   Insertions or deletions into / from 5+ base-pair homopolymers are not
#'   supported.
#'
#' @param flank.length The length of flanking bases around the position or
#'   homopolymer targeted by the indel.
#'
#' @return A string for the specified \code{sequence} and \code{indel.class}.
#'
#' @keywords internal
Get1BPIndelFlanks <- function(sequence, ref, alt, indel.class, flank.length = 5){
  
  # Un-comment the following to generate test function calls.
  # cat(
  #  paste0('Get1BPIndelFlanks("', sequence, '", "', ref, "\",  \"", alt, "\",  \"",indel.class, "\")\n")
  # )
  
  # sanity check; assume the input VCF provides one base of context to the left
  # of the indel, e.g. insertion A -> AT, deletion CT -> C
  stopifnot(nchar(ref) + nchar(alt) == 3)
  
  # indel.class is string such as "DEL:T:1:3"
  split.indel.class <- unlist(strsplit(indel.class, ":"))
  
  indel.base <- split.indel.class[2] # The base inserted or deleted (T or C)
  
  homopolymer.length <-  as.numeric(split.indel.class[4])
  stopifnot(homopolymer.length %in% 0:4)
  
  mid.base <- (nchar(sequence) + 1) / 2
  # For deletions this is a fraction; the substring call below still works.
  
  ins.or.del <- split.indel.class[1]
  
  if (ins.or.del == "INS" & homopolymer.length == 0) {
    if (nchar(alt) == 2) {
      alt <- substr(alt, 2, 2)
    }
    stopifnot(nchar(alt) == 1)
    seq.context <-
      substring(sequence, mid.base - flank.length + 1, mid.base + flank.length)
    
    # alt could be A, C, G, T, need to "normalize" to C or T
    if(alt != indel.base) {
      seq.context <- revc(seq.context)
    }
  } else {
    
    if (ins.or.del == "DEL"){
      homopolymer.length <- homopolymer.length + 1
    }
    
    ##except for de novo insertion, we need to check if the ref is at the center
    
    # I don't think this is the only check we need
    if(nchar(alt) == 2 & substring(sequence, mid.base, mid.base) != ref){ #means we are looking at an insertion
      stop("REF not at the center")
    }
    if(nchar(alt) == 1 & substring(sequence, mid.base, mid.base + 1) != ref){ #means we are looking at a deletion
      stop("REF not at the center")
    }
    
    homopolymer.starts <- mid.base + 1
    
    homopolymer.ends <- mid.base + homopolymer.length
    
    if (ins.or.del == "DEL"){
      # For deletions, the deleted base will be at position 0
      var.length <- homopolymer.length - 1
    } else {
      var.length <- homopolymer.length
    }
    
    ## normalize the insertion context to the middle
    
    if(substring(sequence, homopolymer.starts, homopolymer.starts)!= indel.base){
      seq.context <- substring(sequence,
                               homopolymer.starts - flank.length ,
                               homopolymer.ends + flank.length + var.length)
      seq.context <- revc(seq.context)
      
    } else {
      seq.context <- substring(sequence,
                               homopolymer.starts - flank.length - var.length,
                               homopolymer.ends + flank.length)
    }
    
    homopolymer.seq <- paste(rep(indel.base, homopolymer.length), collapse = "")
    
    re <- paste0("[ACGT]{", flank.length - 1 + var.length, "}[^", indel.base, "]",
                 homopolymer.seq,
                 "[^", indel.base, "][ACGT]{", flank.length - 1, "}")
    if (!grepl(re, seq.context, perl = TRUE)) {
      stop("Extracted sequence ", seq.context, " does not have the expected form ",
           "(does not match the regular expression '", re, "')\n",
           "Possibly the variant caller is not standardizing the position of the indel in the homopolymer")
    }
    
  }
  return(seq.context)
  
}

#' Generate PFMmatrix (Position Frequency Matrix) from a given list of sequences
#'
#' @param sequences A list of strings returned from
#'   \code{\link{SymmetricalContextsFor1BPIndel}}.
#'
#' @param indel.class A single character string that denotes a 1 base pair
#'   insertion or deletion, as taken from \code{ICAMS::catalog.row.order$ID}.
#'   Insertions or deletions into or from 5+ base-pair homopolymers are not
#'   supported.
#'
#' @param flank.length The length of flanking bases around the position or
#'   homopolymer targeted by the indel.
#'
#' @param plot.dir If provided, make a dot-line plot for PFMmatrix.
#'
#' @param plot.title The title of the dot-line plot
#'
#' @return A matrix recording the frequency of each base (A, C, G, T) on each
#'   position of the sequence.
#'
#' @keywords internal
#'
GeneratePlotPFMmatrix <-
  function(sequences, indel.class, flank.length = 5, plot.dir = NULL,
           plot.title = NULL){
    
    if(length(unique(nchar(sequences))) > 1){
      stop("All sequences must have the same length")
    }
    
    indel.base <- unlist(strsplit(indel.class, ":"))[2]
    
    indel.context <- as.numeric(unlist(strsplit(indel.class, ":"))[4])
    
    ins.or.del <- unlist(strsplit(indel.class, ":"))[1]
    
    positions <- c(paste0("-", ((flank.length + indel.context):1)),
                   paste0("+", 1:(flank.length + indel.context)))
    
    # When it is deletion, the deleted base will have position 0
    if(ins.or.del == "DEL"){
      positions <- c(paste0("-", ((flank.length + indel.context):1)),
                     0,
                     paste0("+", 1:(flank.length + indel.context)))
    }
    
    classes <- c("A","C","G","T")
    
    PFMmatrix <- matrix(data = NA, nrow = length(positions), ncol = length(classes),
                        dimnames = list(positions, classes))
    
    for (row in 1:nrow(PFMmatrix)) {
      tmp <- substr(sequences, row, row)
      PFMmatrix[row, "A"] <- sum(tmp == "A")
      PFMmatrix[row, "C"] <- sum(tmp == "C")
      PFMmatrix[row, "G"] <- sum(tmp == "G")
      PFMmatrix[row, "T"] <- sum(tmp == "T")
    }
    
    if(!is.null(plot.dir)){
      
      if (is.null(plot.title)) {
        plot.title <- "Dot-line plot for PFMmatrix"
      }
      
      grDevices::pdf(plot.dir)
      dot.line.plot <- PlotPFMmatrix(PFMmatrix = PFMmatrix,
                                     title = plot.title)
      grDevices::dev.off()
    }
    return(PFMmatrix)
  }

#' Generate dot-line plot for sequence contest of 1bp indel
#'
#' @param PFMmatrix An object return from \code{\link{GeneratePlotPFMmatrix}}.
#'
#' @param title A string provides the title of the plot
#'
#' @param cex.main Passed to R plot function. Title size
#'
#' @param cex.lab Passed to R plot function. Axis label size
#'
#' @param cex.axis Passed to R plot function. Axis text size
#'
#' @return An \strong{invisible} list.
#'
#' @keywords internal
PlotPFMmatrix <- function(PFMmatrix, title,
                        cex.main = 1.5,
                        cex.lab = 1.25,
                        cex.axis = 1){
  
  number.of.rows <- nrow(PFMmatrix)
  
  # set x-axis positions for the plot
  x <- c((1 - number.of.rows/2):(number.of.rows/2))
  
  if ((number.of.rows%%2) != 0) {
    x <- c(-((number.of.rows - 1)/2):((number.of.rows - 1)/2))
    
  }
  
  plot(x, PFMmatrix[, "A"]/sum(PFMmatrix[1, ]), main = title, xlab = "position",
       ylab = "Proportion of bases", xaxt = "n", col = "darkgreen", ylim = c(0, 1),
       type = "b", pch = 20, lwd = 2, cex.main = cex.main, cex.lab = cex.lab,
       cex.axis = cex.axis)
  
  axis(1, at = x, labels = rownames(PFMmatrix), tick = F, outer = F, las = 1,
       font = 1, par(cex.axis = 0.7))
  
  lines(x, PFMmatrix[, "C"]/sum(PFMmatrix[1, ]), col = "blue", type = "b",
        pch = 20, lwd = 2)
  lines(x, PFMmatrix[, "G"]/sum(PFMmatrix[1, ]), col = "black", type = "b",
        pch = 20, lwd = 2)
  lines(x, PFMmatrix[, "T"]/sum(PFMmatrix[1, ]), col = "red", type = "b",
        pch = 20, lwd = 2)
  abline(h = 0.25, col = "grey50")
  
  legend("topright", pch = 16, cex = 1, ncol = 4, bty = "n",
         legend = c("A", "C", "G", "T"), col = c("darkgreen", "blue", "black", "red"))
}

#' Generate Haplotype plot from a given list of sequences
#'
#' @param sequences A list of strings returned from
#'   \code{\link{SymmetricalContextsFor1BPIndel}}.
#'
#' @param indel.class A single character string that denotes a 1 base pair
#'   insertion or deletion, as taken from \code{ICAMS::catalog.row.order$ID}.
#'   Insertions or deletions into or from 5+ base-pair homopolymers are not
#'   supported.
#'
#' @param flank.length The length of flanking bases around the position or
#'   homopolymer targeted by the indel.
#'
#' @param title The title of the haplotype plot
#'
#' @return A ggplot2 object
#' 
#' @keywords internal
#' 
HaplotypePlot <- function(sequences,
                          indel.class, flank.length = 5,
                          title="Haplotype Plot"){
  if ("" == system.file(package = "ggplot2")) {
    stop("\nPlease install ggplot2: install.packages(\"ggplot2\")")
  }
  
  if ("" == system.file(package = "reshape2")) {
    stop("\nPlease install reshape2: install.packages(\"reshape2\")")
  }
  
  if(length(unique(nchar(sequences))) > 1){
    stop("All sequences must have the same length")
  }
  
  indel.base <- unlist(strsplit(indel.class, ":"))[2]
  
  indel.context <- as.numeric(unlist(strsplit(indel.class, ":"))[4])
  
  ins.or.del <- unlist(strsplit(indel.class, ":"))[1]
  
  positions <- c(paste0("-", ((flank.length + indel.context):1)),
                 paste0("+", 1:(flank.length + indel.context)))
  
  # When it is deletion, the deleted base will have position 0
  if(ins.or.del == "DEL"){
    positions <- c(paste0("-", ((flank.length + indel.context):1)),
                   0,
                   paste0("+", 1:(flank.length + indel.context)))
  }
  
  
  tmp<-as.data.frame((sequences))
  
  tmp <- lapply(sequences,function(x){
    return(c(x,unlist(strsplit(x,""))))
  })
  
  seq.tmp <- do.call(rbind,tmp)
  
  seq.tmp <- data.frame(seq.tmp)
  colnames(seq.tmp) <- c("seq",positions)
  
  melt.seq.tmp <- seq.tmp
  
  melt.seq.tmp[melt.seq.tmp=="T"] <- as.numeric(4)
  melt.seq.tmp[melt.seq.tmp=="G"] <- as.numeric(3)
  melt.seq.tmp[melt.seq.tmp=="C"] <- as.numeric(2)
  melt.seq.tmp[melt.seq.tmp=="A"] <- as.numeric(1)
  
  for(i in 2:(ncol(melt.seq.tmp))){
    melt.seq.tmp[,i] <- as.numeric(melt.seq.tmp[,i])
    
  }
  dist.matrix <- stats::dist(data.matrix(melt.seq.tmp[,2:(ncol(melt.seq.tmp))]),
                             method = "euclidean")
  
  ordered.rank <- stats::hclust(dist.matrix)
  
  melt.seq.tmp <- melt.seq.tmp[ordered.rank$order,]
  
  melt.seq.tmp$order <- 1:nrow(melt.seq.tmp)
  
  melt.seq.tmp[,ncol(melt.seq.tmp)] <- as.character(melt.seq.tmp[,ncol(melt.seq.tmp)])
  
  melt.seq.tmp <- suppressMessages(reshape2::melt(melt.seq.tmp)) 
  group.colors <- c(A="springgreen4", `T`="firebrick1",C="dodgerblue3",G="black")
  melt.seq.tmp$value[melt.seq.tmp$value==1] <- "A"
  melt.seq.tmp$value[melt.seq.tmp$value==2] <- "C"
  melt.seq.tmp$value[melt.seq.tmp$value==3] <- "G"
  melt.seq.tmp$value[melt.seq.tmp$value==4] <- "T"
  
  plot <- ggplot2::ggplot(melt.seq.tmp, ggplot2::aes(x = variable, y = order, fill = value)) +
    ggplot2::geom_tile()+
    ggplot2::scale_fill_manual(values=group.colors) +
    ggplot2::scale_y_discrete(limits=factor(c(1:length(sequences))))+
    ggplot2::theme(axis.text.x=ggplot2::element_text(angle = 90,vjust =0.5,size=8),
                   axis.text.y=ggplot2::element_blank(),
                   axis.title.x = ggplot2::element_blank(),
                   axis.title.y = ggplot2::element_blank(),
                   axis.ticks=ggplot2::element_blank(),
                   legend.title = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   panel.background = ggplot2::element_blank())+
    ggplot2::ggtitle(title)
  
  return(plot)
}


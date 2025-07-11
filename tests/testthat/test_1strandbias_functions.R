context("Transcription strand bias functions")

test_that("PlotTransBiasGeneExpToPdf function", {
  skip_if("" == system.file(package = "BSgenome.Hsapiens.1000genomes.hs37d5"))
  stopifnot(requireNamespace("BSgenome.Hsapiens.1000genomes.hs37d5"))
  list.of.vcfs <- 
    expect_warning(
      ReadAndSplitStrelkaSBSVCFs("testdata/Strelka-SBS-GRCh37/Strelka.SBS.GRCh37.s1.vcf"))

  annotated.SBS.vcf <- 
    AnnotateSBSVCF(list.of.vcfs$SBS.vcfs[[1]], "hg19", trans.ranges.GRCh37)
  vcf1 <- annotated.SBS.vcf[REF == "C",]
  vcf2 <- annotated.SBS.vcf[REF %in% c("C", "G"), ]
  vcf3 <- annotated.SBS.vcf[REF == "T",]
  vcf4 <- annotated.SBS.vcf[REF %in% c("A", "T"), ]
  out <- 
    PlotTransBiasGeneExpToPdf(annotated.SBS.vcf = annotated.SBS.vcf,
                              file = file.path(tempdir(), "test.pdf"),
                              expression.data = gene.expression.data.HepG2, 
                              Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                              expression.value.col = "TPM",
                              num.of.bins = 4
    )
  out1 <- 
    PlotTransBiasGeneExpToPdf(annotated.SBS.vcf = vcf1,
                              file = file.path(tempdir(), "test1.pdf"),
                              expression.data = gene.expression.data.HepG2, 
                              Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                              expression.value.col = "TPM",
                              num.of.bins = 4
    )
  out2 <- 
    PlotTransBiasGeneExpToPdf(annotated.SBS.vcf = vcf2,
                              file = file.path(tempdir(), "test2.pdf"),
                              expression.data = gene.expression.data.HepG2, 
                              Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                              expression.value.col = "TPM",
                              num.of.bins = 4
    )
  out3 <- 
    PlotTransBiasGeneExpToPdf(annotated.SBS.vcf = vcf3,
                              file = file.path(tempdir(), "test3.pdf"),
                              expression.data = gene.expression.data.HepG2, 
                              Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                              expression.value.col = "TPM",
                              num.of.bins = 4
    )
  out4 <- 
    PlotTransBiasGeneExpToPdf(annotated.SBS.vcf = vcf4,
                              file = file.path(tempdir(), "test4.pdf"),
                              expression.data = gene.expression.data.HepG2, 
                              Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                              expression.value.col = "TPM",
                              num.of.bins = 4
    )
  
  
  expect_equal(out$plot.success, TRUE)
  expect_equal(out1$plot.success, TRUE)
  expect_equal(out2$plot.success, TRUE)
  expect_equal(out3$plot.success, TRUE)
  expect_equal(out4$plot.success, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "test.pdf"))
  unlink(file.path(tempdir(), "test1.pdf"))
  unlink(file.path(tempdir(), "test2.pdf"))
  unlink(file.path(tempdir(), "test3.pdf"))
  unlink(file.path(tempdir(), "test4.pdf"))
})


test_that("PlotTransBiasGeneExp function", {
  skip_if("" == system.file(package = "BSgenome.Hsapiens.1000genomes.hs37d5"))
  stopifnot(requireNamespace("BSgenome.Hsapiens.1000genomes.hs37d5"))
  
  list.of.vcfs <- 
    ReadAndSplitStrelkaSBSVCFs("testdata/Strelka-SBS-GRCh37/Strelka.SBS.GRCh37.s1.vcf")

  annotated.SBS.vcf <- 
    AnnotateSBSVCF(list.of.vcfs$SBS.vcfs[[1]], "hg19", trans.ranges.GRCh37)
  vcf1 <- annotated.SBS.vcf[REF == "C",]
  vcf2 <- annotated.SBS.vcf[REF %in% c("C", "G"), ]
  vcf3 <- annotated.SBS.vcf[REF == "T",]
  vcf4 <- annotated.SBS.vcf[REF %in% c("A", "T"), ]
  
  out <- 
    PlotTransBiasGeneExp(annotated.SBS.vcf = annotated.SBS.vcf, 
                         expression.data = gene.expression.data.HepG2, 
                         Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                         expression.value.col = "TPM",
                         num.of.bins = 4, plot.type = "C>A")
  
  out1 <- 
    PlotTransBiasGeneExp(annotated.SBS.vcf = vcf1, 
                         expression.data = gene.expression.data.HepG2, 
                         Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                         expression.value.col = "TPM",
                         num.of.bins = 4, plot.type = "C>A")
  
  out2 <- 
    PlotTransBiasGeneExp(annotated.SBS.vcf = vcf2, 
                         expression.data = gene.expression.data.HepG2, 
                         Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                         expression.value.col = "TPM",
                         num.of.bins = 4, plot.type = "C>A")
  out3 <- 
    PlotTransBiasGeneExp(annotated.SBS.vcf = vcf3, 
                         expression.data = gene.expression.data.HepG2, 
                         Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                         expression.value.col = "TPM",
                         num.of.bins = 4, plot.type = "C>A")
  out4 <- 
    PlotTransBiasGeneExp(annotated.SBS.vcf = vcf4, 
                         expression.data = gene.expression.data.HepG2, 
                         Ensembl.gene.ID.col = "Ensembl.gene.ID", 
                         expression.value.col = "TPM",
                         num.of.bins = 4, plot.type = "C>A")
  expect_equal(out$plot.success, TRUE)
  expect_equal(out1$plot.success, TRUE)
  expect_equal(out2$plot.success, TRUE)
  expect_equal(out3$plot.success, TRUE)
  expect_equal(out4$plot.success, TRUE)
  graphics.off()
})

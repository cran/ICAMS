context("extended seq.context functions")

test_that("extended seq.context functions for Mutect GRCh38 vcf", {
  skip_if("" == system.file(package = "BSgenome.Hsapiens.UCSC.hg38"))
  stopifnot(requireNamespace("BSgenome.Hsapiens.UCSC.hg38"))
  vcf <- 
    ReadAndSplitMutectVCFs("testdata/Mutect.GRCh38.vcf")
  sbs.vcf <- vcf$SBS[[1]]
  mat <- CreateOnePPMFromSBSVCF(sbs.vcf, ref.genome = "GRCh38",
                                seq.context.width = 10)
  out <- PlotPPM(mat, title = "ExtendedSeqContext_21bases")
  out1 <- 
    PlotPPMToPdf(list(mat), titles = "ExtendedSeqContext_21bases",
                 file = file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
  expect_equal(out, TRUE)
  expect_equal(out1, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
})

test_that("extended seq.context functions for Mutect GRCh37 vcf", {
  skip_if("" == system.file(package = "BSgenome.Hsapiens.1000genomes.hs37d5"))
  stopifnot(requireNamespace("BSgenome.Hsapiens.1000genomes.hs37d5"))
  vcf <- 
    ReadAndSplitMutectVCFs("testdata/Mutect-GRCh37/Mutect.GRCh37.s1.vcf")
  sbs.vcf <- vcf$SBS[[1]]
  mat <- CreateOnePPMFromSBSVCF(sbs.vcf, ref.genome = "GRCh37",
                                seq.context.width = 10)
  out <- PlotPPM(mat, title = "ExtendedSeqContext_21bases")
  out1 <- 
    PlotPPMToPdf(list(mat), titles = "ExtendedSeqContext_21bases",
                 file = file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
  expect_equal(out, TRUE)
  expect_equal(out1, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
})

test_that("extended seq.context functions for Mutect GRCm38 vcf", {
  skip_if("" == system.file(package = "BSgenome.Mmusculus.UCSC.mm10"))
  stopifnot(requireNamespace("BSgenome.Mmusculus.UCSC.mm10"))
  vcf <- expect_warning(
    ReadAndSplitMutectVCFs("testdata/Mutect.GRCm38.vcf")
  )
    
  sbs.vcf <- vcf$SBS[[1]]
  mat <- CreateOnePPMFromSBSVCF(sbs.vcf, ref.genome = "GRCm38",
                                seq.context.width = 10)
  out <- PlotPPM(mat, title = "ExtendedSeqContext_21bases")
  out1 <- 
    PlotPPMToPdf(list(mat), titles = "ExtendedSeqContext_21bases",
                 file = file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
  expect_equal(out, TRUE)
  expect_equal(out1, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
})

test_that("extended seq.context functions for Strelka GRCh38 vcf", {
  skip_if("" == system.file(package = "BSgenome.Hsapiens.UCSC.hg38"))
  stopifnot(requireNamespace("BSgenome.Hsapiens.UCSC.hg38"))
  vcfs <- 
    ReadAndSplitStrelkaSBSVCFs("testdata/Strelka.SBS.GRCh38.vcf")
  sbs.vcf <- vcfs$SBS.vcfs[[1]]
  mat <- CreateOnePPMFromSBSVCF(sbs.vcf, ref.genome = "GRCh38",
                                seq.context.width = 10)
  out <- PlotPPM(mat, title = "ExtendedSeqContext_21bases")
  out1 <- 
    PlotPPMToPdf(list(mat), titles = "ExtendedSeqContext_21bases",
                 file = file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
  expect_equal(out, TRUE)
  expect_equal(out1, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
})

test_that("extended seq.context functions for Strelka GRCh37 vcf", {
  skip_if("" == system.file(package = "BSgenome.Hsapiens.1000genomes.hs37d5"))
  stopifnot(requireNamespace("BSgenome.Hsapiens.1000genomes.hs37d5"))
  vcfs <- ReadAndSplitStrelkaSBSVCFs("testdata/Strelka-SBS-GRCh37/Strelka.SBS.GRCh37.s1.vcf")
  sbs.vcf <- vcfs$SBS.vcfs[[1]]
  mat <- CreateOnePPMFromSBSVCF(sbs.vcf, ref.genome = "GRCh37",
                                seq.context.width = 10)
  out <- PlotPPM(mat, title = "ExtendedSeqContext_21bases")
  out1 <- 
    PlotPPMToPdf(list(mat), titles = "ExtendedSeqContext_21bases",
                 file = file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
  expect_equal(out, TRUE)
  expect_equal(out1, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
})

test_that("extended seq.context functions for Strelka GRCm38 vcf", {
  skip_if("" == system.file(package = "BSgenome.Mmusculus.UCSC.mm10"))
  stopifnot(requireNamespace("BSgenome.Mmusculus.UCSC.mm10"))
  vcfs <- ReadAndSplitStrelkaSBSVCFs("testdata/Strelka.SBS.GRCm38.vcf")
  sbs.vcf <- vcfs$SBS.vcfs[[1]]
  mat <- CreateOnePPMFromSBSVCF(sbs.vcf, ref.genome = "GRCm38",
                                seq.context.width = 10)
  out <- PlotPPM(mat, title = "ExtendedSeqContext_21bases")
  out1 <- 
    PlotPPMToPdf(list(mat), titles = "ExtendedSeqContext_21bases",
                 file = file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
  expect_equal(out, TRUE)
  expect_equal(out1, TRUE)
  graphics.off()
  unlink(file.path(tempdir(), "Extended.seq.context.21bases.pdf"))
})

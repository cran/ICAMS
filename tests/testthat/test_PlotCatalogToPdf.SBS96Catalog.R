context("PlotCatalogToPdf.SBS96Catalog")

test_that("PlotCatalogToPdf.SBS96Catalog function", {
  catalog.counts <- ReadCatalog("testdata/regress.cat.sbs.96.csv",
                                ref.genome = "GRCh37",
                                region = "genome", catalog.type = "counts")
  colnames(catalog.counts) <- paste0("HepG2_", 1 : 4)
  out <-
    PlotCatalogToPdf(catalog.counts, 
                     file = file.path(tempdir(), "PlotCatSBS96.counts.test.pdf"))
  expect_equal(out, TRUE)

  catalog.density <-
    TransformCatalog(catalog.counts, target.ref.genome = "GRCh37",
                     target.region = "genome",
                     target.catalog.type = "density")
  out <-
    PlotCatalogToPdf(catalog.density, file = file.path(tempdir(), "PlotCatSBS96.density.test.pdf"))
  expect_equal(out, TRUE)

  catalog.counts.signature <-
    TransformCatalog(catalog.counts, target.ref.genome = "GRCh37",
                     target.region = "genome",
                     target.catalog.type = "counts.signature")
  out <-
    PlotCatalogToPdf(catalog.counts.signature,
                     file = file.path(tempdir(), "PlotCatSBS96.counts.signature.test.pdf"))
  expect_equal(out, TRUE)

  catalog.density.signature <-
    TransformCatalog(catalog.counts, target.ref.genome = "GRCh37",
                     target.region = "genome",
                     target.catalog.type = "density.signature")
  out <-
    PlotCatalogToPdf(catalog.density.signature,
                     file = file.path(tempdir(), "PlotCatSBS96.density.signature.test.pdf"))
  expect_equal(out, TRUE)

  unlink(file.path(tempdir(), "PlotCatSBS96.counts.test.pdf"))
  unlink(file.path(tempdir(), "PlotCatSBS96.density.test.pdf"))
  unlink(file.path(tempdir(), "PlotCatSBS96.counts.signature.test.pdf"))
  unlink(file.path(tempdir(), "PlotCatSBS96.density.signature.test.pdf"))
  graphics.off()
})
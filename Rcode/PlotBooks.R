# code to produce a "book" of plot images. The book is placed in the base data folder
#
source("Rcode/FileSystem.R")

library(terra)
library(fusionwrapr)

checkForFiles <- TRUE
doHillshade <- FALSE

for (thePlot in 1:length(imagePlotFolders)) {
    bookFileName <- paste0(dataFolder, "/", imageFileBaseNames[thePlot], "_Images.pdf")
  
  # check to see if we already have the images...needed since a single images covers multiple plots
  if (checkForFiles) {
    if (file.exists(bookFileName))
      next
  }
  
  # read composite images and grayscale
  baseName <- paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_")

  imageFile <- paste0(baseName, bandNames[6], "_reflectance.tif")
  panchro <- rast(imageFile)
  panchro <- stretch16(panchro)
  
  rgb <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_RGB.tif"))
  fcnir <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.tif"))
  fcrededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_rededge.tif"))
  nvdirededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdirededge.tif"))
  nvdinir <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdinir.tif"))
  msr <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msr.tif"))
  msrrededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msrrededge.tif"))
  cigreen <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_cigreen.tif"))
  cirededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_cirededge.tif"))
  nvdiredrededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdiredrededge.tif"))
  msrredrededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msrredrededge.tif"))
  ciredrededge <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_ciredrededge.tif"))
  nir_re_g <- rast(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nir_re_g.tif"))
  
  # get image extent to clip DTM since DTM covers more than 1 plot
  e <- ext(panchro)
  
  if (doHillshade) {
    DTMFileName <- paste0(dataFolder, "/", plotFolders[thePlot], "/ground.dtm")
    DTM <- readDTM(DTMFileName, type = "terra", epsg = 26910)
    DTM <- crop(DTM, e)
    
    # do hillshade using multiple angles
    alt <- disagg(DTM, 10, method="bilinear")
    slope <- terrain(alt, "slope", unit="radians")
    aspect <- terrain(alt, "aspect", unit="radians")
    h <- shade(slope, aspect, angle = c(45, 45, 45, 80), direction = c(315, 0, 45, 135))
    h <- Reduce(mean, h)
  }
  
  margins <- c(2, 4, 2, 6)
  
  # if dimensions of the area are wider than they are tall, legend is clipped off
  pdf(bookFileName)
  if (doHillshade) plot(h, col=grey(0:100/100), legend=FALSE, mar=c(2,2,2,4), main = "Hillshade")
  
#  l <- global(panchro, quantile, na.rm = TRUE, probs = c(0.01))
#  h <- global(panchro, quantile, na.rm = TRUE, probs = c(0.99))
#  plot(panchro, range = c(l[[1]], h[[1]]), col = grDevices::gray.colors(255), legend = FALSE, axes = FALSE, mar = c(0, 0, 2, 0), main = "panchromatic")
  plot(panchro, col = grDevices::gray.colors(255), legend = FALSE, axes = TRUE, mar = margins, main = "panchromatic")
  
  plotRGB(rgb, mar = margins, axes = TRUE, main = "RGB")
  plotRGB(fcnir, mar = margins, axes = TRUE, main = "False color NIR")
  plotRGB(fcrededge, mar = margins, axes = TRUE, main = "False color rededge")
  
  l <- global(nvdinir, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(nvdinir, quantile, na.rm = TRUE, probs = c(0.99))
  plot(nvdinir, range = c(l[[1]], h[[1]]), mar = margins, main = "NIR NVDI")
  
  l <- global(nvdirededge, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(nvdirededge, quantile, na.rm = TRUE, probs = c(0.99))
  plot(nvdirededge, range = c(l[[1]], h[[1]]), mar = margins, main = "rededge NVDI")
  
  l <- global(msr, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(msr, quantile, na.rm = TRUE, probs = c(0.99))
  plot(msr, range = c(l[[1]], h[[1]]), mar = margins, main = "MSR")
  
  l <- global(msrrededge, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(msrrededge, quantile, na.rm = TRUE, probs = c(0.99))
  plot(msrrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "rededge MSR")
  
  l <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.99))
  plot(cigreen, range = c(l[[1]], h[[1]]), mar = margins, main = "green CI")
  
  l <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.99))
  plot(cirededge, range = c(l[[1]], h[[1]]), mar = margins, main = "rededge CI")
  
  l <- global(nvdiredrededge, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(nvdiredrededge, quantile, na.rm = TRUE, probs = c(0.99))
  plot(nvdiredrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "red and rededge NVDI")
  
  l <- global(msrredrededge, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(msrredrededge, quantile, na.rm = TRUE, probs = c(0.99))
  plot(msrredrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "red and rededge MSR")
  
  l <- global(ciredrededge, quantile, na.rm = TRUE, probs = c(0.01))
  h <- global(ciredrededge, quantile, na.rm = TRUE, probs = c(0.99))
  plot(ciredrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "red and rededge modified CI")

  plotRGB(nir_re_g, mar = margins, axes = TRUE, main = "False color NIR-rededge-green")
  dev.off()
}


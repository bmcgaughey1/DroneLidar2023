# code to produce a "book" of plot images. The book is placed in the base data folder
#
source("Rcode/FileSystem.R")

library(terra)
library(fusionwrapr)

checkForFiles <- FALSE

for (thePlot in 1:length(imagePlotFolders)) {
  bookFileName <- paste0(dataFolder, "/", imageFileBaseNames[thePlot], "_Images.pdf")
  
  # check to see if we already have the images...needed since a single images covers multiple plots
  if (checkForFiles) {
    if (file.exists(bookFileName))
      next
  }
  
  # read composite images and grayscale
  baseName <- paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_", "transparent_reflectance_")
  
  imageFile <- paste0(baseName, bandNames[6], ".tif")
  panchro <- rast(imageFile)
  panchro <- stretch(panchro)
  
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
  
  # get image extent to clip DTM since DTM covers more than 1 plot
  e <- ext(panchro)
  
  DTMFileName <- paste0(dataFolder, "/", plotFolders[thePlot], "/ground.dtm")
  DTM <- readDTM(DTMFileName, type = "terra", epsg = 26910)
  DTM <- crop(DTM, e)
  
  # do hillshade using multiple angles
  alt <- disagg(DTM, 10, method="bilinear")
  slope <- terrain(alt, "slope", unit="radians")
  aspect <- terrain(alt, "aspect", unit="radians")
  h <- shade(slope, aspect, angle = c(45, 45, 45, 80), direction = c(315, 0, 45, 135))
  h <- Reduce(mean, h)
  
  pdf(bookFileName)
  plot(h, col=grey(0:100/100), legend=FALSE, mar=c(2,2,2,4), main = "Hillshade")
  plot(panchro, col = grDevices::gray.colors(255), legend = FALSE, axes = FALSE, mar = c(0, 0, 2, 0), main = "panchromatic")
  plotRGB(rgb, mar = c(0, 0, 2, 0), main = "RGB")
  plotRGB(fcnir, mar = c(0, 0, 2, 0), main = "False color NIR")
  plotRGB(fcrededge, mar = c(0, 0, 2, 0), main = "False color rededge")
  plot(nvdinir, mar = c(0, 0, 2, 0), main = "NIR NVDI")
  plot(nvdirededge, mar = c(0, 0, 2, 0), main = "rededge NVDI")
  plot(msr, mar = c(0, 0, 2, 0), main = "MSR")
  plot(msrrededge, mar = c(0, 0, 2, 0), main = "rededge MSR")
  plot(cigreen, mar = c(0, 0, 2, 0), main = "green CI")
  plot(cirededge, mar = c(0, 0, 2, 0), main = "rededge CI")
  plot(nvdiredrededge, mar = c(0, 0, 2, 0), main = "red and rededge NVDI")
  plot(msrredrededge, mar = c(0, 0, 2, 0), main = "red and rededge MSR")
  plot(ciredrededge, mar = c(0, 0, 2, 0), main = "red and rededge modified CI")
  dev.off()
}

?rgl::surface3d

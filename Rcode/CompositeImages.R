# code to create composite images for 2023 drone imagery
#
source("Rcode/FileSystem.R")

library(terra)

# you can use the following line to set a specific plot (by index into lists in FileSystem.R)
# then you can run individual lines to test things without using the loop to process all data
# thePlot <- 4

checkForFiles <- FALSE
alpha <- 0.4

for (thePlot in 1:length(imagePlotFolders)) {
  # check to see if we already have the images...needed since a single images covers multiple plots
  if (checkForFiles) {
    if (file.exists(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.tif")))
      break
  }
  
  baseName <- paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_", "transparent_reflectance_")
  
  imageFile <- paste0(baseName, bandNames[1], ".tif")
  red <- rast(imageFile)
  red <- stretch(red)
  
  imageFile <- paste0(baseName, bandNames[2], ".tif")
  green <- rast(imageFile)
  green <- stretch(green)
  
  imageFile <- paste0(baseName, bandNames[3], ".tif")
  blue <- rast(imageFile)
  blue <- stretch(blue)
  
  imageFile <- paste0(baseName, bandNames[4], ".tif")
  nir <- rast(imageFile)
  nir <- stretch(nir)
  
  imageFile <- paste0(baseName, bandNames[5], ".tif")
  rededge <- rast(imageFile)
  rededge <- stretch(rededge)
  
  imageFile <- paste0(baseName, bandNames[6], ".tif")
  panchro <- rast(imageFile)
  panchro <- stretch(panchro)

  #Xie, Qiaoyun & Dash, Jadu & Huang, Wenjiang & Peng, Dailiang & Qin, Qiming &
  #Mortimer, Hugh & Casa, Raffaele & Pignatti, Stefano & Laneve, Giovanni &
  #Pascucci, Simone & Dong, Yingying & Ye, Huichun. (2018). Vegetation Indices
  #Combining the Red and Red-Edge Spectral Information for Leaf Area Index
  #Retrieval. IEEE Journal of Selected Topics in Applied Earth Observations and
  #Remote Sensing. 11. 10.1109/JSTARS.2018.2813281.  
  rgb <- rast(list(red, green, blue))
  fcnir <- rast(list(nir, red, green))
  fcrededge <- rast(list(rededge, red, green))
  nvdinir <- (nir - red) / (nir + red)
  nvdirededge <- (nir - rededge) / (nir + rededge)
  msr <- ((nir / red) - 1) / sqrt((nir / red) + 1)
  msrrededge <- ((nir / rededge) - 1) / sqrt((nir / rededge) + 1)
  cigreen <- nir / green -1
  cirededge <- nir / rededge - 1
  nvdiredrededge <- (nir - (alpha * red + (1 - alpha) * rededge)) / (nir + (alpha * red + (1 - alpha) * rededge))
  msrredrededge <- (nir / (alpha * red + (1 - alpha) * rededge) - 1) / sqrt(nir / (alpha * red + (1 - alpha) * rededge) + 1)
  ciredrededge <- nir / (alpha * red + (1 - alpha) * rededge) - 1
  
  #nvdinir <- stretch(nvdinir)
  #nvdirededge <- stretch(nvdirededge)
  
  # # get center of extent...this can be used to plot a small portion of the images to check for detail
  # buf <- 10
  # e <- ext(red)
  # center <- c((e[1] + e[2]) / 2, (e[3] + e[4]) / 2)
  # newExtent <- ext(c(center[1] - buf, center[1] + buf, center[2] - buf, center[2] + buf))
  # 
  # plotRGB(crop(rgb, newExtent))
  # plotRGB(crop(fcnir, newExtent))
  # plotRGB(crop(fcrededge, newExtent))
  # 
  # plotRGB(fcnir)
  # 
  # plot(crop(panchro, newExtent), col = grDevices::gray.colors(255))
  
  # we need a world file to use these images with FUSION. This is done using the gdal options. You can use
  # WORLDFILE=YES but the file extension will be .wld which FUSION won't recognize. TFW-YES produces a world file
  # with .tfw extension which FUSION will recognize and use.
  #
  # write off composite images...convert to 8-bit integer data type to save space. Original image bands used 4-byte floating
  # point type but band DNs ranged form 0.0 - 1.0 so lots of wasted space.
  writeRaster(fcnir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.tif"), gdal = "TFW=YES", datatype = "INT1U", overwrite = TRUE)
  writeRaster(fcrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_rededge.tif"), gdal = "TFW=YES", datatype = "INT1U", overwrite = TRUE)
  writeRaster(rgb, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_RGB.tif"), gdal = "TFW=YES", datatype = "INT1U", overwrite = TRUE)
  writeRaster(nvdirededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdirededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(nvdinir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdinir.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(msr, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msr.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(msrrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msrrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(cigreen, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_cigreen.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(cirededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_cirededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(nvdiredrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdiredrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(msrredrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msrredrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  writeRaster(ciredrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_ciredrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
  
  #writeRaster(fcnir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.bmp"), gdal = "WORLDFILE=YES", datatype = "INT1U", overwrite = TRUE)
}

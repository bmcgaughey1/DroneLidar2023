# code to create composite images for 2023 drone imagery
#
source("FileSystem.R")

library(terra)

# you can use the following line to set a specific plot (by index into lists in FileSystem.R)
# then you can run individual lines to test things without using the loop to process all data
# thePlot <- 4

for (thePlot in 1:length(imagePlotFolders)) {
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
  
  rgb <- rast(list(red, green, blue))
  fcnir <- rast(list(nir, red, green))
  fcrededge <- rast(list(rededge, red, green))
  
  # # get center of extent
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
  
  #writeRaster(fcnir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.bmp"), gdal = "WORLDFILE=YES", datatype = "INT1U", overwrite = TRUE)
}

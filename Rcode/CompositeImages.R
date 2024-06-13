# code to create composite images for 2023 drone imagery
#
source("Rcode/FileSystem.R")

library(terra)

# new stretch function...just a wrapper around terra's stretch function that
# uses all cells and defaults to the 99.99 percentile instead of the maximum value
# to scale values from 0-255
stretchq <- function(
    x,
    maxq = 0.9999)
{
  invisible(terra::stretch(x, minq = 0.0, maxq = maxq, maxcell = dim(x)[1] * dim(x[2])))
}

# new stretch function to produce 16-bit values. I left this one so it uses the
# 99.9 percentile but scales from 0-65534 instead of 0-65535. ArcPro seemed to
# be treating values of 65535 as invalid.
stretch16 <- function (
    x,
    maxq = 0.999  # same as maximum value
)
{
  # check for maxq = 1.0...this is the maximum and it may be faster to compute
  # the maximum directly
  if (maxq == 1.0) {
    q <- terra::global(x, max, na.rm = TRUE)
  } else {
    # compute the quantile
    q <- terra::global(x, quantile, na.rm = TRUE, probs = c(maxq))
  }
  # q is a data frame so you have to add the subscripts to get the numeric value
  
  # truncate values to the target quantile value
  x <- terra::ifel(x > q[1,1], q[1,1], x)
  
  # do the linear stretch
  x <- x / q[1,1] * 65534
}

# alpha is used for some of the composite images defined in:
# Xie, Qiaoyun & Dash, Jadu & Huang, Wenjiang & Peng, Dailiang & Qin, Qiming &
# Mortimer, Hugh & Casa, Raffaele & Pignatti, Stefano & Laneve, Giovanni &
# Pascucci, Simone & Dong, Yingying & Ye, Huichun. (2018). Vegetation Indices
# Combining the Red and Red-Edge Spectral Information for Leaf Area Index
# Retrieval. IEEE Journal of Selected Topics in Applied Earth Observations and
# Remote Sensing. 11. 10.1109/JSTARS.2018.2813281.  
alpha <- 0.4

# you can use the following line to set a specific plot (by index into lists in FileSystem.R)
# then you can run individual lines to test things without using the loop to process all data
# thePlot <- 1

checkForFiles <- FALSE

# options for GDAL TIFF writer
gdalOptions <- c("TFW=YES", "PHOTOMETRIC=RGB")

# bitsPerPixel can be either 8 or 16. If 16, images won't read into FUSION
bitsPerPixel <- 8

dataType = "INT2U"
if (bitsPerPixel == 8)
  dataType = "INT1U"

thePlot <- 1
for (thePlot in 1:length(imagePlotFolders)) {
  # check to see if we already have the images...needed since a single images covers multiple plots
  if (checkForFiles) {
    if (file.exists(paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.tif")))
      next
  }
  
  baseName <- paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_")
  
  imageFile <- paste0(baseName, bandNames[1], "_reflectance.tif")
  red <- rast(imageFile)
  if (bitsPerPixel == 8)
    red <- stretchq(red)
  else
    red <- stretch16(red)
  
  imageFile <- paste0(baseName, bandNames[2], "_reflectance.tif")
  green <- rast(imageFile)
  if (bitsPerPixel == 8)
    green <- stretchq(green)
  else
    green <- stretch16(green)
  
  imageFile <- paste0(baseName, bandNames[3], "_reflectance.tif")
  blue <- rast(imageFile)
  if (bitsPerPixel == 8)
    blue <- stretchq(blue)
  else
    blue <- stretch16(blue)
  
  imageFile <- paste0(baseName, bandNames[4], "_reflectance.tif")
  nir <- rast(imageFile)
  if (bitsPerPixel == 8)
    nir <- stretchq(nir)
  else
    nir <- stretch16(nir)
  
  imageFile <- paste0(baseName, bandNames[5], "_reflectance.tif")
  rededge <- rast(imageFile)
  if (bitsPerPixel == 8)
    rededge <- stretchq(rededge)
  else
    rededge <- stretch16(rededge)
  
  imageFile <- paste0(baseName, bandNames[6], "_reflectance.tif")
  panchro <- rast(imageFile)
  if (bitsPerPixel == 8)
    panchro <- stretchq(panchro)
  else
    panchro <- stretch16(panchro)
  
  imageFile <- paste0(baseName, bandNames[7], "_reflectance.tif")
  lwir <- rast(imageFile)
  if (bitsPerPixel == 8)
    lwir <- stretchq(lwir)
  else
    lwir <- stretch16(lwir)
  
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
  
  # extra combinations
  nir_re_g <- rast(list(nir, rededge, green))

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
  
  # we need a world file to use these images with FUSION (not any more!!...GeoTIFF is recognized). This is done using the gdal options. You can use
  # WORLDFILE=YES but the file extension will be .wld which FUSION won't recognize. TFW=YES produces a world file
  # with .tfw extension which FUSION will recognize and use.
  #
  # write off composite images
  writeRaster(fcnir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
  writeRaster(fcrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_rededge.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
  writeRaster(rgb, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_RGB.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
  writeRaster(nvdirededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdirededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(nvdinir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdinir.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(msr, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msr.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(msrrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msrrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(cigreen, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_cigreen.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(cirededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_cirededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(nvdiredrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nvdiredrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(msrredrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_msrredrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  writeRaster(ciredrededge, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_ciredrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
  
  writeRaster(nir_re_g, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_nir_re_g.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
  
  #writeRaster(fcnir, paste0(dataFolder, "/", imagePlotFolders[thePlot], "/", imageFileBaseNames[thePlot], "_NIR.bmp"), gdal = "WORLDFILE=YES", datatype = "INT1U", overwrite = TRUE)
}

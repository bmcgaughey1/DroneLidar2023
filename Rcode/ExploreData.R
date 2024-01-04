# code to explore the 2023 drone lidar data and multi-spectral imagery data
# for cedar-specific plots
#
# I made some corrections to file names...see notes.txt in dataFolder. There
# are also some inconsistencies in the folder structure for plot_8_9_14 with
# separate folders for Plot_8_9 and Plot_14.
#
library(terra)

dataFolder <- "H:/westforkenv_cedar_plots_2023/Cedar_Plots"

plotNumbers <- c(8, 9, 10, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27)

imagePlotFolders <- c(
    "OESF_Cedar_Plot_8_9_14/Reflectance/OESF_Cedar_Plot_8_9"
  , "OESF_Cedar_Plot_8_9_14/Reflectance/OESF_Cedar_Plot_8_9"
  , "OESF_Cedar_Plot_10/Reflectance"
  , "OESF_Cedar_Plot_8_9_14/Reflectance/OESF_Cedar_Plot_14"
  , "ONF_Cedar_Plot_15_16/Reflectance"
  , "ONF_Cedar_Plot_15_16/Reflectance"
  , "ONF_Cedar_Plot_17_thru_22/Reflectance"
  , "ONF_Cedar_Plot_17_thru_22/Reflectance"
  , "ONF_Cedar_Plot_17_thru_22/Reflectance"
  , "ONF_Cedar_Plot_17_thru_22/Reflectance"
  , "ONF_Cedar_Plot_17_thru_22/Reflectance"
  , "ONF_Cedar_Plot_17_thru_22/Reflectance"
  , "ONF_Cedar_Plot_23_24_25/Reflectance"
  , "ONF_Cedar_Plot_23_24_25/Reflectance"
  , "ONF_Cedar_Plot_23_24_25/Reflectance"
  , "ONF_Cedar_Plot_26_27/Reflectance"
  , "ONF_Cedar_Plot_26_27/Reflectance"
)

imageFileBaseNames <- c(
  "OESF_Cedar_Plot_8_9"
  , "OESF_Cedar_Plot_8_9"
  , "OESF_Cedar_Plot_10"
  , "OESF_Cedar_Plot_14"
  , "ONF_Cedar_Plot_15"
  , "ONF_Cedar_Plot_15"
  , "ONF_Cedar_Plot_17_thru_22"
  , "ONF_Cedar_Plot_17_thru_22"
  , "ONF_Cedar_Plot_17_thru_22"
  , "ONF_Cedar_Plot_17_thru_22"
  , "ONF_Cedar_Plot_17_thru_22"
  , "ONF_Cedar_Plot_17_thru_22"
  , "ONF_Cedar_Plot_23_24_25"
  , "ONF_Cedar_Plot_23_24_25"
  , "ONF_Cedar_Plot_23_24_25"
  , "ONF_Cedar_Plot_26_27"
  , "ONF_Cedar_Plot_26_27"
)

bandNames <- c(
  "red"
  , "green"
  , "blue"
  , "nir"
  , "red edge"
  , "panchro"
)

#thePlot <- 4
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



# convert DTMs
library(fusionwrapr)

# list of files was created at DOS command line and copied into code
DTMFiles <- c(
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/OESF_Cedar_Plot_10/OESF_Cedar_Plot_10_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/OESF_Cedar_Plot_8_9_14/OESF_Cedar_Plot_8_9_14_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_15_16/ONF_Cedar_Plot_15_16_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_17_thru_22/ONF_Cedar_Plot_17_thru_22_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_23_24_25/ONF_Cedar_Plot_23_24_25_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_26_27/ONF_Cedar_Plot_26_27_DTM.tif"
)

for (i in 1:6) {
  d <- rast(DTMFiles[i])
  outFile <- paste0(dirname(DTMFiles[i]), "/ground.dtm")

  writeDTM(d, outFile, xyunits = "m", zunits = "m", coordsys = 2, zone = 10, horizdatum = 2, vertdatum = 2)
}

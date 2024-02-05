# code to test new images processed using metashape
#
# https://support.micasense.com/hc/article_attachments/4421956437143/Altum-PT_Integration_Guide-Feb2022.pdf
#
# for the altumPT sensor, the panchromatic and multispectral channels output
# 12-bit values (0-4095). The thermal band outputs 16-bit values (0-65535).
#
# For terra's stretch function, the default is to stretch values to a range of
# 0-255. You can decrease the upper value but can't increase it above 255.
#
# When using the stretch function, the actual range of values is reduced. The 
# equation for a single pixel is: 
#   stretched_value = value / max_value * 255
#
# The advantage to reducing the range of values to 0-255 is that composite
# images built using various bands will display correctly in GIS. However,
# there is some loss of precision when the range is reduced. A better option
# might be to increase the range to 16 bits (0-65535) but this requires a
# custom stretch function. These images will be larger but will still display
# correctly in GIS. the stretch16() function does the stretch to 16-bit values.
#
# I tested image viewing in ArcPro and composite images with and without stretching
# display "correctly". However, ArcPro automatically uses percent clip to adjust the 
# range of values in the images for display. If you set the "stretch type" to 
# "none", the composite made with the original band images is dark. The new,
# stretched image with full 16-bit range displays OK (still dark and low contrast
# but useable).
#
# I also noticed in ArcPro that pixels with values equal to the max possible value
# seem to be treated in a special way. It might be that they are being treated as
# no data. I "fixed" this by stretching to the max 16-bit integer value minus 1
# (65534).
#
# for the stretch functions, I originally had the upper percentile value set to
# 99.9 but I was clipping off some valid data in the NIR and rededge bands. I changed
# this to the 100th percentile (max data value) and it works better.
#
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

#folder <- "H:/westforkenv_onf_cedar_plot_17_thru_22-tif_2024-01-17_1649/"
#baseName <- "ONF_Cedar_Plot_17_thru_22"

folder <- "H:/westforkenv_oesf_cedar_plot_10_lwir_reflectance-tif_2024-01-18_1939/"
baseName <- "OESF_Cedar_Plot_10"

# alpha is used for some of the composite images defined in:
# Xie, Qiaoyun & Dash, Jadu & Huang, Wenjiang & Peng, Dailiang & Qin, Qiming &
# Mortimer, Hugh & Casa, Raffaele & Pignatti, Stefano & Laneve, Giovanni &
# Pascucci, Simone & Dong, Yingying & Ye, Huichun. (2018). Vegetation Indices
# Combining the Red and Red-Edge Spectral Information for Leaf Area Index
# Retrieval. IEEE Journal of Selected Topics in Applied Earth Observations and
# Remote Sensing. 11. 10.1109/JSTARS.2018.2813281.  
alpha <- 0.4

# read the single band images
red <- rast(paste0(folder, baseName, "_red_reflectance.tif"))
green <- rast(paste0(folder, baseName, "_green_reflectance.tif"))
blue <- rast(paste0(folder, baseName, "_blue_reflectance.tif"))
nir <- rast(paste0(folder, baseName, "_NIR_reflectance.tif"))
lwir <- rast(paste0(folder, baseName, "_LWIR_reflectance.tif"))
rededge <- rast(paste0(folder, baseName, "_rededge_reflectance.tif"))
pan <- rast(paste0(folder, baseName, "_panchro_reflectance.tif"))

# code to explore the values in the single band images. I tend to run this line-
# by-line for testing
#
# turn this code on/off by using TRUE/FALSE
if (FALSE) {
  # Look at range of values...size and maxcell are needed so we look at all pixel values
  # otherwise the functions use a very small sample of the pixel values and may miss
  # extreme values
  size = dim(red)[1] * dim(red)[2]
  summary(nir, size = size)
  hist(green, breaks = 50, maxcell = size)
  t <- global(red, quantile, na.rm = TRUE, probs = c(0.9999))
  
  # stretch values...two options: stretchq produces 0-255, stretch19 produces 0-65535
  reds <- stretchq(red)
  reds <- stretch16(red)
  summary(reds, size = size)
  
  # histogram of new stretched values
  hist(reds, breaks = 50, maxcell = size)

  # plot shows good contrast and correct no data areas
  plot(reds, col = grDevices::gray.colors(255))
}

# the range of values in the individual bands is a little wonky.
# Chris delivered normalized bands and non-normalized bands. The normalized bands
# have values ranging from 0-1.0. It looks like these values are a simple rescaling
# of the values in the non-normalized bands. Stretching the values scales them
# from 0-65535.
red <- stretch16(red)
green <- stretch16(green)
blue <- stretch16(blue)
nir <- stretch16(nir)
lwir <- stretch16(lwir)
rededge <- stretch16(rededge)
pan <- stretch16(pan)

# build composite images...see reference at the top of this code
rgb <- rast(list(red, green, blue))
fcnir <- rast(list(nir, red, green))
fcrededge <- rast(list(rededge, red, green))
nvdinir <- (nir - red) / (nir + red)
nvdirededge <- (nir - rededge) / (nir + rededge)
msr <- ((nir / red) - 1) / sqrt((nir / red) + 1)
msrrededge <- ((nir / rededge) - 1) / sqrt((nir / rededge) + 1)
cigreen <- nir / green - 1
cirededge <- nir / rededge - 1
nvdiredrededge <- (nir - (alpha * red + (1 - alpha) * rededge)) / (nir + (alpha * red + (1 - alpha) * rededge))
msrredrededge <- (nir / (alpha * red + (1 - alpha) * rededge) - 1) / sqrt(nir / (alpha * red + (1 - alpha) * rededge) + 1)
ciredrededge <- nir / (alpha * red + (1 - alpha) * rededge) - 1

# extra combinations
nir_re_g <- rast(list(nir, rededge, green))

# write off images...should probably add the baseName to keep the names associated with the units
writeRaster(rgb, paste0(folder, "/", "Metashape_composite_RGB.tif"), gdal = "TFW=YES", datatype = "INT2U", overwrite = TRUE)
writeRaster(fcnir, paste0(folder, "/", "Metashape_composite_fcnir.tif"), gdal = "TFW=YES", datatype = "INT2U", overwrite = TRUE)
writeRaster(fcrededge, paste0(folder, "/", "Metashape_composite_fcrededge.tif"), gdal = "TFW=YES", datatype = "INT2U", overwrite = TRUE)
writeRaster(nvdinir, paste0(folder, "/", "Metashape_composite_nvdinir.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(nvdirededge, paste0(folder, "/", "Metashape_composite_nvdirededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(msr, paste0(folder, "/", "Metashape_composite_msr.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(msrrededge, paste0(folder, "/", "Metashape_composite_msrrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(cigreen, paste0(folder, "/", "Metashape_composite_cigreen.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(cirededge, paste0(folder, "/", "Metashape_composite_cirededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(nvdiredrededge, paste0(folder, "/", "Metashape_composite_nvdiredrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(msrredrededge, paste0(folder, "/", "Metashape_composite_msrredrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)
writeRaster(ciredrededge, paste0(folder, "/", "Metashape_composite_ciredrededge.tif"), gdal = "TFW=YES", datatype = "FLT4S", overwrite = TRUE)

writeRaster(nir_re_g, paste0(folder, "/", "Metashape_composite_nir_re_g.tif"), gdal = "TFW=YES", datatype = "INT2U", overwrite = TRUE)

# ******************************************************************************
# ******************************************************************************
# this code looks at the multiband image. For the most part, the individual bands in 
# the multiband image are the same as the single band images. However, the handling
# of no data areas is different. I think you have to use the 99.9th percentile for
# the stretch functions because the max value is used to identify no data cells.
#
# Band order:
# B1 = Blue, B2 = Green, B3 = Panchro, B4 = Red, B5 = Red-Edge, B6 = Near-IR, B7 = LWIR
multiband <- rast(paste0(folder, baseName, ".tif"))

# multiband image has 16-bit values for storage but actual values do not range from 
# 0-255 or 0-65535 for bands 1-6. band 7 has values much higher values than the
# other bands. The LWIR band records data in 32-bit precision so the range of 
# values for the LWIR band is very different from the other bands.
#
# It looks like 65535 is being used as the NODATA value but not through the
# header (raster just has these values in places with NODATA). This makes
# it a little tricky to stretch the values in the bands. When testing, the
# mean value makes a good cutoff but it may not work for all images.
#
# There may also be problems computing the percentile value used for the stretch
# when the bands use a very large number to indicate no data. the percentiles
# will be skewed by the no data cells. For images with more/less non data pixels,
# the "best" percentile value for the stretch may change.
#
# get red band
rm <- multiband[[4]]

# deal with no data values...not sure if mean value will always work
rm <- ifel(rm > global(rm, mean)$mean, NA, rm)
summary(rm, size = size)
hist(rm, breaks = 50, maxcell = size)
global(rm, quantile, na.rm = TRUE, probs = c(0.999))

rms <- stretchq(rm, 0.999)
plot(rms, col = grDevices::gray.colors(255))

# values and plot for red band are the same as those for the single band image

gm<- multiband[[2]]
gm <- ifel(gm > global(gm, mean)$mean, NA, gm)
gms <- stretchq(gm, 0.999)

bm<- multiband[[1]]
bm <- ifel(bm > global(bm, mean)$mean, NA, bm)
bms <- stretchq(bm, 0.999)

rgb <- rast(list(rms, gms, bms))
plotRGB(rgb)

# function to pull a single band from the multiband image. this probably
# won't work for the LWIR band (band 7) but it might. It also stretches 
# things to 0-255. Should be able to replace the call to terra::stretch()
# with stretch16(b, maxq).
#
getBand <- function(
    mb,
    band = 0,
    fixNA = TRUE,
    stretch = TRUE,
    maxq = 0.999)
{
  if (band == 0)
    stop("Must specify a band to extract!!")
  
  # check for number of bands
  if (band > dim(mb)[3])
    stop("Band to extract is larger than number of bands in image!!")
  
  # get the band
  b <- mb[[band]]
  
  if (fixNA) {
    b <- terra::ifel(b > terra::global(b, mean)$mean, NA, b)
  }
  
  if (stretch) {
    b <- terra::stretch(b, minq = 0.0, maxq = maxq, maxcell = dim(b)[1] * dim(b[2]))
  }
  
  invisible(return(b))
}

rm <- getBand(multiband, 4)
plot(rm, col = grDevices::gray.colors(255))

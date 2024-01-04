# code to convert DTMs from .tif to .dtm format. Uses the fusionwrapr package
# to convert terra SpatRasters into FUSION (PLANS) .dtm format
#
# Data are in UTM zone 10 with XY and elevations in meters
#
# Source file names (.tif) are in FileSystem.R
source("Rcode/FileSystem.R")

library(fusionwrapr)

for (i in 1:6) {
  d <- rast(DTMFiles[i])
  outFile <- paste0(dirname(DTMFiles[i]), "/ground.dtm")
  
  writeDTM(d, outFile, xyunits = "m", zunits = "m", coordsys = 2, zone = 10, horizdatum = 2, vertdatum = 2)
}

# explore 2022 field and lidar data
#
library(sf)
library(tidyverse)
library(mapview)

source("../DroneLidarCode/Rcode/PredictDBH_Height.R")

makeFUSIONTrees <- function(x, R = 0, G = 192, B = 0, statusCode = 0) {
  if (nrow(x)) {
    FUSIONtrees <- data.frame(
      "TreeID" = x$TreeID,
      "X" = x$X,
      "Y" = x$Y,
      "Elevation" = 0.0,
      "Height_m" = x$T3Ht,
      "CBH_m" = x$T3Ht * 0.6,
      "MinCrownDia_m" = x$T3Ht * 0.16,
      "MaxCrownDia_m" = x$T3Ht * 0.16,
      "rotation" = 0.0,
      "R" = R,
      "G" = G,
      "B" = B,
      "DBH_m" = x$DBH_cm / 100,
      "LeanFromVertical" = 0,
      "LeanAzimuth" = 0,
      "StatusCode" = statusCode
    )
    
    return(invisible(FUSIONtrees))
  } else {
    return(invisible(NULL))
  }
}

dataFolder <- "H:/T3_GIS/2022 Field Season/Shapefiles/"
lidarFolder <- "H:/2022_DroneLidar/"

# read lidar index
index <- st_read(paste0(lidarFolder, "DroneIndex2022.shp"))
mapview(index)

# build list of shapefiles for plots
plotFiles <- list.files(path=dataFolder, pattern=".shp", all.files=TRUE, full.names=TRUE)

# drop files with .shp.xml in their name
t <- grep(".xml", plotFiles)
plotFiles <- plotFiles[-t]

for (i in 1:length(plotFiles)) {
  cat (i, "\n\n")
  p <- st_read(plotFiles[i])
  
  crs <- st_crs(p)
  
  # plots 17, 19, 21, 22 are good. report different crs? manipulating the columns is messing up the crs
  # using add_column fixes the problem. the plot with 18 columns doesn't have GPS location
  if (i == 9 | i == 11 | i == 12 | i == 13 | i == 14 | i == 15 | i == 16 | i == 18 | i == 20)
    next
  
  n <- colnames(p)
  if (length(n) == 19)
    p = p%>% add_column(X_1 = NA, .after = 1)
#    p <- c(p[1], "X_1", p[2:19])

  if (length(n) == 18)
    p <- c(p[1], "X_1", p[2:7], "DBH_cm", p[9:15], "Note", p[16:18])

  st_crs(p) <- crs

  if ( i == 1) {
    plots <- p
  } else {
    plots <- rbind(plots, p)
   }
}

mapview(list(index, plots))



# create FUSION tree files using data for all plots
targetPlots <- c(48, 49, 50, 51, 52, 53, 54, 55)
for (i in 1:length(targetPlots)) {
  trees <- plots[plots$Plot_Numbe == targetPlots[i], ]
  
  # build tree ID
  trees$TreeID <- paste0(trees$Plot_Numbe, "_", trees$Tag_Num, "_", trees$Species)
  
  # predict tree height
  for (j in 1:nrow(trees))
    trees$T3Ht[j] <- predictHeight(trees$Species[j], trees$DBH_cm[j], method = "FVS", heightUnits = "meters", DBHUnits = "cm")
  
  fTrees <- makeFUSIONTrees(trees)
  
  # modify the color based on the lidar visible flag and anomaly code
  for (j in 1:nrow(fTrees)) {
    if (trees$LiDAR_visi[j] == "Y" & trees$Anomaly_Nu[j] == 0)
      fTrees$R[j] = 255
  }
  
  write.csv(fTrees, file = paste0("extras/", "FUSIONFieldLocations_Plot_", targetPlots[i], ".csv"), row.names = FALSE, quote = TRUE)
}

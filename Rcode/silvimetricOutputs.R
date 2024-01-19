# code to explore silvimetric outputs
library(terra)
library(mapview)

fileName <- "C:/Users/bmcgaughey/metrics/m_Intensity_max.tif"

i <- rast(fileName)

plot(i)
summary(i)

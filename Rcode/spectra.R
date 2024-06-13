library(photobiologyFilters)
library(photobiologyWavebands)
library(ggspectra)
library(ggplot2)
library(magrittr)
library(rlang)

# I didn't get very far with this. You can produce some nice plots of reflectance data but
# I don't know ggplot well enough to make the graphs really work.
#
# In the end, I used powerpoint to create a spectral image (but with no reflectance curves for various materials).
#
length(materials.mspct)
names(materials.mspct)

# drop some materials
mat <- materials.mspct[c(1, 2, 5, 6, 7, 8, 9, 10, 11)]
names(mat) <- c("asphalt", "concrete", "clay soil", "dark soil", "dry grass", "green grass", "conifer", "deciduous", "snow")
names(mat)

col = c("gray", "tan", "yellow", "black", "blue", "green", "lightblue", "purple", "cyan")

autoplot(mat, range = c(0, 1000), 
         annotations = c("-", "peaks*"),
         legend = TRUE, facets = F, w.band = photobiologyWavebands::VIS_bands("ISO")) +
  aes(color = col, group = spct.idx, linetype = "solid") +
  theme(legend.position = "right")

str(materials.mspct)


autoplot(mat, range = c(0, 1000), 
         annotations = c("-", "peaks*"),
         legend = TRUE, 
         facets = F, 
         w.band = c(VIS_bands(), IR_bands("CIE"))) + 
 # geom_line(linewidth = 1) +
  theme(legend.position = "right")



geom_area(data = . %>% trim_wl(range = NIR()) %>% tag(w.band = IR_bands()),
          mapping = aes(fill = wb.color)) +
  scale_fill_identity()

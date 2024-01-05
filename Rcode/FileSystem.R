# code to set paths and filenames
#
# folder names and drive letters are specific to my computer. Most necessary changes
# will be handled by changing dataFolder. However, the DTM conversion logic has
# full file names so they will need to be changed as well.
#
# I made some corrections to file names...see notes.txt in extras. There
# are also some inconsistencies in the folder structure for plot_8_9_14 with
# separate folders for Plot_8_9 and Plot_14.
#
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

plotFolders <- c(
  "OESF_Cedar_Plot_8_9_14"
  , "OESF_Cedar_Plot_8_9_14"
  , "OESF_Cedar_Plot_10"
  , "OESF_Cedar_Plot_8_9_14"
  , "ONF_Cedar_Plot_15_16"
  , "ONF_Cedar_Plot_15_16"
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

# these are the names used to identify the bands. The file names for the bands are formed
# using the imageFileBaseNames[n] + "_transparent_reflectance_" + bandNames[n] + ".tif"
bandNames <- c(
  "red"
  , "green"
  , "blue"
  , "nir"
  , "red edge"
  , "panchro"
)

DTMFiles <- c(
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/OESF_Cedar_Plot_10/OESF_Cedar_Plot_10_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/OESF_Cedar_Plot_8_9_14/OESF_Cedar_Plot_8_9_14_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_15_16/ONF_Cedar_Plot_15_16_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_17_thru_22/ONF_Cedar_Plot_17_thru_22_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_23_24_25/ONF_Cedar_Plot_23_24_25_DTM.tif",
  "H:/westforkenv_cedar_plots_2023/Cedar_Plots/ONF_Cedar_Plot_26_27/ONF_Cedar_Plot_26_27_DTM.tif"
)

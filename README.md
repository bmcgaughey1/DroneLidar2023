DroneLidar2023
================
Robert J. McGaughey
2024-01-04

<!-- README.md is generated from README.Rmd. Please edit that file -->

# Overview

This repository contains code and information for the 2023 drone lidar
and imagery collected over cedar plots and young stands.

# 2023 Drone Lidar Data

The data for the young stands and cedar plots was delivered in late
December 2023. The data for cedar plots includes multispectral imagery
and lidar data. Data for the young stand areas doesn’t have imagery.

The imagery was delivered as separate bands. Each band is stored in TIF
format with 4-byte integer values for the digital numbers (DNs). The
actual values range from 0.0 to 1.0 so this is a waste of file space.
The code in **CompositeImages.R** converts the DNs to single byte values
using terra::stretch() with default values (DNs range from 0 to 255).
Composite images are stored using a single byte for each band so the
final file size for the 3-band composite images is smaller than the size
of the original single-band files.

Overall, the imagery is dark with lots of deep shadow areas. In
addition, there are some problems with the imagery with sharpness and
registration. I did a bit of research online and found reports of
problems using Pix4D with images collected over areas with relief (and
presumably areas with tall objects). The problems I found are related to
varying GSD across image sets due to the distance from the camera to the
ground or objects (trees) captured in the images. I emailed Chris
Erikson about this and he verified that there are some issues with the
imagery that he wants to learn more about and, potentially, correct. The
registration problems could be related to this same issue. Some areas
are worse than others and the worst area is the one with the most
topography (area covering plots 17-22).


setwd("D:/GitHub/Generate-Raster-Data-from-Vector-R")

source("set-up.R")#load script with required packages
source("r_scripts/Functions/StudyAreaLineDensityRaster.R")#load custom function

#Load Vector Data

bound <- st_read("input_data/DEM_2013_TIF",
                 layer = "BoundaryMask") #study area boundary polygon

VanCT <- st_read("input_data",
                 layer = "VanCT")# census tract polygon

sep_bls <- st_read("input_data",
                   layer = "sep_bls")#separated bike lane polylines


ggplot(bound) +
  geom_sf() + 
  ggtitle("City of Vancouver Boundary overlaid by separated bike lane polylines") + 
  geom_sf(data = sep_bls,color="black") + 
  xlab("Longitude") + 
  ylab("Latitude") +
  theme_bw()



#"Rasterize" polyline data using custom function

sepbls_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                          inputLines = sep_bls,
                                          cellSize = 100,
                                          buffWidth = 100)




sepbls_rast_df <- as.data.frame(sepbls_rast, xy = TRUE)


ggplot() +
  geom_raster(data = sepbls_rast_df,aes(x=x,y=y,fill=layer)) + 
  scale_fill_viridis_c() +
  ggtitle("City of Vancouver Bikelane Density") + 
  xlab("Longitude") + 
  ylab("Latitude") +
  coord_quickmap() + 
  theme_bw()

# sepbls_rast_mask <- mask(sepbls_rast, as(bound, "Spatial"))


# writeRaster(x = sepbls_rast_mask,
#             filename = "output/sepbls_length_100mbuff_mask.tif",
#             datatype = "FLT4S")





setwd("D:/GitHub/Generate-Raster-Data-from-Vector-R")

source("set-up.R")#load script with required packages
source("r_scripts/function/rasterize_lines.R")#load custom function

#Load Vector Data

bound <- st_read("input_data/DEM_2013_TIF",
                 layer = "BoundaryMask") #study area boundary polygon

VanCT <- st_read("input_data",
                 layer = "VanCT")# census tract polygon

sep_bls <- st_read("input_data",
                   layer = "sep_bls")#separated bike lane polylines


ggsave(ggplot(bound) +
  geom_sf() + 
  ggtitle("City of Vancouver Boundary overlaid by\nseparated bike lane polylines") + 
  geom_sf(data = sep_bls,color="black") + 
  xlab("Longitude") + 
  ylab("Latitude") +
  theme_bw(),filename = "vancouver_bikelane_vector.jpg",path = "imgs")



#"Rasterize" polyline data using custom function

sepbls_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                          inputLines = sep_bls,
                                          cellSize = 100,
                                          buffWidth = 100)




# sepbls_rast_df <- as.data.frame(sepbls_rast, xy = TRUE)


ggsave(plot = ggplot() +
         geom_raster(data = sepbls_rast_df,aes(x=x,y=y,fill=layer)) + 
         scale_fill_viridis_c(name = "Metres of\nBikelanes\nwithin 100m") +
         ggtitle("City of Vancouver: Rasterized Separated Bikelanes") + 
         xlab("Longitude") + 
         ylab("Latitude") +
         coord_quickmap() + 
         theme_bw(),filename = "vancouver_bikelane_raster.jpg",path = "output_data")
          

# sepbls_rast_mask <- mask(sepbls_rast, as(bound, "Spatial"))


# writeRaster(x = sepbls_rast_mask,
#             filename = "output/sepbls_length_100mbuff_mask.tif",
#             datatype = "FLT4S")



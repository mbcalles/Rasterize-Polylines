
setwd("D:/GitHub/Rasterize-Polylines")

source("set-up.R")#load script with required packages
source("r_scripts/function/rasterize_lines.R")#load custom function

#Load Vector Data

bound <- st_read("input_data/DEM_2013_TIF",
                 layer = "BoundaryMask") #study area boundary polygon

VanCT <- st_read("input_data",
                 layer = "VanCT")# census tract polygon

sep_bls <- st_read("input_data",
                   layer = "sep_bls")#separated bike lane polylines


vector_map <- ggplot(bound) +
  geom_sf() + 
  ggtitle("City of Vancouver boundary by separated bike lane polylines") + 
  geom_sf(data = sep_bls,color="black") + 
  xlab("Longitude") + 
  ylab("Latitude") +
  theme_bw()

ggsave(filename = "vancouver_bikelane_vector.jpg",path = "imgs")



#"Rasterize" polyline data using custom function

sepbls_rast <- rasterize_lines(inputStudyArea = VanCT,
                                          inputLines = sep_bls,
                                          cellSize = 100,
                                          buffWidth = 300,
                                          mask=F)


sepbls_rast_df <- as.data.frame(sepbls_rast, xy = TRUE)


rasterized_map <- ggplot() +
  geom_raster(data = sepbls_rast_df,aes(x=x,y=y,fill=layer)) + 
  scale_fill_viridis_c(name = "Metres of\nBikelanes\nwithin 300m") +
  ggtitle("City of Vancouver: Rasterized Separated Bikelanes") + 
  xlab("Longitude") + 
  ylab("Latitude") +
  coord_equal() + 
  theme_map() +
  theme(legend.position="bottom") +
  theme(legend.key.width=unit(2, "cm"))

ggsave(rasterized_map,device = "jpeg",filename = "vancouver_bikelane_raster.jpg",path = "imgs")
          





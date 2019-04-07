
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

unsep_bls <- st_read("input_data",
                   layer = "unsep_bls")#unseparated bike lane polylines


art_col_rds <- st_read("input_data",
                     layer = "art_col_roads")#arterial road lane polyglines


#"Rasterize" polyline data using custom function

sepbls_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                          inputLines = sep_bls,
                                          cellSize = 100,
                                          buffWidth = 100)

plot(sepbls_rast)


sepbls_rast_mask <- mask(sepbls_rast, as(bound, "Spatial"))


# writeRaster(x = sepbls_rast_mask,
#             filename = "output/sepbls_length_100mbuff_mask.tif",
#             datatype = "FLT4S")



#Unseparated Bike Path

unsepbls_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                          inputLines = unsep_bls,
                                          cellSize = 100,
                                          buffWidth = 100
)

unsepbls_rast_mask <- mask(unsepbls_rast, as(bound, "Spatial"))


plot(unsepbls_rast_mask)

# writeRaster(x = unsepbls_rast_mask,
#             filename = "output/unsepbls_length_100mbuff_mask.tif",
#             datatype = "FLT4S")


#Arterial Road Density

artcolrds_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                            inputLines = art_col_rds,
                                            cellSize = 100,
                                            buffWidth = 100
)

artcolrds_rast_mask <- mask(artcolrds_rast, as(bound, "Spatial"))

# writeRaster(x = artcolrds_rast_mask,
#             filename = "output/artcolrd_length_100mbuff_mask.tif",
#             datatype = "FLT4S")
# 





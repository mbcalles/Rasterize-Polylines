source("set-up.R")
source("R/Functions/StudyAreaLineDensityRaster.R")

#Load Vector Data

bound <- st_read("input/DEM_2013_TIF",
                 layer = "BoundaryMask")

VanCT <- st_read("input",
                 layer = "VanCT")

sep_bls <- st_read("input",
                   layer = "sep_bls")

unsep_bls <- st_read("input",
                   layer = "unsep_bls")


art_col_rds <- st_read("input",
                     layer = "art_col_roads") #read in road layer


#Separated Bike Path


sepbls_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                          inputLines = sep_bls,
                                          cellSize = 100,
                                          buffWidth = 100
)
plot(sepbls_rast)


sepbls_rast_mask <- mask(sepbls_rast, as(bound, "Spatial"))


writeRaster(x = sepbls_rast_mask,
            filename = "output/sepbls_length_100mbuff_mask.tif",
            datatype = "FLT4S")



#Unseparated Bike Path

unsepbls_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                          inputLines = unsep_bls,
                                          cellSize = 100,
                                          buffWidth = 100
)

unsepbls_rast_mask <- mask(unsepbls_rast, as(bound, "Spatial"))


plot(unsepbls_rast_mask)

writeRaster(x = unsepbls_rast_mask,
            filename = "output/unsepbls_length_100mbuff_mask.tif",
            datatype = "FLT4S")


#Arterial Road Density

artcolrds_rast <- StudyAreaLineDensityRaster(inputStudyArea = VanCT,
                                            inputLines = art_col_rds,
                                            cellSize = 100,
                                            buffWidth = 100
)

artcolrds_rast_mask <- mask(artcolrds_rast, as(bound, "Spatial"))

writeRaster(x = artcolrds_rast_mask,
            filename = "output/artcolrd_length_100mbuff_mask.tif",
            datatype = "FLT4S")

#DEM 2013 





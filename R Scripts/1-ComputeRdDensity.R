
#polygon refers to an sp polygon object
#line refers to an sp line object
#buff distance of 0 if no buffer required around individual polygons
#colname in quotations to specify desired column name in output sp object
#beep =TRUE if you want to have a noise notify you the function is done running (can take a long time)

source("set-up.R")



points <- st_read("input",
                   layer = "VancouverFishnetCentroids") %>% select(ORIG_FID) #read in points of fishnet



buff <- st_buffer(points,dist=500)#create buffer around points

rds <- st_read("input",
                  layer = "art_col_roads") #read in road layer

  
buff_ls <- st_cast(buff,"MULTILINESTRING")#convert buffer of points into lines

int_ls_buff <- st_intersection(buff_ls,rds) %>% #find intersection of road lines and centroid buffers
  st_cast("MULTIPOINT") %>%
  st_cast("POINT")

int_ls_buff <- st_geometry(int_ls_buff)#use only geometry

int_ls_buff <- st_buffer(int_ls_buff,dist = 0.0000001) %>% st_combine() #buffer points to very small distance


split_rds <- st_geometry(rds) %>% st_combine() #combine roads into one gemetry

#split study area into smaller sections
grid <- st_make_grid(buff,what = "polygons",n = 100)#split bounding box iof polygon into grid
grid <- grid[st_intersects(grid,int_ls_buff,sparse = F)[,1]]#remove grid cells that do not hintersect with the roads

#iterate through each grid cell andintersect roads with grid cell, split the line geometry within that cell by the intersection buffers
for(i in 1:length(grid)){
  
  temp <- st_intersection(int_ls_buff,grid[i])
  split_rds <- st_difference(split_rds,temp)
  print(paste( round(i/length(grid)*100, 0),
                                        "% done"))
}


#st_write(obj = split_rds, dsn = "output/split_rds_mls.shp")#write object o shapefile

split_rds_linestring <- split_rds %>%
  st_cast("LINESTRING")#convert to linestring to isolate non-contiguous lines

split_rds_lengths <- st_sf(data.frame(length_m = st_length(split_rds_linestring)), geometry = split_rds_linestring) #calculate each line segment length

#st_write(obj = split_rds_lengths, dsn = "output/split_rds_lengths.shp")#write object o shapefile



#Join to line polygons, sum line segment length within each polygon
buff_rdlengths <- buff %>%
  st_join(split_rds_lengths) %>%
          group_by(ORIG_FID) %>%
          summarize(rd_length = sum(length_m))

#st_write(obj = buff_rdlengths, dsn = "output/buff_rds_mls.shp")

#convert polygons to centroids

cntrd_buff_rdlengths <- st_centroid(buff_rdlengths) %>% mutate(rd_length = replace_na(rd_length,0))

fishnet <- st_read("input",
                  layer = "VancouverFishnet") #read in ishnet


raster_template = raster(extent(fishnet), resolution = 100,
                         crs = st_crs(cntrd_buff_rdlengths)$proj4string)


rstr_rdlength_500mbuff = rasterize(cntrd_buff_rdlengths, raster_template, 
                       field = "rd_length", fun = sum)

plot(rstr_rdlength_500mbuff)


writeRaster(x = rstr_rdlength_500mbuff,
            filename = "output/rd_length_500mbuff.tif",
            datatype = "FLT4S")

#Function that takes an input study area polygon, input polyline data and creates a "rasterized" version of the data

rasterize_lines <- function(input_study_area,input_linestring,cell_size=100,buffer_width=300,mask=F){
  require(sf)
  require(raster)
  require(tidyverse)

  if(st_crs(input_study_area)$proj4string==st_crs(input_linestring)$proj4string){ #check that both study area and polyline files are in the same coordinate system and projection


    print("Generating grid...")
    #Create template raster from Study Area extent (empty raster with the extent of the study area, and cell size as indicated)
    raster_template <- raster(extent(input_study_area), resolution = cell_size,
                              crs = st_crs(input_study_area)$proj4string)
    print("Buffering grid cell centroids....")

    rast_point <- rasterToPoints(raster_template, spatial = TRUE) %>%
      st_as_sf() #create point layer from template raster based on the centroid

    rast_point_buff <- st_buffer(rast_point,dist=buffer_width)#create buffers from raster cell centroids of specified width


    print("Finding intersections between grid cell centroid buffers and input lines...")

    #find intersection points between buffer boundaries and input_linestring (e.g. isolate buffers that actually intersect with polyline data)
    rast_point_buff_ls <- st_cast(rast_point_buff,"LINESTRING")

    input_linestring <- st_geometry(input_linestring) %>%
      st_transform(crs = st_crs(rast_point_buff_ls)$proj4string)#reduce size of dataset and ensure proj4strings are the same

    int_points <- st_intersection(rast_point_buff_ls,input_linestring) %>% #find intersection of road lines and centroid buffers
      st_cast("MULTIPOINT") %>%
      st_cast("POINT")

    print("Splitting input lines by intersections...")

    int_points_buff <- st_buffer(int_points,dist = 0.0000001) %>% st_combine() #buffer points to very small distance

    grid <- st_make_grid(rast_point_buff,what = "polygons",n = c(10,10))#split bounding box of polygon into grid
    grid <- grid[st_intersects(grid,int_points_buff,sparse = F)[,1]]#remove grid cells that do not intersect with the roads
    printPercent <- seq(from = 0, to = length(grid),by=(length(grid)/20))

    #iterate through each grid cell and intersect roads with grid cell, split the line geometry within that cell by the intersection buffers
    for (i in 1:length(grid)) {
      temp <- st_intersection(int_points_buff, grid[i])
      input_linestring <- st_difference(input_linestring, temp)

      if (i %in% round(printPercent)) {
        print(paste(round(i / length(grid) * 100, 0),
                    "% of lines split"))
      }
    }

    print("Calculating lengths of split polylines...")

    input_linestring_ls <- input_linestring %>%
      st_cast("MULTILINESTRING") %>%
      st_cast("LINESTRING")#convert to linestring to isolate non-contiguous lines

    input_linestring_ls <-
      st_sf(data.frame(length_m = st_length(input_linestring_ls)), geometry = input_linestring_ls) #calculate each line segment length

    print("Spatially aggregating road lengths by each cell centroid buffer")

    #Join to line polygons, sum line segment length within each polygon
    rast_point_buff <-
      st_sf(data.frame(ID = seq(1, length(st_geometry(rast_point_buff))),
                       geometry = rast_point_buff)) #create sf object with the geometry of the point buffer

    rast_point_buff <- rast_point_buff %>%
      st_join(input_linestring_ls) %>% #join lines split by buffer geometry and associated lengths to the buffer it falls within (e.g. points buffer is the target layer, input lines are join layer)
      group_by(ID) %>%
      summarize(line_length = sum(length_m),`.groups`="drop_last") %>%
      mutate(line_length = replace_na(line_length, 0)) %>%
      st_set_agr(c(line_length = "identity", ID = "identity")) #specify attribute-geometry relationship to avoid warning since we already know line_length represents the value over the entire geometry

    rast_point_buff_cntrd <- st_centroid(rast_point_buff)

    output_rast = rasterize(rast_point_buff_cntrd,
                            raster_template,
                            field = "line_length",
                            fun = sum)

    if(mask==TRUE){

      output_rast <- mask(output_rast, as(input_study_area, "Spatial"))


    }


  }else{
    "Input study area must be in the same projection as input lines"


  }

  return(output_rast)

}


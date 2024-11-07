get_municipality <- function(header){
  coordinates <- tibble(
    lat = as.numeric(sub(",", ".", header[5,2], fixed = TRUE)),
    long = as.numeric(sub(",", ".", header[6,2], fixed = TRUE))
  )
  
  points <- st_as_sf(coordinates, coords = c("long", "lat")) %>%
    st_set_crs(4674) 
  
  tmp <- st_intersection(x = points, y = brmun) %>%
    st_drop_geometry() %>%
    select(code_muni, name_muni)
  
  if(nrow(tmp) == 0){
    tmp <- tibble(
      code_muni = NA,
      name_muni = NA
    )
  }
  
  return(tmp)
}
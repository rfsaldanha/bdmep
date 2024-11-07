library(tidyverse)
library(janitor)

source("fun/parse_header.R")

files_list <- paste0("data/2022/", list.files(path = "data/2022/", recursive = TRUE))


stations_headers <- data.frame()
for(f in files_list){
  tmp <- parse_header(file = f) %>%
    pivot_wider() %>%
    janitor::clean_names() %>%
    mutate(
      latitude = as.numeric(str_replace(latitude, ",", ".")),
      longitude = as.numeric(str_replace(longitude, ",", ".")),
    )
  
  stations_headers <- bind_rows(stations_headers, tmp)
}


write_csv(x = stations_headers, file = "stations_headers_2022.csv")




# Packages ----------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(duckdb)
library(sf)
sf_use_s2(FALSE)
library(tictoc)

brmun <- readRDS(file = "brmun.rds")


# Functions ---------------------------------------------------------------

source(file = "fun/parse_header.R")
source(file = "fun/get_municipality.R")
source(file = "fun/parse_bdmep.R")


# Database ----------------------------------------------------------------

db_dir <- "bdmep.duckdb" 
db_table <- "hourly_data"

if(file.exists(db_dir)) unlink(db_dir)


# Files list --------------------------------------------------------------

files_list <- paste0("data/", list.files(path = "data/", recursive = TRUE))



# Loop --------------------------------------------------------------------

conn = dbConnect(duckdb::duckdb(), dbdir = db_dir)
tic()
for(f in files_list){
  tmp <- parse_bdmep(file = f)
  dbWriteTable(
    conn = conn, 
    name = db_table, 
    value = tmp,
    append = TRUE
  )
  rm(tmp)
}
toc()

# 1534.499 sec elapsed

dbDisconnect(conn, shutdown = TRUE)

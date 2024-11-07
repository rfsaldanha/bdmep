# Packages ----------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(duckdb)
library(arrow)

# Database ----------------------------------------------------------------

db_dir <- "bdmep.duckdb" 
db_table <- "hourly_data"

conn = dbConnect(duckdb::duckdb(), dbdir = db_dir)

hourly_tb <- tbl(conn, "hourly_data")


# Daily aggregation -------------------------------------------------------

daily_aggregate <- hourly_tb %>%
  mutate(date = as.Date(datetime)) %>%
  group_by(code_muni, name_muni, station_cod, station_name, date) %>%
  summarise(
    prec_tot = sum(prec_total, na.rm = TRUE),
    prec_avg = mean(prec_total, na.rm = TRUE),
    temp_sec = mean(temp_sec, na.rm = TRUE),
    temp_max = mean(temp_max, na.rm = TRUE),
    temp_min = mean(temp_min, na.rm = TRUE),
    umid_max = mean(umid_rel_max, na.rm = TRUE),
    umid_min = mean(umid_rel_min, na.rm = TRUE),
    umid = mean(umid_real, na.rm = TRUE)
  ) %>%
  ungroup()

if(dbExistsTable(conn = conn, name = "daily_data")){
  dbRemoveTable(conn = conn, name = "daily_data")
}


# Execute -----------------------------------------------------------------

daily_tb <- compute(daily_aggregate, "daily_data", temporary = FALSE)


# Export ------------------------------------------------------------------

conn = dbConnect(duckdb::duckdb(), dbdir = db_dir)

tbl(conn, "daily_data") %>% 
  collect() %>%
  write_parquet(sink = "parquet/bdmep_daily.parquet")

dbDisconnect(conn, shutdown = TRUE)

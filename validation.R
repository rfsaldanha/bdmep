# Packages ----------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(duckdb)
library(arrow)


# Data --------------------------------------------------------------------

bdmep_conn <- dbConnect(duckdb::duckdb(), 
                       dbdir = "bdmep.duckdb", 
                       read_only = TRUE)

brdwgd_conn <- dbConnect(duckdb::duckdb(), 
                                      dbdir = "../brclim/db/job_brdwgd_br_19610101_20200731.duckdb", 
                                      read_only = TRUE)

cod_mun <- 4314902

bdmep_data <- tbl(bdmep_conn, "daily_data") %>%
  filter(code_muni == cod_mun) %>%
  select(station_cod, date, prec_tot, prec_avg, temp_max, temp_min) %>%
  arrange(station_cod, date) %>%
  filter(date >= as.Date("2010-01-01") & date <= as.Date("2015-01-01")) %>%
  collect()

brdwgd_data_tmax <- tbl(brdwgd_conn, "Tmax") %>%
  filter(code_muni == cod_mun) %>%
  filter(name == "Tmax_mean") %>%
  collect() %>%
  filter(date >= as.Date("2010-01-01") & date <= as.Date("2015-01-01")) %>%
  select(date, value)

brdwgd_data_tmin <- tbl(brdwgd_conn, "Tmin") %>%
  filter(code_muni == cod_mun) %>%
  filter(name == "Tmin_mean") %>%
  collect() %>%
  filter(date >= as.Date("2010-01-01") & date <= as.Date("2015-01-01")) %>%
  select(date, value)

brdwgd_data_prec <- tbl(brdwgd_conn, "pr") %>%
  filter(code_muni == cod_mun) %>%
  filter(name == "pr_mean") %>%
  collect() %>%
  filter(date >= as.Date("2010-01-01") & date <= as.Date("2015-01-01")) %>%
  select(date, value)

ggplot() +
  geom_line(
    data = bdmep_data, 
    aes(x = date, y = temp_max, colour = station_cod),
    alpha = .5
  ) +
  geom_line(
    data = brdwgd_data_tmax,
    aes(x = date, y = value),
    alpha = .5, color = "purple"
  )


ggplot() +
  geom_line(
    data = bdmep_data, 
    aes(x = date, y = temp_min, colour = station_cod),
    alpha = .5
  ) +
  geom_line(
    data = brdwgd_data_tmin,
    aes(x = date, y = value),
    alpha = .5, color = "orange"
  )

ggplot() +
  geom_line(
    data = bdmep_data, 
    aes(x = date, y = prec_avg, colour = station_cod),
    alpha = .5
  ) +
  geom_line(
    data = brdwgd_data_prec,
    aes(x = date, y = value),
    alpha = .5, color = "blue"
  )


teste_tmax <- inner_join(bdmep_data, brdwgd_data_tmax, by = "date") %>%
  select(date, bdmep = temp_max, brdwgd = value) %>%
  arrange(date) %>%
  na.omit() %>%
  mutate(dif = brdwgd - bdmep)


plot(teste_tmax$bdmep, teste_tmax$brdwgd)

mean(teste_tmax$dif)

cor.test(teste_tmax$bdmep, teste_tmax$brdwgd)

TSclust::diss.EUCL(teste_tmax$bdmep, teste_tmax$brdwgd)

TSdist::ManhattanDistance(teste_tmax$bdmep, teste_tmax$brdwgd)

TSclust::diss.DTWARP(teste_tmax$bdmep, teste_tmax$brdwgd)




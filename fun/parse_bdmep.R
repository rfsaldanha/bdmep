parse_bdmep <- function(file, db_dir, db_table){
  # Variables abbreviated names and types
  data_col_names <- c("data", "hora", "prec_total", "press", "press_max", "press_min", "rad", "temp_sec", "temp_orv", "temp_max", "temp_min", "temp_orv_max", "temp_orv_min", "umid_rel_min", "umid_rel_max", "umid_real", "vento_dir", "vento_raj", "vento_veloc")
  data_col_types <- c("ccnnnnnnnnnnnnnnnnn")
  
  # Parse header
  header <- parse_header(file = file)
  
  # Municipality
  mun_info <- get_municipality(header) %>%
    suppressMessages() %>%
    suppressWarnings()
  
  # CSV file reading with encoding, skip the header
  tmp <- read_delim(
    file = file, 
    skip = 9, 
    col_names = data_col_names,
    col_types = data_col_types,
    delim = ";", 
    na = c("", "NA", "-9999", -9999),
    locale = locale(
      encoding = "latin1", 
      decimal_mark = ",", 
      grouping_mark = "."
    )
  ) %>%
    # Remove junk variable
    select(-X20) %>%
    # Parse correct date and time
    mutate(
      datetime = parse_date_time(
        x = paste(data, hora), 
        tz = "UTC",
        orders = c("%Y/%m/%d %H%M", "%Y/%m/%d %H:%M",
                   "%Y-%m-%d %H%M", "%Y-%m-%d %H:%M")
      ) %>% with_tz(tzone = "UTC")
    ) %>%
    # Add station code and name from header
    mutate(
      station_cod = pull(header[4,2]),
      station_name = pull(header[3,2])
    ) %>%
    # Remove original date and time
    select(-data, -hora) %>%
    # Relocate select(-data, -hora) 
    relocate(station_cod, station_name, datetime)
  
  # Add municipality data
  tmp <- tmp %>%
    mutate(
      code_muni = mun_info$code_muni,
      name_muni = mun_info$name_muni
    ) %>%
    relocate(code_muni, name_muni)
  
  # Return result
  return(tmp)
}
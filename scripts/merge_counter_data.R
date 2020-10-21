packages <- c(
  "tidyverse",
  "fs",
  "here",
  "janitor"
)

invisible(lapply(packages, library, character.only = TRUE))

data_files <- list.files(here("data", "all"), pattern = "*.csv")

locations_file <- paste(here("data"), "locations.csv", sep = "/")

locations <- read_csv(locations_file)

field_names <- c("date", "hour", "total_ct", "ped_ct", "bike_ct")

merged_tibble <- data_files %>%
  paste(here("data", "all"), ., sep = "/") %>%
  set_names() %>%
  map_dfr(read_csv, .id = "sensor_id") %>%
  clean_names() %>%
  mutate(
    sensor_id = path_ext_remove(path_file(sensor_id)),
    date = as.Date(date, format = "%d/%m/%Y"),
    hour = x2
  )

tidy_tibble <- merged_tibble %>%
  select(-x2) %>%
  group_by(sensor_id, date, hour) %>%
  pivot_longer(
    -c(sensor_id, date, hour),
    names_to = "count_name",
    values_to = "count"
  ) %>%
  drop_na() %>%
  left_join(locations)

output_file <- paste(here("data"), "all_tidy.csv", sep = "/")

write_csv(tidy_tibble, output_file)
  

# tidy_tables.R
# written by Tim Riley, 2020-06-08
packages <- c(
  "tidyverse",
  "sf",
  "here"
)

invisible(lapply(packages, library, character.only = TRUE))

data <- read_csv(here("data","2020-04-16_2020-05-16.csv")) %>%
  mutate(Date = as.Date(Date, "%d/%m/%y")) %>%
  pivot_longer(
    cols = -Date,
    names_to = c("loc_name", "type", "direction"),
    names_sep = "_",
    values_to = "count"
  )

summary <- data %>%
  filter(type == "total") %>%
  select(loc_name, count) %>%
  group_by(loc_name) %>%
  summarize(monthAvgTot = round(sum(count) / 31)) %>%
  left_join(data %>%
           filter(type == "ped") %>%
           select(loc_name, count) %>%
           group_by(loc_name) %>%
           summarize(monthAvgPed = round(sum(count) / 31))
  ) %>%
  left_join(data %>%
              filter(type == "cyc") %>%
              select(loc_name, count) %>%
              group_by(loc_name) %>%
              summarize(monthAvgCyc = round(sum(count) / 31))
  )

write_csv(summary, paste(here("data"), "summary.csv", sep = "/"))




# Download and process inflation adjustment constants from Fred using API
# Blake Feist - 7 May 2024, adopted from Erin Steiner

# packages
library(dplyr)
library(readr)


# download the quarterly inflation adjustments from Fred from 1985 to present
fredr_set_key('3101834d945b5dddb0e6004862a11183') # The Fred API key I created at https://fred.stlouisfed.org/docs/api/api_key.html
fred_gdpdefl <- fredr(
  series_id = "GDPDEF",
  observation_start = as.Date("1985-01-01")
)

# generate the mean annual deflators using the quarterly values 
gdp_defl <- mutate(fred_gdpdefl, YEAR = format(date,"%Y")) %>%
  group_by(YEAR) %>%
  summarize(defl = mean(value), .groups = 'drop') %>%
  mutate(DEFL = defl/defl[YEAR == max(YEAR)]) %>%
  select(-defl) %>%
  mutate(YEAR = as.numeric(YEAR)) %>%
  data.frame()
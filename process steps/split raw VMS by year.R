# helper file to chunk up the enormous vms file Jameal downloaded

library(tidyverse)
library(here)

# vms_raw <- read_csv(here::here('data','raw','vms','vms_01012009_12312023.csv'))

# wayyy too big, so we need to do this in pieces
# try to brute force in 10M-row segments

st <- 1
chunk_num<-1

#I'll keep running the following lines until we run out of data to parse
# looks like 11 10M-row chunks
cn <- c("DOCNUM","VESSEL_NAME","DECLARATION_CODE","UTC_TIME","COURSE","SPEED","AVG_COURSE","AVG_SPEED","LAT","LON","FMC_PROVIDER_ID","PROVIDER","DATA_LOAD_DATE","UTCDATETIME","year")
x <- read_csv(here('Confidential','raw','vms','vms_01012009_12312023.csv'),
              skip=st,n_max=1e7,lazy=T,
              # column names explicit
              col_names = cn,
              # column types explicit
              col_types='ccicddddddicc') %>% 
  mutate(UTCDATETIME=parse_date_time(UTC_TIME, c("mdy HM","mdy HMS"))) %>% 
  mutate(year=year(UTCDATETIME))
yrs_captured <- paste(unique(x$year),collapse=" ")
write_rds(x,here('Confidential','raw','vms',paste0('vms chunk ',chunk_num," ",yrs_captured,'.rds')))
st <- st+1e7
chunk_num <- chunk_num+1
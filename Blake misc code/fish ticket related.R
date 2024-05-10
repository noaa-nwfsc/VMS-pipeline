# misc code boneyard for processing files in VMS Pipeline
# Blake Feist - 7 May 2024

# packages
library(dplyr)
library(readr)
library(desc)
library(DescTools)

# load master 1994 - 2023 fish tickets file
all_fishtickets_1994_2023 <- readRDS("~/Documents/GitHub/VMS-pipeline/Confidential/raw/fish tickets/all_fishtickets_1994_2023.rds")

# take a look at the attribute structure
glimpse(all_fishtickets_1994_2023)

# filter only Dungeness crab tickets
Dungeness <- all_fishtickets_1994_2023 %>%
  filter(PACFIN_SPECIES_CODE == "DCRB")

# take a look at the Dungeness crab attribute structure
glimpse(Dungeness)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
DCRB_gear <- table(Dungeness$PACFIN_GEAR_CODE)
# 99.73% of all DCRB tickets are from CPT, CLP, OTH or OPT, so only select those in master_process script


# filter only Chinook salmon tickets
Chinook <- all_fishtickets_1994_2023 %>%
  filter(PACFIN_SPECIES_CODE == "CHNK")

# take a look at the Chinook salmon attribute structure
glimpse(Chinook)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
CHNK_gear <- table(Chinook$PACFIN_GEAR_CODE)
# more detailed tally the number of tickets by PacFIN gear code to figure out which gear types to use
CHNK_gear <- Freq(Chinook$PACFIN_GEAR_CODE, ord-"desc")

# 99.88% of all CHNK tickets are from "TRL","GLN","STN","DPN","MDT","SEN","POL","JIG","ONT", so only select those in master_process script

## for running Chinook using master_process.Rmd
spp_codes <- c("CHNK")

gear_codes <- c("TRL","GLN","STN","DPN","MDT","SEN","POL","JIG","ONT")

# misc code boneyard for processing files in VMS Pipeline
# Blake Feist - 7 May 2024

# packages
library(dplyr)
library(readr)
library(desc)
library(DescTools)

# load master 1994 - 2023 fish tickets file
fishtickets <- readRDS("~/Documents/GitHub/VMS-pipeline/Confidential/raw/fish tickets/all_fishtickets_1994_2023.rds")

# take a look at the attribute structure
glimpse(fishtickets)

# filter only Dungeness crab tickets
Dungeness <- fishtickets %>%
  filter(PACFIN_SPECIES_CODE == "DCRB")

# take a look at the Dungeness crab attribute structure
glimpse(Dungeness)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
DCRB_gear <- table(Dungeness$GEAR_NAME)
# more detailed tally (using DescTools) the number of tickets by PacFIN gear code to figure out which gear types to use
DCRB_gear <- Freq(Dungeness$GEAR_NAME, ord = "desc")

# 99.66% of all DCRB tickets are from SHELLFISH POT (CRAB), CRAB OR LOBSTER POT, CRAB POT, CRAB RING, so only select those in master_process script

# save a tab delimited table
write_tsv(DCRB_gear, "Dungeness gear type freq distribution 1994-2023.txt")

## for running Dungeness using master_process.Rmd
spp_codes <- c("DCRB")

gear_codes <- c("SHELLFISH POT (CRAB)","CRAB OR LOBSTER POT","CRAB POT","CRAB RING")


# filter only Chinook salmon tickets
Chinook <- fishtickets %>%
  filter(PACFIN_SPECIES_CODE == "CHNK")

# take a look at the Chinook salmon attribute structure
glimpse(Chinook)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
CHNK_gear <- table(Chinook$GEAR_NAME)
# more detailed tally (using DescTools) the number of tickets by PacFIN gear code to figure out which gear types to use
CHNK_gear <- Freq(Chinook$GEAR_NAME, ord = "desc")

# code from Ole to check for errors in the gear codes and gear names
names(Chinook)
CHNK_gear2 <- Chinook %>% group_by(GEAR_CODE,GEAR_NAME) %>% summarise(N= length(GEAR_NAME)) %>% arrange(GEAR_CODE) %>% as.data.frame()


# Excluding eggs and any tickets with gear names that include "Col." or "Columbia River", 99.63% of all CHNK tickets are from
# TROLL, (SALMON), OCEAN TROLL, TROLL (SALMON), DRAG SEINE, DIP BAG NET, HOOK AND LINE, PURSE SEINE (SALMON),
# so only select those in master_process script

# save a tab delimited table
write_tsv(CHNK_gear, "Chinook gear type freq distribution 1994-2023.txt")

## for running Chinook using master_process.Rmd
spp_codes <- c("CHNK")

gear_codes <- c("TROLL, (SALMON)","SET NET","OCEAN TROLL","TROLL (SALMON)","GILL NET (SALMON)","DRAG SEINE","DIP BAG NET","HOOK AND LINE","PURSE SEINE (SALMON)")




# filter only Albacore tuna tickets
Albacore <- fishtickets %>%
  filter(PACFIN_SPECIES_CODE == "ALBC")

# take a look at the Dungeness crab attribute structure
glimpse(Albacore)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
ALBC_gear <- table(Albacore$GEAR_NAME)
# more detailed tally (using DescTools) the number of tickets by PacFIN gear code to figure out which gear types to use
ALBC_gear <- Freq(Albacore$GEAR_NAME, ord = "desc")

# 99.06% of all ALBC tickets are from OCEAN TROLL, TROLL (SALMON), TROLL (ALBACORE), HOOK AND LINE, JIG (ALBACORE), GILL NET, DRIFT, LONG LINE, SET, TROLL, (SALMON), so only select those in master_process script

# save a tab delimited table
write_tsv(ALBC_gear, "Albacore gear type freq distribution 1994-2023.txt")

## for running Albacore using master_process.Rmd
spp_codes <- c("ALBC")

gear_codes <- c("OCEAN TROLL","TROLL (SALMON)","TROLL (ALBACORE)","HOOK AND LINE","JIG (ALBACORE)","GILL NET, DRIFT","LONG LINE, SET","TROLL, (SALMON)")

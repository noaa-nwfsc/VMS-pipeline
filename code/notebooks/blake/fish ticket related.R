# misc code boneyard for processing files in VMS Pipeline
# Blake Feist - created 7 May 2024

# packages
library(dplyr)
library(readr)
library(desc)
library(DescTools)

# load master 1994 - 2023 fish tickets file
fishtickets <- readRDS("~/Documents/GitHub/VMS-pipeline/Confidential/raw_data/fish_tickets/all_fishtickets_1994_2023.rds")

# take a look at the attribute structure
glimpse(fishtickets)

# filter only Dungeness crab tickets
Dungeness <- fishtickets %>%
  filter(PACFIN_SPECIES_CODE == "DCRB")

# take a look at the Dungeness crab attribute structure
glimpse(Dungeness)

# filter for 2011 - 2023 tickets only
Dungeness_2011to23 <- Dungeness %>%
  filter(LANDING_YEAR > 2010)

# filter for CA only tickets only
Dungeness_CA <- Dungeness_2011to23 %>%
  filter(COUNTY_STATE == "CA")

# create a table with the sum of lbs landed for each CDFW BLOCK10 ID
CDFW_AREA_BLOCK_sum <- tapply(Dungeness_CA$LANDED_WEIGHT_LBS, Dungeness_CA$CDFW_AREA_BLOCK, sum)
head(CDFW_AREA_BLOCK_sum[order(-CDFW_AREA_BLOCK_sum)], 100)


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


# filter only spot prawn tickets
Spot_prawn <- fishtickets %>%
  filter(PACFIN_SPECIES_CODE == "SPRW")

# take a look at the spot prawn attribute structure
glimpse(Spot_prawn)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
SPRW_gear <- table(Spot_prawn$GEAR_NAME)
# more detailed tally (using DescTools) the number of tickets by PacFIN gear code to figure out which gear types to use
SPRW_gear <- Freq(Spot_prawn$GEAR_NAME, ord = "desc")

# Looking only at CA fish tickets from 2009 - 2023, with PARTICIPATION_GROUP_NAME	= NON-INDIAN COMMERCIAL FISHER
# REMOVAL_TYPE_NAME	= COMMERCIAL (NON-EFP), 97.51% of all SPRW tonnes landed and 93.48% of all tickets are from PRAWN TRAP, so only select those in master_process script

# save a tab delimited table
write_tsv(SPRW_gear, "Spot prawn gear type freq distribution 1994-2023.txt")




# filter only spot prawn tickets
Sable <- fishtickets %>%
  filter(PACFIN_SPECIES_CODE == "SABL")

# take a look at the spot prawn attribute structure
glimpse(Sable)

# tally the number of tickets by PacFIN gear code to figure out which gear types to use
SABL_gear <- table(Sable$GEAR_NAME)
# more detailed tally (using DescTools) the number of tickets by PacFIN gear code to figure out which gear types to use
SABL_gear <- Freq(Sable$GEAR_NAME, ord = "desc")

# ##.##% of all SABL tickets are from NAME(S), so only select those in master_process script

# save a tab delimited table
write_tsv(SABL_gear, "Sablefish gear type freq distribution 1994-2023.txt")






## Code from Kelly for selecting and filtering duplicate fish tickets in Pipeline intermediate output

library(tidyverse)

matched_alltix_withFTID_2017 <- readRDS("/Volumes/Thunderblade 4TB/VMS Pipeline/Pipeline run output raw file BACKUPS/CHNK and DCRB 28May2024/Confidential/processed/matched/matching/2017_matched_alltix_withFTID.rds")
View(matched_alltix_withFTID_2017)
length(unique(matched_alltix_withFTID_2017$FTID))
test <- matched_alltix_withFTID_2017 %>% filter(has_vms == 0)
length(unique(test$FTID))
test <- test %>% group_by(FTID) %>% mutate(no_ftids = n())
test <- test %>% filter(no_ftids > 1)
View(test)


## this-n-that

select_pipe <- filter(matched_alltix_withFTID_2017,
FTID == "Z993360" | 
FTID == "Z987035" |
FTID == "Z984953" |
FTID == "Z984738" |
FTID == "Z984725")

write.csv(select_pipe, here::here('Confidential', 'processed', 'pipeline output', 'DCRB and CHNK 28May2024', 'unmatched_pipeline_output_fish_tix_with_error_dupes_2017.csv'))

# create summary freq table for all the fish tickets in a given year that had VMS or didn't
fishtix_YEAR_by_VMS <- matched_alltix_withFTID_YEAR %>%
  group_by(FTID, has_vms) %>%
  summarize(Freq=n())

# create summary freq table for all the fish tickets by PACFIN_SPECIES_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, PACFIN_SPECIES_COMMON_NAME
COMBO_freq <- rawdat %>%
  group_by(PACFIN_SPECIES_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, PACFIN_SPECIES_COMMON_NAME) %>%
  summarize(Freq=n())

## create summary freq table for all the fish tickets in a VMS Pipeline run that had VMS or didn't and include fish ticket date
# append all of the YEAR_matched_alltix_withFTID files together and create summary freq table for all the fish tickets in a given year that had VMS or didn't
vms2011 <- read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2011.rds')
vms_all <- vms2011 %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2012.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2013.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2014.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2015.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2016.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2017.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2018.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2019.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2020.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2021.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2022.rds')) %>%
  bind_rows(read_rds('/Volumes/Thunderblade 4TB/Various large GIS files/Ecosystem_Sci/VMS Pipeline/Confidential/Pipeline run output raw file BACKUPS/SPRW_processed_2025-04-22/matched/matched_alltix_withFTID_2023.rds'))

# create summary freq table by grouping by FTID, date, has_vms
FTID_by_date_VMS <- vms_all %>%
  group_by(FTID, date, has_vms) %>%
  summarize(Freq=n())

# save .csv of FTID_by_date_VMS df
write.csv(FTID_by_date_VMS, 'Spot_prawn_FTIDs_by_date_lbs_and_VMS_status_2011-2023.csv')
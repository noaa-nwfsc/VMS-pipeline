#this script joins all fishticket data and calculates a target species for each FTID
#See the following pdf for description of all data: https://pacfin.psmfc.org/wp-content/uploads/2022/05/PacFIN_Comprehensive_Fish_Tickets.pdf

library(tidyverse)
library(lubridate)
library(sf)
library(janitor)
library(here)
library(glue)

####Joining all fishtickets

project <- "NCCOS_California_2024"

#bring in 2020's
pacfin_ft_2021_2023 <- read.csv(glue('{project}/Confidential/raw_data/PACFIN/raw_downloads_from_PacFIN/pacfin_ft_2021_2023.csv'))

#bring in 2010's
pacfin_ft_2011_2020 <- read.csv(glue('{project}/Confidential/raw_data/PACFIN/raw_downloads_from_PacFIN/pacfin_ft_2011_2020.csv'))

#compare field attributes
compare_df_cols(pacfin_ft_2021_2023, pacfin_ft_2011_2020, return = 'mismatch')

#modify field attributes so we can bind together
pacfin_ft_2011_2020 <- pacfin_ft_2011_2020 %>%
  mutate(GF_PERMIT_NUMBER = as.character(GF_PERMIT_NUMBER),
         TRIP_SEQ = as.integer(TRIP_SEQ))

#bind 2010's to 2020's
ft_1 <- pacfin_ft_2021_2023 %>%
  bind_rows(pacfin_ft_2011_2020)

#cleanup
rm(pacfin_ft_2021_2023, pacfin_ft_2011_2020)

#bring in 2000's
pacfin_ft_2001_2010 <- read.csv(glue('{project}/Confidential/raw_data/PACFIN/raw_downloads_from_PacFIN/pacfin_ft_2001_2010.csv'))

#compare field attributes
compare_df_cols(ft_1, pacfin_ft_2001_2010, return = 'mismatch')

#modify field attributes so we can bind together
pacfin_ft_2001_2010 <- pacfin_ft_2001_2010 %>%
  mutate(DEALER_NUM = as.character(DEALER_NUM),
         DECLARATION_CODES = as.character(DECLARATION_CODES),
         EFP_CODE = as.character(EFP_CODE),
         EFP_NAME = as.character(EFP_NAME),
         FIRST_RECEIVER_NUMBER = as.integer(FIRST_RECEIVER_NUMBER),
         GF_PERMIT_NUMBER = as.character(GF_PERMIT_NUMBER),
         HILLE_PERMIT = as.character(HILLE_PERMIT),
         IFQ_ACCOUNT_NUM = as.character(IFQ_ACCOUNT_NUM),
         IFQ_MANAGEMENT_AREA = as.character(IFQ_MANAGEMENT_AREA))

#bind 2000's to 2010's and 2020's
ft_2 <- ft_1 %>%
  bind_rows(pacfin_ft_2001_2010)

#cleanup
rm(ft_1, pacfin_ft_2001_2010)


#bring in 1990's
pacfin_ft_1991_2000 <- read.csv(glue('{project}/Confidential/raw_data/PACFIN/raw_downloads_from_PacFIN/pacfin_ft_1991_2000.csv'))

#compare field attributes
compare_df_cols(ft_2, pacfin_ft_1991_2000, return = 'mismatch')

#modify field attributes so we can bind together
pacfin_ft_1991_2000 <- pacfin_ft_1991_2000 %>%
  mutate(ACL_CODE = as.character(ACL_CODE),
         DEALER_NUM = as.character(DEALER_NUM),
         DECLARATION_CODES = as.character(DECLARATION_CODES),
         DECLARATION_TYPES = as.character(DECLARATION_TYPES),
         EFP_CODE = as.character(EFP_CODE),
         EFP_NAME = as.character(EFP_NAME),
         FIRST_RECEIVER_NUMBER = as.integer(FIRST_RECEIVER_NUMBER),
         FOS_GROUNDFISH_SECTOR_CODE = as.character(FOS_GROUNDFISH_SECTOR_CODE),
         GF_PERMIT_NUMBER = as.character(GF_PERMIT_NUMBER),
         HILLE_PERMIT = as.character(HILLE_PERMIT),
         HSFCA_PERMIT = as.character(HSFCA_PERMIT),
         IFQ_ACCOUNT_NUM = as.character(IFQ_ACCOUNT_NUM),
         IFQ_MANAGEMENT_AREA = as.character(IFQ_MANAGEMENT_AREA),
         IS_SABLEFISH_TIER = as.integer(IS_SABLEFISH_TIER),
         TICKET_SOURCE_CODE = as.character(TICKET_SOURCE_CODE),
         WCHMS_PERMIT = as.character(WCHMS_PERMIT)) %>%
  filter(PACFIN_YEAR > 1993) #limit to >1994 (beginning of limited entry fisheries)

#bind 1990's to 2000's, 2010's and 2020's
ft_3 <- ft_2 %>%
  bind_rows(pacfin_ft_1991_2000)

#cleanup
rm(ft_2, pacfin_ft_1991_2000)

saveRDS(ft_3, glue('{project}/Confidential/raw_data/PACFIN/all_fields_all_fishtickets_1994_2023.rds'))



#Calculate Target species for each FTID:
fts <- ft_3 %>%
dplyr::select(PACFIN_YEAR, LANDING_MONTH, VESSEL_NUM, VESSEL_ID, FISH_TICKET_ID, FTID, PACFIN_GROUP_PORT_CODE, IOPAC_PORT_GROUP, PACFIN_PORT_CODE, DEALER_ID, AGENCY_CODE, PACFIN_GROUP_GEAR_CODE, PACFIN_GEAR_CODE, GEAR_NAME, MANAGEMENT_GROUP_CODE, DANGELO_HMS_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, ROUND_WEIGHT_MTONS, EXVESSEL_REVENUE)
rm(ft_3)

#Adjust gear group codes for some uncategorized gears
fts %>%
  mutate(PACFIN_GROUP_GEAR_CODE=case_when(
    PACFIN_GROUP_GEAR_CODE=='MSC' & GEAR_NAME %in% c('SPEAR','DIVING - ABALONE IRON','DIVING - RAKE/HOOKS SEA URCHINS','DIVING', 'SHELLFISH DIVER') ~ 'DVG',
    PACFIN_GROUP_GEAR_CODE=='MSC' & GEAR_NAME %in% c('UNKNOWN','UNKNOWN OR UNSPECIFIED GEAR') ~ 'USP',
    PACFIN_GROUP_GEAR_CODE=='MSC' & GEAR_NAME %in% c('AQUACULTURE FARM','OYSTER FARM','CLAM FARM') ~ 'FRM',
    TRUE ~ PACFIN_GROUP_GEAR_CODE
  ))

#Concatenate all species information for the fish ticket.
all.species <- fts %>%
  group_by(FISH_TICKET_ID, PACFIN_GEAR_CODE) %>%
  summarise(species_code_all = ifelse(length(unique(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE)) > 1, paste(unique(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE), collapse="/"), as.character(unique(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE))))

#Concatenate the gear information for the fish ticket
gear.info <- fts %>%
  group_by(FISH_TICKET_ID) %>%
  summarise(GEAR_NAME_all = ifelse(length(unique(GEAR_NAME)) > 1, paste(unique(GEAR_NAME), collapse="/"), as.character(unique(GEAR_NAME))),
            PACFIN_GEAR_CODE_all = ifelse(length(unique(GEAR_NAME)) > 1, paste(unique(PACFIN_GEAR_CODE), collapse="/"), as.character(unique(PACFIN_GEAR_CODE))))


#### Find Target Species ####
# We need to define the target species for each landed ticket. We will do this by finding the species with the greatest landed weight and revenue for each fishticket.Right now, each row of the data is a landing amount for a particular gear/ticket/species combo. We want to collapse these tickets in order to just have one row for each ticket, with an associated amount of landings and revenue across all species.

fts.w.targets <- fts %>% 
  # Group by ticket, removal type, and species
  group_by(FISH_TICKET_ID, PACFIN_GROUP_GEAR_CODE, PACFIN_GEAR_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE) %>% 
  
  # calculate landed pounds and revenue by species
  summarise(spp_mts = sum(ROUND_WEIGHT_MTONS, na.rm = T),
            spp_revenue = sum(EXVESSEL_REVENUE, na.rm = T)) %>% 
  ungroup() %>% 
  
  # now, calculate total pounds per species across the entire ticket
  group_by(FISH_TICKET_ID, PACFIN_GROUP_GEAR_CODE, PACFIN_GEAR_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE) %>% 
  mutate(tot_mts_spp = sum(spp_mts, na.rm = T),
         tot_revenue_spp = sum(spp_revenue, na.rm = T)) %>% 
  ungroup() %>% 
  
  # using these species totals, calculate proportions of total catch belonging to each species
  # by mts landed and revenue
  group_by(FISH_TICKET_ID, PACFIN_GROUP_GEAR_CODE, PACFIN_GEAR_CODE) %>% 
  mutate(prop_mts_spp = tot_mts_spp/sum(tot_mts_spp, na.rm = T),
         prop_revenue_spp = tot_revenue_spp/sum(tot_revenue_spp, na.rm = T)) %>% 
  
  # finally, assign a TARGET to the trip, defined as the species with the
  # LARGEST proportion of revenue for that trip
  # If a species landed is not >1% more than the second species, target is NONE
  mutate(first_rev = dplyr::first(prop_revenue_spp,order_by = desc(prop_revenue_spp)),
         second_rev=dplyr::nth(prop_revenue_spp,n=2,order_by = desc(prop_revenue_spp)),
         first_rev_spp = dplyr::first(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE,order_by= desc(prop_revenue_spp)),
         second_rev_spp=dplyr::nth(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE,n=2,order_by= desc(prop_revenue_spp)),
         first_mts = dplyr::first(prop_mts_spp,order_by = desc(prop_mts_spp)),
         second_mts=dplyr::nth(prop_mts_spp,2,order_by = desc(prop_mts_spp)),
         first_mts_spp = dplyr::first(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE,order_by=desc(prop_mts_spp)),
         second_mts_spp=dplyr::nth(NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE,n=2,order_by= desc(prop_mts_spp))) %>% 
  
  # check if first is >1% more than second, for revenue and landed mts
  # or, if first and second species are the same (i.e. for a ticket with both commercial and personal use catch)
  # if so, assign that species as TARGET
  
  mutate(TARGET_rev = first_rev_spp,
         TARGET_mts = first_mts_spp,
         TARGET2_rev = second_rev_spp,
         TARGET2_mts = second_mts_spp) %>% 
  ungroup() %>% 
  select(-(first_rev:second_mts_spp))

# Add back in dates, vessel IDs, etc.##Added FTID in this list
recID_attributes <- fts %>% 
  select(PACFIN_YEAR, LANDING_MONTH, VESSEL_NUM, VESSEL_ID, FISH_TICKET_ID, FTID, PACFIN_GROUP_PORT_CODE, IOPAC_PORT_GROUP, PACFIN_PORT_CODE, DEALER_ID, AGENCY_CODE, PACFIN_GROUP_GEAR_CODE, PACFIN_GEAR_CODE, GEAR_NAME, MANAGEMENT_GROUP_CODE, DANGELO_HMS_CODE, NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE) %>%
  distinct()


fts.targets <- fts.w.targets %>%
  left_join(recID_attributes, by = c("FISH_TICKET_ID", "PACFIN_GROUP_GEAR_CODE", "PACFIN_GEAR_CODE", "NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE"))

# add all species and gear types for each ticket; multiple rows for each Fish_ticket_ID because we still have the data grouped by SPECIES_CODE in order to use the HPOUNDS and APOUNDS values to apportion landings/revenue across tows
fts.targets %<>%
  left_join(all.species) %>% 
  left_join(gear.info)

#save joined fishticket data
saveRDS(fts.targets, glue('{project}/Confidential/raw_data/PACFIN/targets_all_fishtickets_1994_2023.rds'))



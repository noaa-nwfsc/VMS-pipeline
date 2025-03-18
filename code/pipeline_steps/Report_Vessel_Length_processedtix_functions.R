


##############################################################################################################################
                                                         # CALCULATE MODE #
##############################################################################################################################
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}



##############################################################################################################################
                              # CALCULATE MEAN OF 2 MOST RECENT YEARS OF DATA #
##############################################################################################################################

get2yrmean <- function(x, years){
  library(dplyr)
  tmp_dat_frame <- data.frame("Year"=years, "Lengths" = x)
  #tmp_dat_frame <- tmp_dat_frame %>%
  #filter(!is.na(Lengths)) %>%
  #arrange(desc(Year))
  tmp_dat_sub <- tmp_dat_frame[1:2,]
  mean_length <- mean(tmp_dat_sub$Lengths)
  return(mean_length)
}



##############################################################################################################################
# DEFINE FUNCTION TO CALCULATE LENGTH FROM SUMMARY DATA FRAME - 5 YEAR OR ALL DATA #
##############################################################################################################################

get_historic_length <- function(tmp_vessel_info){
  ##### if only one unique vessel length was recorded
  if(tmp_vessel_info$n_unique == 1){
    #####-- if only 1 / all years contained vessel data
    if(tmp_vessel_info$n_lengths == 1){
      final_vessel_length <- tmp_vessel_info$max_length
      length_calc <- "unique_1"
    } 
    #####-- if 2 + years contained vessel data
    else{
      final_vessel_length <- tmp_vessel_info$max_length
      length_calc <- "unique_2up"
    }
  } 
  ##### if two unique vessel lengths were recorded
  else if(tmp_vessel_info$n_lengths == 2){
    #####-- if the max length is more than 2 * the min length
    if(tmp_vessel_info$max_length > 2*tmp_vessel_info$min_length){
      final_vessel_length <- NA
      length_calc <- "highSD"
    } 
    #####-- otherwise,
    else{
      final_vessel_length <- tmp_vessel_info$mode_length
      length_calc <- "mode"
    }
  } 
  
  #### if 3+ unique vessel lengths were recorded ####
  else{
    final_vessel_length <- tmp_vessel_info$med_length
    length_calc <- "median"
  }
  return(c(final_vessel_length, length_calc))
}



##############################################################################################################################
      # DEFINE FUNCTION TO CALCULATE LENGTH WHEN LOOPING OVER MULTIPLE YEARS OF FISH TICKET DATA #
##############################################################################################################################
calc_length <- function(permits, vesseldat, lengthdat, summarydat, index, y){
  ## subset vessel data for vessel_num / agency_code / registration_year for new vessel
  tmp_vessel <- vesseldat[index,]
  
  ## grab 3 year summary statistics for this vessel
  tmp_vessel_info <- left_join(tmp_vessel, summarydat, by=c("drvid"="VESSEL_NUM", "agency_code"="AGENCY_CODE"))
  
  ## if more than one vessel length was recorded in the past three years AND the max length was within 10ft of the min length ##
  if(!is.na(tmp_vessel_info$n_lengths) && tmp_vessel_info$n_lengths > 1 && tmp_vessel_info$max_length < (10+tmp_vessel_info$min_length)){
    warnmessage <- NA
    final_vessel_length <- tmp_vessel_info$mean2yr
    ### if the number of unique vessel lengths recorded was one, save 'type' as unique
    if(tmp_vessel_info$n_unique == 1){
      length_calc <- "unique"
      #cat(length_calc)
    } else{
      ### if more than two unique vessel lengths were recorded, save 'type' as 2yr mean
      length_calc <- "2yrmean"
    }
    #cat(length_calc)
  }
  
  ## one or no vessel lengths were recorded in the past three years OR the max length was more than 10ft larger than the min length ##
  else{
    #cat("calculating summarydat_5yr\n")
    ### find summary statistics for the most recent 5 years for this particular vessel
    target_reg_years <- seq(y-4,y)
    
    summarydat_5yr <- lengthdat %>%
      filter(VESSEL_NUM == tmp_vessel$drvid) %>%
      filter(AGENCY_CODE == tmp_vessel$agency_code) %>%
      filter(REGISTRATION_YEAR %in% target_reg_years) %>%
      filter(!is.na(VESSEL_LENGTH)) %>%
      group_by(VESSEL_NUM, AGENCY_CODE) %>%
      arrange(desc(REGISTRATION_YEAR)) %>%
      summarise(n_lengths = length(VESSEL_LENGTH),
                n_unique = length(unique(VESSEL_LENGTH)),
                max_length = max(VESSEL_LENGTH),
                min_length = min(VESSEL_LENGTH),
                mode_length = getmode(VESSEL_LENGTH),
                med_length = median(VESSEL_LENGTH))
    
    ### grab 5 year summary statistics for this vessel
    tmp_vessel_info <- left_join(tmp_vessel, summarydat_5yr, by=c("drvid"="VESSEL_NUM", "agency_code"="AGENCY_CODE"))
    
    ### if there are still no vessel lengths recorded ###
    if(is.na(tmp_vessel_info$n_lengths)){
      #### record "NA"
      final_vessel_length <- NA
      length_calc <- "none"
      #### determine whether lengths for this vessel were removed from the length filter, or whether the vessel number is missing from the permit data
      all_permits_length_filter <- lengthdat %>% filter(VESSEL_NUM == tmp_vessel_info$drvid) %>%
        filter(AGENCY_CODE == tmp_vessel_info$agency_code)
      all_permits <- permits %>% filter(VESSEL_NUM == tmp_vessel_info$drvid) %>%
        filter(AGENCY_CODE == tmp_vessel_info$agency_code)
      
      #### if lengths for this vessel exist, but are outside the 5 year lookback window ####
      if(length(all_permits_length_filter$VESSEL_NUM) > 0){
        warnmessage <- paste0("WARNING: Length for vessel ", tmp_vessel_info$drvid, " ", tmp_vessel_info$agency_code, " had to be calculated with data > 4 years prior to ", y)
        print(warnmessage)
        
        ## dealing with R's annoying object class assignment habit
        pthin_length_filter$VESSEL_NUM <- as.character(pthin_length_filter$VESSEL_NUM)
        pthin_length_filter$AGENCY_CODE <- as.character(pthin_length_filter$AGENCY_CODE)
        
        ## save all historic permit data for this vessel
        old_vessel_info <- pthin_length_filter %>%
          filter(VESSEL_NUM == tmp_vessel_info$drvid) %>%
          filter(AGENCY_CODE == tmp_vessel_info$agency_code) %>%
          filter(!is.na(VESSEL_LENGTH)) %>%
          arrange(desc(REGISTRATION_YEAR)) %>%
          summarise(n_lengths = length(VESSEL_LENGTH),
                    n_unique = length(unique(VESSEL_LENGTH)),
                    max_length = max(VESSEL_LENGTH),
                    min_length = min(VESSEL_LENGTH),
                    mode_length = getmode(VESSEL_LENGTH),
                    med_length = median(VESSEL_LENGTH))
        ## run through historic data decision tree (same as 5yr)
        olddat_output <- get_historic_length(tmp_vessel_info=old_vessel_info)
        final_vessel_length <- olddat_output[1]
        length_calc <- paste0("olddat_", olddat_output[2]) ## add "olddat" to type calc so we know which vessels have historical data
        tmp_vessel_info$n_unique <- old_vessel_info$n_unique
        tmp_vessel_info$n_lengths <- old_vessel_info$n_lengths
      }
      else if(length(all_permits_length_filter$VESSEL_NUM) == 0 & length(all_permits_length_filter$VESSEL_NUM) > 0){
        warnmessage <- paste0("ERROR: All Records for Vessel ", tmp_vessel_info$drvid, " ", tmp_vessel_info$agency_code, " Removed by Length Filter.")
      } 
      else if(length(all_permits_length_filter$VESSEL_NUM) == 0 & length(all_permits_length_filter$VESSEL_NUM) == 0){
        warnmessage <- paste0("ERROR: Vessel ", tmp_vessel_info$drvid, " ", tmp_vessel_info$agency_code, " COULD NOT BE FOUND IN PERMITS DATA BASE.")
      }
    } 
    
    ### if there were vessel lengths recorded ###
    else{
      warnmessage <- NA
      output_5yr <- get_historic_length(tmp_vessel_info = tmp_vessel_info)
      final_vessel_length <- output_5yr[1]
      length_calc <- output_5yr[2]
    } ###
  } ##
  if(is.na(warnmessage)){
    output_vec <- c(tmp_vessel_info$n_lengths, tmp_vessel_info$n_unique, final_vessel_length, length_calc)
  } else{
    output_vec <- c(tmp_vessel_info$n_lengths, tmp_vessel_info$n_unique, final_vessel_length, length_calc, warnmessage)
  }
  return(output_vec)
}

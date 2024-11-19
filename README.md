## Vessel Monitoring System data matched to fish ticket data
This repo contains code that matches VMS location data to fish ticket data in order to help identify fishing locations. Created by Kelly Andrews, February 2024.

# Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project content is provided on an "as is" basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.

# Purpose
This repository collates the code used to process Vessel Monitoring System (VMS) data and join it to PacFIN fishery landings (i.e., "fish ticket") data for the U.S. West Coast to produce spatial information on fishing activity. These outputs are useful for a wide array of applications in west coast fishery management, such as describing spatial fishing behavior and dynamics, assessing fisheries overlap with protected resources, and attributing drivers of change in west coast fisheries.

# Structure
The repository is structured into multiple required steps in the processing of VMS and fish ticket  data from raw inputs into useful outputs. This process has a number of steps, including multiple QA/QC steps. These steps are described in detail in the associated `.Rmd` files in the `process steps` folder. The scripts are organized hierarchically, wherein individual data processing steps have their own associated scripts, which are then knit into the overall process file. This is to facilitate editing of individual steps, while maintaining the overall framework in one document.

Most raw data in this project are large in size and confidential. This repository therefore does not include any raw data, but refers to these data using the relational command from the `here` package `here::here()`. Therefore, authorized users of the data that wish to run or utilize specific pieces of the workflow should obtain the relevant data from one of the moderators of this repository and place it in the `data` folder. Then, all of the code herein should run without needing to change any file path references.

# Pipeline Options

Each individual process step (i.e., Steps 01-06 in the `process steps` folder) contains descriptive details on the analytical choices in various steps of the pipeline. However, overall, the pipeline is designed to be general, and the number of choices to be made by the analyst are few. The key initial choices on data processing are contained in the beginning of the `main_process` file:

| Choice  | Parameter | Description |
| ---- | :-----: | ------- |
| Species  | `spp_codes`    | For which species ([PacFIN species codes](https://pacfin.psmfc.org/pacfin_pub/data_rpts_pub/code_lists/sp.txt)) do you want specific landings information (weight and value) NOTE: this does NOT filter which fish tickets are processed, but rather adds extra variables |
| Gear types | `gear_codes`  | similar to above, should be thought of NOT as a filter on which gears ([PacFIN gear codes](https://pacfin.psmfc.org/pacfin_pub/data_rpts_pub/code_lists/agency_gears.txt)) you get out of the pipeline, but rather as all of the gear types for which you would like total revenue and landings (e.g. "CRAB POT"), regardless of target species. |
| Target cutoff    | `target_cutoff` | Determines how the target species of each trip is calculated. For trips that land multiple species, how much "more important" does your target need to be than the species with the second greatest catch? Expressed as a ratio. |
| Revenue metric | `pacfin_revenue_metric` | Which PacFIN-reported revenue metric to use in calculation of landings |
| Weight metric | `pacfin_weight_metric` | Which PacFIN-reported weight metric to use in calculation of landings |
| Lookback window | `lookback_window` | What is the maximum allowed trip length to attach to a fish ticket (e.g., maximum allowed difference between first and last VMS pings associated with a trip) |

# Pipeline Outputs

The main output of this data analysis pipeline is clean fishery landings data, joined to the relevant spatial information (i.e., VMS-derived locations) associated with each fishing trip. As the pipeline runs, it produces various intermediate outputs along the way, which may be useful in and of themselves, but also for error checking and overall QA/QC:

| Output file name suffix | Description | VMS Pipeline Step | 
| -------- | ------- | :---: |
| `fishtix_withFTID` | Clean fish tickets, but with no auxiliary data attached | 1 |
| `vessel_length_key` | Matching key between vessel registration data and PacFIN vessel identifiers | 2 |
| `fishtix_vlengths_withFTID` | Fish tickets augmented with vessel lengths | 2 |
| `vms_clean` | Clean VMS data, Cropped to US EEZ,Bathymetry added and used to crop records on land | 3 |
| `matched_alltix_withFTID` | All fish tickets with VMS data attached for trips that matched. Binary variable (0 or 1) has_vms indicates whether a trip matched | 4 |
| `matched_vmstix_only_withFTID` | All fish tickets with VMS data attached; trips that did not match VMS are filtered out | 4 |
| `matched_unfiltered` | VMS-matched fish tickets, with indicator variables calculated to identify spatial outliers, indicate records in port, etc. | 5 |
| `matched_filtered_withFTID_length` | As above, but with filters applied based on indicator variables | 5 |
| `interpolated` | matched_filtered_withFTID_length, processed to regularize VMS ping interval | 6 |

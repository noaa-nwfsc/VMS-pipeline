# load library
library(here)

# copy and paste from main_process.Rmd
output_dir_name <- 'processed_2025-02-10'
spp_codes <- c("DCRB")
process_year <- 2014

# create output subdirectory, if doesn't yet exist
output_subdir <- here('Confidential', 'data', output_dir_name, 'markdowns')
if (!dir.exists(output_subdir)) dir.create(output_subdir)

# run this line of code after running main_process.Rmd, to move the knit document output html file from the code subdirectory to the processed data subdirectory
file.rename(from = here('code', 'pipeline_steps', 'main_process.html'),
            to = here('Confidential', 'data', output_dir_name, 'markdowns', paste0('main_process_', spp_codes, '_', process_year, '.html')))
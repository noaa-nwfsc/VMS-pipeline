# run this script after running main_process.Rmd, to move the knit document from `code` to `processed_data`
# this assumes that the most recent log file should be used to name the script

# load library
library(here)
library(readr)

# find most recent log file and read lines
log_files <- list.files(here('code', 'pipeline_steps', 'log'))
most_recent_log_file <- log_files[length(log_files)]

# find output directory name and process year from most recent log file
log_line_output_dir_name <- log_lines[which(startsWith(log_lines, "output_dir_name"))]
log_line_process_year    <- log_lines[which(startsWith(log_lines, "process_year"))]
output_dir_name <- strsplit(log_line_output_dir_name, split = " ")[[1]][2]
process_year    <- strsplit(log_process_year, split = " ")[[1]][2]

# create output subdirectory, if doesn't yet exist
output_subdir <- here('Confidential', 'processed_data', output_dir_name, 'markdowns')
if (!dir.exists(output_subdir)) dir.create(output_subdir)

# move file to output directory, and include process year in the name
file.rename(from = here('code', 'pipeline_steps', 'main_process.html'),
            to = here('Confidential', 'processed_data', output_dir_name, 'markdowns', paste0('main_process_', process_year, '.html')))
# remotes::install_github("muschellij2/SummarizedActigraphy")
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(here)
library(R.utils)


source(here::here("code/helper_functions.R"))

filename = here::here("data", "filenames.rds")
data = read_rds(filename)

full_file = here::here("data", "all_minute_data.rds")

if (!file.exists(full_file)) {
  all_data = vector(length = nrow(data),
                    mode = "list")
  for (ifile in seq(nrow(data))) {
    print(ifile)
    file = data$vm_file[ifile]
    rds_file = data$vm_rds[ifile]
    summary_file = data$summary_file[ifile]
    df = read_rds(rds_file)
    sdf = read_rds(summary_file)
    full_df = full_join(df, sdf)
    full_df$stub = sub("[.]rds*", "", basename(summary_file))
    all_data[[ifile]] = full_df
  }
  all_df = bind_rows(all_data)
  
  all_df %>% 
    select(-HEADER_TIME_STAMP, -stub) %>% 
    corrr::correlate()
  
  # should we do this?
  all_df = all_df %>% 
    filter(!is.na(`Vector Magnitude`))
  
  write_rds(all_df, full_file, compress = "xz")
}

# remotes::install_github("muschellij2/SummarizedActigraphy")
library(SummarizedActigraphy)
# remotes::install_github("THLfi/read.gt3x")
library(read.gt3x)
library(dplyr)
library(readxl)
library(tidyr)
library(readr)
library(lubridate)
library(MIMSunit)

data_dir = here::here("data")
source(here::here("code/helper_functions.R"))

filename = here::here("data", "filenames.rds")
data = read_rds(filename)

for (iid in seq(nrow(data))) {
  
  print(iid)
  idf = data[iid, ]
  
  acc = read_actigraphy(idf$outfile, verbose = FALSE)
  df = acc$data.out
  dates = acc$header %>% 
    filter(Field %in% c("Start Date", "Stop Date"))
  rm(acc)
  df = df %>% 
    rename(HEADER_TIME_STAMP = time) %>% 
    select(HEADER_TIME_STAMP, X, Y, Z)
  
  if (nrow(dates) > 0) {
    dates = dates%>% 
      mutate(Value = as_datetime(Value)) %>% 
      pull(Value)
    dates = range(dates)
    rdates = range(df$HEADER_TIME_STAMP)
    if (max(difftime(rdates, dates, units = "mins")) >= 60) {
      message(paste0(idf$outfile, " is off on dates"))
    }
  } else {
    stop("NO dates!")
  }
  
  
}

rm(list=ls())
library(SummarizedActigraphy)
library(read.gt3x)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

xyz = c("X", "Y", "Z")

outfile = here::here("data", "file_info_with_metadata.rds")
df = readr::read_rds(outfile)

outfile = here::here("data", "csv_file_info.rds")
csv_df = readr::read_rds(outfile)

csv_df = csv_df %>%
  select(download_url, file, id, serial, group, outfile) %>% 
  tibble::as_tibble()


iid = sample(nrow(df), 1)
# iid = 13
# iid = 42
# for (iid in 43:nrow(df)) {
for (iid in seq(nrow(df))) {
  print(iid)
  idf = df[iid, ]
  idf_csv = csv_df %>% 
    filter(id %in% idf$id, serial %in% idf$serial)
  stopifnot(nrow(idf_csv) == 1)
  print(idf$id)
  gt3x_file = idf$outfile
  csv_file = idf_csv$outfile
  
  # check_data = function(gt3x_file, csv_file) {
  
  if (!file.exists(gt3x_file)) {
    out = curl::curl_download(idf$download_url, destfile = gt3x_file)
  }
  if (!file.exists(csv_file)) {
    csv_file = tempfile(fileext = ".csv.gz")
    out = curl::curl_download(idf_csv$download_url, destfile = csv_file)
  }
  
  csv = read_acc_csv(csv_file)
  csv_hdr = csv$parsed_header
  csv = tibble::as_tibble(csv$data)
  csv = csv[, c("time", xyz)]
  
  acc = read_actigraphy(gt3x_file, verbose = FALSE)
  head(acc$data.out)
  acc$freq # sample rate
  acc$header
  
  acc_hdr = acc$header
  acc = tibble::as_tibble(acc$data.out)
  acc = acc[, c("time", xyz)]
  
  stopifnot(nrow(csv) == nrow(acc))
  
  rs_csv = rowSums(csv[,xyz] == 0) == 3
  rs_acc = rowSums(acc[,xyz] == 0) == 3
  if (any(rs_csv)) {
    message("ZEROS in CSV file!!!")
    csv = fix_zeros(csv)
    rs_csv = rowSums(csv[,xyz] == 0) == 3
  }
  stopifnot(sum(rs_csv) == 0)
  
  acc = fix_zeros(acc)
  
  stopifnot(all(acc[,xyz] == csv[,xyz]))
  
  # }
  rm(acc)
  rm(csv_file)
  
}

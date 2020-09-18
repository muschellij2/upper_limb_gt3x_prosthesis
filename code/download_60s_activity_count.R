# remotes::install_github("muschellij2/SummarizedActigraphy")
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(here)
library(rfigshare)
library(R.utils)


source(here::here("code/helper_functions.R"))

token_file = here::here("fs_token.rds")
if (file.exists(token_file)) {
  token = readr::read_rds(token_file)
  assign("oauth", token, envir = rfigshare:::FigshareAuthCache)
}

filename = here::here("data", "filenames.rds")
data = read_rds(filename)
data_dir = here::here("data")

data = data %>% 
  mutate(vm_base = basename(vm_file))

if (!all(file.exists(data$vm_file))) {
  # this is the 60s vector magnitude
  x = rfigshare::fs_details("7946174")
  files = x$files
  stopifnot(length(files) == 1)
  files = files[[1]]
  download_url = files[["download_url"]]
  ext = paste0(".", tools::file_ext(files$name))
  outfile = tempfile(fileext = ext)
  
  if (!file.exists(outfile)) {
    out = curl::curl_download(download_url, destfile = outfile)
    csv_files = unzip(out, exdir = tempdir(), 
                      junkpaths = TRUE)
    outfiles = basename(csv_files)
    outfiles = sub("\\(", "", outfiles)
    outfiles = sub("\\)", "", outfiles)
    outfiles = gsub(" ", "_", outfiles)
    outfiles = sub("60secDataTable[.]csv", "_60sVM.csv.gz",
                   outfiles)
    out_df = data.frame(
      csv_file = csv_files,
      vm_base = outfiles,
      stringsAsFactors = FALSE
    )
    stopifnot(all(out_df$vm_base %in% data$vm_base))
    out_df = left_join(
      out_df, 
      data %>% select(vm_base, vm_file))
    x = mapply(function(filename, destname) {
      R.utils::gzip(filename, destname,
                    compression = 9,
                    remove = FALSE,
                    overwrite = TRUE) 
      invisible(NULL)
    }, out_df$csv_file, out_df$vm_file)
    stopifnot(all(file.exists(data$vm_file)))
  }
} 

for (ifile in seq(nrow(data))) {
  print(ifile)
  file = data$vm_file[ifile]
  rds_file = data$vm_rds[ifile]
  summary_file = data$summary_file[ifile]
  if (!file.exists(rds_file)) {    
    df = read_acc_csv(file)
    quick_check(df$data)
    df = df$data 
    df = df %>% 
      select(HEADER_TIME_STAMP, Steps, `Vector Magnitude`)
    write_rds(df, rds_file, compress = "xz")
  } 
}





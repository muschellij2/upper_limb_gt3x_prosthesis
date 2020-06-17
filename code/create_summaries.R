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

iid = 1 
idf = data[iid, ]

summary_file = idf$summary_file  

if (!file.exists(idf$outfile)) {
  dir.create(dirname(idf$outfile), showWarnings = FALSE,
             recursive = TRUE)
  out = curl::curl_download(idf$download_url, destfile = idf$outfile)
}
acc = read_actigraphy(idf$outfile, verbose = TRUE)
head(acc$data.out)
options(digits.secs = 2)
head(acc$data.out)
acc$freq
acc$header
acc$header %>% 
  filter(Field %in% c("Sex", "Age", "Side"))
idf[, c("Gender", "Age")]


df = acc$data.out
df = df %>% 
  rename(HEADER_TIME_STAMP = time) %>% 
  select(HEADER_TIME_STAMP, X, Y, Z)
df = fix_zeros(df)

hdr = acc$header %>% 
  filter(Field %in% c("Acceleration Min", "Acceleration Max")) %>% 
  mutate(Value = as.numeric(Value))
dynamic_range = range(hdr$Value)
if (all(is.na(dynamic_range))) {
  dynamic_range = c(-6, 6)
}

rm(acc)

measures = calculate_measures(df,
  dynamic_range = dynamic_range
)

## ----setup, include=FALSE-----------------------------------------------
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, comment = "")


## ----packages-----------------------------------------------------------
# remotes::install_github("muschellij2/SummarizedActigraphy")
library(SummarizedActigraphy)
# remotes::install_github("THLfi/read.gt3x")
library(read.gt3x)
library(dplyr)
library(readxl)
library(tidyr)
library(readr)
library(lubridate)
library(kableExtra)
library(corrr)


## ----auth, include=FALSE------------------------------------------------
token_file = here::here("fs_token.rds")
if (file.exists(token_file)) {
  token = readr::read_rds(token_file)
  assign("oauth", token, envir = rfigshare:::FigshareAuthCache)
}


## ---- echo = TRUE, eval = FALSE-----------------------------------------
## data_dir = tempdir()


## ---- eval = TRUE, echo = FALSE-----------------------------------------
data_dir = here::here("data")


## ----get_fs_data--------------------------------------------------------
outfile = here::here("data", "file_info.rds")
if (file.exists(token_file) && !file.exists(outfile)) {
  x = rfigshare::fs_details("11916087")
  
  files = x$files
  files = lapply(files, function(x) {
    as.data.frame(x[c("download_url", "name", "id", "size")],
                  stringsAsFactors = FALSE)
  })
  all_files = dplyr::bind_rows(files)
  readr::write_rds(all_files, outfile)
} else {
  all_files = readr::read_rds(outfile)
}
meta = all_files %>% 
  filter(grepl("Meta", name))
df = all_files %>% 
  filter(grepl("gt3x", name))
df %>% 
  head %>% 
  knitr::kable() %>% 
  kableExtra::kable_styling()


## ----filedf-------------------------------------------------------------
df = df %>% 
  rename(file = name) %>% 
  tidyr::separate(file, into = c("id", "serial", "date"), sep = "_",
                  remove = FALSE) %>% 
  mutate(date = sub(".gt3x.*", "", date)) %>% 
  mutate(date = lubridate::ymd(date)) %>% 
  mutate(group = ifelse(grepl("^PU", basename(file)), 
                        "group_with_prosthesis",
                        "group_without_prosthesis")) %>% 
  mutate(article_id = basename(download_url)) %>% 
  mutate(outfile = file.path(data_dir, group, basename(file)))
df %>% 
  head() %>% 
  knitr::kable() %>% 
  kableExtra::kable_styling()


## ----meta---------------------------------------------------------------
metadata = file.path(data_dir, "Metadata.xlsx")
if (!file.exists(metadata)) {
  out = download.file(meta$download_url, destfile = metadata)
}
meta = readxl::read_excel(metadata)
bad_col = grepl("^\\.\\.", colnames(meta))
colnames(meta)[bad_col] = NA
potential_headers = rbind(colnames(meta), meta[1:2, ])
potential_headers = apply(potential_headers, 2, function(x) {
  x = paste(na.omit(x), collapse = "")
  x = sub(" .csv", ".csv", x)
  x = sub(" .wav", ".wav", x)
  x = gsub(" ", "_", x)
  x
})
colnames(meta) = potential_headers
meta = meta[-c(1:2),]
meta = meta %>% 
  rename(id = Participant_Identifier)
meta = meta %>% 
  filter(!is.na(id),
         id != "Participant Identifier") %>% 
  mutate_all(.funs = function(x) gsub("ü", "yes", x))
meta = meta %>% 
  mutate_at(
    .vars = vars(
      Age,
      `Time_since_prescription_of_a_myoelectric_prosthesis_(years)`
    ),
    readr::parse_number
  ) 
meta = meta %>% 
  mutate( `Time_since_limb_loss_(years)` = ifelse(
    `Time_since_limb_loss_(years)` == "Congenital", 0,
    `Time_since_limb_loss_(years)`)
  )
meta %>% 
  head %>% 
  knitr::kable() %>% 
  kableExtra::kable_styling()


## ----merge--------------------------------------------------------------
data = full_join(meta, df)


## ----readin-------------------------------------------------------------
iid = sample(nrow(df), 1)
idf = df[iid, ]
if (!file.exists(idf$outfile)) {
  out = curl::curl_download(idf$download_url, destfile = idf$outfile)
}
# acc = read.gt3x(idf$outfile, verbose = FALSE, 
#                 asDataFrame = TRUE, imputeZeroes = TRUE)
acc = read_actigraphy(idf$outfile, verbose = FALSE)
head(acc$data.out)
options(digits.secs = 2)
head(acc$data.out)
acc$freq


## ----sample_size, dependson="readin"------------------------------------
res = acc$data.out %>% 
  mutate(dt = floor_date(time, "seconds")) %>% 
  group_by(dt) %>% 
  count()
table(res$n)


## ----p_diff, dependson="readin"-----------------------------------------
library(ggplot2)
res = acc$data.out %>% 
  mutate(day = floor_date(time, "day"),
         time = hms::as_hms(time)) %>% 
  mutate(day = difftime(day, day[1], units = "days")) 
res = res %>%
  filter(day == 1)
res = res %>% 
  filter(between(time, 
                 hms::as_hms("10:00:00"),
                 hms::as_hms("10:30:00"))
         ) 
res = res %>% 
  tidyr::gather(key = direction, value = accel, -time, -day)

res %>%
  ggplot(aes(x = time, y = accel, colour = direction)) +
  geom_line() +
  theme(
  legend.background = element_rect(
    fill = "transparent"),
  legend.position = c(0.5, 0.9),
  legend.direction = "horizontal",
  legend.key = element_rect(fill = "transparent", 
                            color = "transparent") ) 
  


## -----------------------------------------------------------------------
check_zeros = function(df) {
  any(rowSums(df[, c("X", "Y", "Z")] == 0) == 3)
}
fix_zeros = function(df, fill_in = TRUE) {
  zero = rowSums(df[, c("X", "Y", "Z")] == 0) == 3
  names(zero) = NULL
  df$X[zero] = NA
  df$Y[zero] = NA
  df$Z[zero] = NA
  if (fill_in) {
    df$X = zoo::na.locf(df$X, na.rm = FALSE)
    df$Y = zoo::na.locf(df$Y, na.rm = FALSE)
    df$Z = zoo::na.locf(df$Z, na.rm = FALSE)
    
    df$X[ is.na(df$X)] = 0
    df$Y[ is.na(df$Y)] = 0
    df$Z[ is.na(df$Z)] = 0
  }
  df
}


## ----header-------------------------------------------------------------
acc$header
acc$header %>% 
  filter(Field %in% c("Sex", "Age", "Side"))
data[iid, c("Gender", "Age")]


## ----create_functions---------------------------------------------------
calculate_ai = function(df, unit = "1 min") {
  sec_df = df %>% 
    mutate(
      HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, "1 sec")) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      AI = sqrt((var(X) + var(Y) + var(Z))/3),
    )
  sec_df %>% mutate(
    HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, unit)) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      AI = sum(AI)
    )
}

calculate_mad = function(df, unit = "1 min") {
  df %>% 
    mutate(         
      r = sqrt(X^2+Y^2+Z^2),
      HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, unit)) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      SD = sd(r),
      MAD = mean(abs(r - mean(r))),
      MEDAD = median(abs(r - mean(r)))
    )
}

calculate_measures = function(df, unit = "1 min") {
  ai0 = calculate_ai(df, unit = unit)
  mad = calculate_mad(df, unit = unit)
  res = full_join(ai0, mad)
  res
}



## ----zeroes-------------------------------------------------------------
df = acc$data.out
df = df %>% 
  rename(HEADER_TIME_STAMP = time) %>% 
  select(HEADER_TIME_STAMP, X, Y, Z)
zero_rows = rowSums(df[, c("X", "Y", "Z")] == 0) == 3
any(zero_rows)
ind = unname(which(zero_rows))
ind = head(ind)
ind = c(min(ind) - (1:5), ind)
as.data.frame(df[ind,])
df = fix_zeros(df)
as.data.frame(df[ind,])


## ----make_measures, dependson="zeroes"----------------------------------
system.time({measures = calculate_measures(df)})


## ----MIMS, dependson="zeroes"-------------------------------------------
library(MIMSunit)
hdr = acc$header %>% 
  filter(Field %in% c("Acceleration Min", "Acceleration Max")) %>% 
  mutate(Value = as.numeric(Value))
dynamic_range = range(hdr$Value)
system.time({
  mims = df %>% 
    mims_unit(epoch = "1 min", 
              dynamic_range = dynamic_range)
})
measures = full_join(measures, mims)


## ----corr, dependson="zeroes"-------------------------------------------
library(corrr)
measures %>% 
  select(-HEADER_TIME_STAMP) %>% 
  correlate() %>% 
  stretch(remove.dups = TRUE, na.rm = TRUE) %>% 
  arrange(desc(r))


## ----avg----------------------------------------------------------------
to_minute = function(x) {
  x = format(x, "%H:%M:%S")
  x = hms::as_hms(x)
  x
}
average_day = measures %>% 
  mutate(HEADER_TIME_STAMP = to_minute(HEADER_TIME_STAMP)) %>% 
  group_by(HEADER_TIME_STAMP) %>% 
  summarise_at(vars(AI, SD, MAD, MEDAD), mean, na.rm = TRUE)
average_day %>%
  ggplot(aes(x = HEADER_TIME_STAMP, y = AI)) +
  geom_line()

average_day %>%
  ggplot(aes(x = HEADER_TIME_STAMP, y = MAD)) +
  geom_line()


## ----make1440-----------------------------------------------------------
measures1440 = measures %>% 
  select(HEADER_TIME_STAMP, AI) %>% 
  mutate(
    date = lubridate::as_date(HEADER_TIME_STAMP),
    HEADER_TIME_STAMP = to_minute(HEADER_TIME_STAMP)) %>% 
  mutate(HEADER_TIME_STAMP = sprintf("MIN_%04.0f", as.numeric(HEADER_TIME_STAMP)/60)) %>% 
  spread(HEADER_TIME_STAMP, value = AI)
head(measures1440)


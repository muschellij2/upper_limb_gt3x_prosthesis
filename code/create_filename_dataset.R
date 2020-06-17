library(SummarizedActigraphy)
library(dplyr)
library(readxl)
library(tidyr)
library(readr)
library(lubridate)


token_file = here::here("fs_token.rds")
if (file.exists(token_file)) {
  token = readr::read_rds(token_file)
  assign("oauth", token, envir = rfigshare:::FigshareAuthCache)
}
data_dir = here::here("data")

outfile = here::here("data", "file_info.rds")
if (
  (file.exists(token_file) && !file.exists(outfile)) ||
  !file.exists(token_file)) {
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

data = full_join(meta, df)

data = data %>% 
  mutate(
    summary_file = here::here("data", "summaries", 
                              sub("[.]gt3x.*", ".rds", file)))

write_rds(data, here::here("data", "filenames.rds"))

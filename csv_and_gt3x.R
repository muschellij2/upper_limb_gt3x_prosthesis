library(dplyr)
library(tidyr)
library(rfigshare)
library(read.gt3x)
# token_file = here::here("fs_token.rds")
# if (file.exists(token_file)) {
#   token = readr::read_rds(token_file)
#   assign("oauth", token, envir = rfigshare:::FigshareAuthCache)
# }
# 
# if (!"oauth" %in% names(rfigshare:::FigshareAuthCache)) {
#   rfigshare::fs_auth()
# }

make_df = function(article_id) {
  rfigshare::fs_auth
  x = rfigshare::fs_details(article_id = article_id, mine = FALSE,
                            session = NULL)
  files = x$files
  files = lapply(files, function(x) {
    as.data.frame(x[c("download_url", "name", "id", "size")],
                  stringsAsFactors = FALSE)
  })
  all_files = dplyr::bind_rows(files)
  all_files = all_files %>% 
    dplyr::filter(grepl("csv|gt3x", name)) %>% 
    tidyr::separate(name, into= c("id", "serial", "date"),
                    sep = "_", remove = FALSE) 
  all_files = all_files %>% 
    dplyr::mutate(
      group = gsub("\\d*", "", id),
      number = as.numeric(sub("AI|PU", "", id))
    ) %>% 
    dplyr::arrange(group, number) %>% 
    tibble::as_tibble()
}
gt3x = make_df("11916087") %>% 
  dplyr::select(name, download_url, id, serial)
csv = make_df("12883463") %>% 
  dplyr::select(name, download_url, id, serial)

df = dplyr::full_join(
  gt3x, csv, 
  by = c("id", "serial"),
  suffix = c("_gt3x", "_csv"))
stopifnot(nrow(df) == nrow(gt3x))
stopifnot(nrow(df) == nrow(csv))
nrow(csv)



# remotes::install_github("muschellij2/SummarizedActigraphy")
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(here)
library(mgcv)


filename = here::here("data", "filenames.rds")
data = read_rds(filename)

full_file = here::here("data", "all_minute_data.rds")

data = read_rds(full_file) %>% 
  rename(vectormagnitude = `Vector Magnitude`)


data = data %>% 
  mutate(MIMS_UNIT = ifelse(MIMS_UNIT < 0, 0, MIMS_UNIT),
         # MIMS_UNIT = round(MIMS_UNIT, 1),
         vectormagnitude = round(vectormagnitude, 1)) 

pred_df = data.frame(vectormagnitude = c(100, 1853, 1952, 2690))


mod = gam(MIMS_UNIT ~ s(vectormagnitude, bs = "cr"), data = data)

predict(mod, newdata = pred_df)

mod_over0 = gam(MIMS_UNIT ~ s(vectormagnitude, bs = "cr"), 
                data = data %>% 
                  filter(vectormagnitude > 0))
predict(mod_over0, newdata = pred_df)



mod = gam(AI ~ s(vectormagnitude, bs = "cr"), data = data)

predict(mod, newdata = pred_df)

mod_over0 = gam(AI ~ s(vectormagnitude, bs = "cr"), 
                data = data %>% 
                  filter(vectormagnitude > 0))
predict(mod_over0, newdata = pred_df)



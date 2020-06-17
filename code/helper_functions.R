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

calculate_ai = function(df, epoch = "1 min") {
  sec_df = df %>% 
    mutate(
      HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, 
                                                "1 sec")) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      AI = sqrt((var(X) + var(Y) + var(Z))/3),
    )
  sec_df %>% mutate(
    HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, 
                                              epoch)) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      AI = sum(AI)
    )
}

calculate_mad = function(df, epoch = "1 min") {
  df %>% 
    mutate(  
      r = sqrt(X^2+Y^2+Z^2),
      HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, 
                                                epoch)) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      SD = sd(r),
      MAD = mean(abs(r - mean(r))),
      MEDAD = median(abs(r - mean(r)))
    )
}


calculate_mims = function(
  df, 
  epoch = "1 min",
  dynamic_range = c(-6, 6)) {
  MIMSunit::mims_unit(
    df,
    epoch = "1 min", 
    dynamic_range = dynamic_range)
}


calculate_measures = function(
  df, epoch = "1 min",
  dynamic_range = c(-6, 6),
  verbose = TRUE) {
  if (verbose) {
    message("Calculating ai0")
  }
  ai0 = calculate_ai(df, epoch = epoch)
  if (verbose) {
    message("Calculating MAD")
  }
  mad = calculate_mad(df, epoch = epoch)
  if (verbose) {
    message("Calculating MIMS")
  }
  mims = calculate_mims(df, epoch = epoch, 
                        dynamic_range = dynamic_range)
  if (verbose) {
    message("Joining")
  }
  res = full_join(ai0, mad)
  res = full_join(res, mims)
  res
}


ticks2datetime = function (ticks, tz = "GMT") 
{
  ticks <- as.numeric(ticks)
  seconds <- ticks/1e+07
  datetime <- as.POSIXct(seconds, origin = "0001-01-01", tz = tz)
  datetime
}

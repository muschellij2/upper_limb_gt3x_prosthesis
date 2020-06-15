---
title: "Analysis of Raw GT3X files to Summary Measures in Chadwell et. al Data"
author: "John Muschelli"
date: '2020-06-15'
output: 
  html_document:
    keep_md: true
    theme: cosmo
    toc: true
    toc_depth: 3
    toc_float:
      collapsed: false
    number_sections: true
bibliography: refs.bib      
---

All code for this document is located at [here](https://raw.githubusercontent.com/muschellij2/osler/master/gt3x_limb_data/index.R).




```r
library(SummarizedActigraphy)
library(read.gt3x)
library(dplyr)
```

```

Attaching package: 'dplyr'
```

```
The following objects are masked from 'package:stats':

    filter, lag
```

```
The following objects are masked from 'package:base':

    intersect, setdiff, setequal, union
```

```r
library(readxl)
library(tidyr)
library(readr)
library(lubridate)
```

```

Attaching package: 'lubridate'
```

```
The following objects are masked from 'package:base':

    date, intersect, setdiff, union
```

```r
library(kableExtra)
```

```

Attaching package: 'kableExtra'
```

```
The following object is masked from 'package:dplyr':

    group_rows
```

```r
library(corrr)
```

# Data

The data is from @chadwell_kenney_granat_thies_galpin_head_2019.  The figshare project for this data is located at https://springernature.figshare.com/collections/Upper_limb_activity_of_twenty_myoelectric_prosthesis_users_and_twenty_healthy_anatomically_intact_adults_/4457855. The gt3x data is located at https://springernature.figshare.com/articles/Unprocessed_raw_30Hz_acceleration_data_stored_as_gt3x/7946189.  

The whole data can be downloaded from [Figshare](https://springernature.figshare.com/articles/Unprocessed_raw_30Hz_acceleration_data_stored_as_gt3x/7946189) directly or can be downloaded for each gt3x file from the [Duplicated Data Figshare]().

## Data Description

The data consists of 40 subjects, 20 with prostheses, 20 without.  Each wore tri-axial Actigraph watches for 7 days, one on each hand.  The metadata/demographics is located at [Demog Figshare]()




```r
data_dir = tempdir()
```




```r
x = rfigshare::fs_details("11916087")
```

```
No encoding supplied: defaulting to UTF-8.
No encoding supplied: defaulting to UTF-8.
```

```r
files = x$files
files = lapply(files, function(x) {
  as.data.frame(x[c("download_url", "name", "id", "size")],
                stringsAsFactors = FALSE)
})
all_files = dplyr::bind_rows(files)
meta = all_files %>% 
  filter(grepl("Meta", name))
df = all_files %>% 
  filter(grepl("gt3x", name))
df %>% knitr::kable() %>% head()
```

```
[1] "<table>\n <thead>\n  <tr>\n   <th style=\"text-align:left;\"> download_url </th>\n   <th style=\"text-align:left;\"> name </th>\n   <th style=\"text-align:right;\"> id </th>\n   <th style=\"text-align:left;\"> size </th>\n  </tr>\n </thead>\n<tbody>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855555 </td>\n   <td style=\"text-align:left;\"> AI1_NEO1B41100255_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855555 </td>\n   <td style=\"text-align:left;\"> 33.59 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855558 </td>\n   <td style=\"text-align:left;\"> AI1_NEO1F09120035_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855558 </td>\n   <td style=\"text-align:left;\"> 36.04 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855561 </td>\n   <td style=\"text-align:left;\"> AI2_NEO1B41100262_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855561 </td>\n   <td style=\"text-align:left;\"> 39.84 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855564 </td>\n   <td style=\"text-align:left;\"> AI2_NEO1F16120038_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855564 </td>\n   <td style=\"text-align:left;\"> 41.67 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855567 </td>\n   <td style=\"text-align:left;\"> AI3_CLE2B21130054_2017-06-02.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855567 </td>\n   <td style=\"text-align:left;\"> 46.45 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855573 </td>\n   <td style=\"text-align:left;\"> AI3_CLE2B21130055_2017-06-02.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855573 </td>\n   <td style=\"text-align:left;\"> 44.68 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855576 </td>\n   <td style=\"text-align:left;\"> AI4_MOS2D09170393_2017-06-06.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855576 </td>\n   <td style=\"text-align:left;\"> 36.13 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855582 </td>\n   <td style=\"text-align:left;\"> AI4_MOS2D09170398_2017-06-06.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855582 </td>\n   <td style=\"text-align:left;\"> 36.47 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855588 </td>\n   <td style=\"text-align:left;\"> AI5_NEO1B41100262_2017-06-13.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855588 </td>\n   <td style=\"text-align:left;\"> 33.70 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855591 </td>\n   <td style=\"text-align:left;\"> AI5_NEO1F16120038_2017-06-13.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855591 </td>\n   <td style=\"text-align:left;\"> 32.65 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855639 </td>\n   <td style=\"text-align:left;\"> AI6_NEO1B41100255_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855639 </td>\n   <td style=\"text-align:left;\"> 44.02 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855642 </td>\n   <td style=\"text-align:left;\"> AI6_NEO1F16120039_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855642 </td>\n   <td style=\"text-align:left;\"> 35.96 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855645 </td>\n   <td style=\"text-align:left;\"> AI7_MOS2D09170393_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855645 </td>\n   <td style=\"text-align:left;\"> 39.66 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855648 </td>\n   <td style=\"text-align:left;\"> AI7_MOS2D09170398_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855648 </td>\n   <td style=\"text-align:left;\"> 38.59 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855651 </td>\n   <td style=\"text-align:left;\"> AI8_CLE2B21130054_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855651 </td>\n   <td style=\"text-align:left;\"> 33.83 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855654 </td>\n   <td style=\"text-align:left;\"> AI8_CLE2B21130055_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855654 </td>\n   <td style=\"text-align:left;\"> 33.84 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855657 </td>\n   <td style=\"text-align:left;\"> AI9_NEO1B41100255_2017-06-27.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855657 </td>\n   <td style=\"text-align:left;\"> 36.65 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855660 </td>\n   <td style=\"text-align:left;\"> AI9_NEO1F16120039_2017-06-27.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855660 </td>\n   <td style=\"text-align:left;\"> 33.61 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855663 </td>\n   <td style=\"text-align:left;\"> AI10_CLE2B21130054_2017-07-05.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855663 </td>\n   <td style=\"text-align:left;\"> 38.40 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855666 </td>\n   <td style=\"text-align:left;\"> AI10_CLE2B21130055_2017-07-05.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855666 </td>\n   <td style=\"text-align:left;\"> 36.25 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855669 </td>\n   <td style=\"text-align:left;\"> AI11_MOS2D09170393_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855669 </td>\n   <td style=\"text-align:left;\"> 35.82 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855672 </td>\n   <td style=\"text-align:left;\"> AI11_MOS2D09170398_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855672 </td>\n   <td style=\"text-align:left;\"> 35.21 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855675 </td>\n   <td style=\"text-align:left;\"> AI12_NEO1F09120034_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855675 </td>\n   <td style=\"text-align:left;\"> 38.94 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855678 </td>\n   <td style=\"text-align:left;\"> AI12_NEO1F09120035_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855678 </td>\n   <td style=\"text-align:left;\"> 37.06 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855681 </td>\n   <td style=\"text-align:left;\"> AI13_CLE2B21130054_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855681 </td>\n   <td style=\"text-align:left;\"> 43.46 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855684 </td>\n   <td style=\"text-align:left;\"> AI13_CLE2B21130055_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855684 </td>\n   <td style=\"text-align:left;\"> 44.94 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855687 </td>\n   <td style=\"text-align:left;\"> AI14_NEO1F16120038_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855687 </td>\n   <td style=\"text-align:left;\"> 41.77 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855690 </td>\n   <td style=\"text-align:left;\"> AI14_NEO1F16120039_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855690 </td>\n   <td style=\"text-align:left;\"> 41.24 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855693 </td>\n   <td style=\"text-align:left;\"> AI15_MOS2D09170393_2017-10-30.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855693 </td>\n   <td style=\"text-align:left;\"> 27.94 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855696 </td>\n   <td style=\"text-align:left;\"> AI15_MOS2D09170398_2017-10-30.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855696 </td>\n   <td style=\"text-align:left;\"> 26.89 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855753 </td>\n   <td style=\"text-align:left;\"> AI16_MOS2D20170459_2017-11-08.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855753 </td>\n   <td style=\"text-align:left;\"> 33.53 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855762 </td>\n   <td style=\"text-align:left;\"> AI16_MOS2D20170460_2017-11-08.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855762 </td>\n   <td style=\"text-align:left;\"> 32.87 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855765 </td>\n   <td style=\"text-align:left;\"> AI17_CLE2B21130054_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855765 </td>\n   <td style=\"text-align:left;\"> 31.97 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855768 </td>\n   <td style=\"text-align:left;\"> AI17_CLE2B21130055_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855768 </td>\n   <td style=\"text-align:left;\"> 32.62 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855771 </td>\n   <td style=\"text-align:left;\"> AI18_NEO1F09120034_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855771 </td>\n   <td style=\"text-align:left;\"> 34.47 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855774 </td>\n   <td style=\"text-align:left;\"> AI18_NEO1F09120035_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855774 </td>\n   <td style=\"text-align:left;\"> 32.12 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855777 </td>\n   <td style=\"text-align:left;\"> AI19_NEO1F16120038_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855777 </td>\n   <td style=\"text-align:left;\"> 38.46 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855780 </td>\n   <td style=\"text-align:left;\"> AI19_NEO1F16120039_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855780 </td>\n   <td style=\"text-align:left;\"> 37.39 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855783 </td>\n   <td style=\"text-align:left;\"> AI20_MOS2D20170459_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855783 </td>\n   <td style=\"text-align:left;\"> 37.41 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855786 </td>\n   <td style=\"text-align:left;\"> AI20_MOS2D20170460_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855786 </td>\n   <td style=\"text-align:left;\"> 35.79 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855795 </td>\n   <td style=\"text-align:left;\"> PU1_NEO1F09120035_2016-04-18.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855795 </td>\n   <td style=\"text-align:left;\"> 41.55 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855798 </td>\n   <td style=\"text-align:left;\"> PU1_NEO1F16120038_2016-04-18.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855798 </td>\n   <td style=\"text-align:left;\"> 19.03 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855801 </td>\n   <td style=\"text-align:left;\"> PU2_NEO1B41100255_2016-04-21.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855801 </td>\n   <td style=\"text-align:left;\"> 6.34 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855804 </td>\n   <td style=\"text-align:left;\"> PU2_NEO1B41100262_2016-04-21.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855804 </td>\n   <td style=\"text-align:left;\"> 43.08 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855807 </td>\n   <td style=\"text-align:left;\"> PU3_CLE2B21130054_2017-03-16.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855807 </td>\n   <td style=\"text-align:left;\"> 11.67 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855810 </td>\n   <td style=\"text-align:left;\"> PU3_CLE2B21130055_2017-03-16.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855810 </td>\n   <td style=\"text-align:left;\"> 14.90 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855813 </td>\n   <td style=\"text-align:left;\"> PU4_NEO1B41100262_2017-03-23.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855813 </td>\n   <td style=\"text-align:left;\"> 43.55 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855816 </td>\n   <td style=\"text-align:left;\"> PU4_NEO1F09120034_2017-03-23.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855816 </td>\n   <td style=\"text-align:left;\"> 34.04 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855819 </td>\n   <td style=\"text-align:left;\"> PU5_NEO1F09120035_2017-03-24.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855819 </td>\n   <td style=\"text-align:left;\"> 16.13 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855822 </td>\n   <td style=\"text-align:left;\"> PU5_NEO1F16120038_2017-03-24.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855822 </td>\n   <td style=\"text-align:left;\"> 33.47 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855825 </td>\n   <td style=\"text-align:left;\"> PU6_CLE2B21130054_2017-03-28.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855825 </td>\n   <td style=\"text-align:left;\"> 44.21 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855828 </td>\n   <td style=\"text-align:left;\"> PU6_CLE2B21130055_2017-03-28.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855828 </td>\n   <td style=\"text-align:left;\"> 34.61 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855831 </td>\n   <td style=\"text-align:left;\"> PU7_NEO1B41100262_2017-05-09.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855831 </td>\n   <td style=\"text-align:left;\"> 1.43 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855834 </td>\n   <td style=\"text-align:left;\"> PU7_NEO1F16120038_2017-05-09.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855834 </td>\n   <td style=\"text-align:left;\"> 33.76 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855837 </td>\n   <td style=\"text-align:left;\"> PU8_NEO1B41100262_2017-05-18.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855837 </td>\n   <td style=\"text-align:left;\"> 20.26 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855840 </td>\n   <td style=\"text-align:left;\"> PU8_NEO1F16120038_2017-05-18.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855840 </td>\n   <td style=\"text-align:left;\"> 2.18 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855843 </td>\n   <td style=\"text-align:left;\"> PU9_NEO1B41100255_2017-06-05.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855843 </td>\n   <td style=\"text-align:left;\"> 39.53 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855846 </td>\n   <td style=\"text-align:left;\"> PU9_NEO1F16120039_2017-06-05.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855846 </td>\n   <td style=\"text-align:left;\"> 30.72 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855849 </td>\n   <td style=\"text-align:left;\"> PU10_NEO1F09120034_2017-06-07.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855849 </td>\n   <td style=\"text-align:left;\"> 31.72 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855852 </td>\n   <td style=\"text-align:left;\"> PU10_NEO1F09120035_2017-06-07.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855852 </td>\n   <td style=\"text-align:left;\"> 38.88 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855855 </td>\n   <td style=\"text-align:left;\"> PU11_MOS2D09170393_2017-08-11.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855855 </td>\n   <td style=\"text-align:left;\"> 44.10 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855858 </td>\n   <td style=\"text-align:left;\"> PU11_MOS2D09170398_2017-08-11.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855858 </td>\n   <td style=\"text-align:left;\"> 18.28 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855861 </td>\n   <td style=\"text-align:left;\"> PU12_NEO1B41100255_2017-07-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855861 </td>\n   <td style=\"text-align:left;\"> 12.90 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855864 </td>\n   <td style=\"text-align:left;\"> PU12_NEO1F16120039_2017-07-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855864 </td>\n   <td style=\"text-align:left;\"> 31.59 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855867 </td>\n   <td style=\"text-align:left;\"> PU13_NEO1B41100262_2017-07-18.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855867 </td>\n   <td style=\"text-align:left;\"> 41.62 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855870 </td>\n   <td style=\"text-align:left;\"> PU13_NEO1F16120038_2017-07-18.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855870 </td>\n   <td style=\"text-align:left;\"> 7.67 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855873 </td>\n   <td style=\"text-align:left;\"> PU14_NEO1F09120034_2017-08-02.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855873 </td>\n   <td style=\"text-align:left;\"> 36.01 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855876 </td>\n   <td style=\"text-align:left;\"> PU14_NEO1F09120035_2017-08-02.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855876 </td>\n   <td style=\"text-align:left;\"> 20.51 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855879 </td>\n   <td style=\"text-align:left;\"> PU15_NEO1F16120038_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855879 </td>\n   <td style=\"text-align:left;\"> 24.27 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855882 </td>\n   <td style=\"text-align:left;\"> PU15_NEO1F16120039_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855882 </td>\n   <td style=\"text-align:left;\"> 20.54 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855885 </td>\n   <td style=\"text-align:left;\"> PU16_NEO1B41100255_2017-09-27.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855885 </td>\n   <td style=\"text-align:left;\"> 15.39 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855888 </td>\n   <td style=\"text-align:left;\"> PU16_NEO1B41100262_2017-09-27.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855888 </td>\n   <td style=\"text-align:left;\"> 37.75 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855891 </td>\n   <td style=\"text-align:left;\"> PU17_CLE2B21130054_2017-10-16.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855891 </td>\n   <td style=\"text-align:left;\"> 9.06 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855894 </td>\n   <td style=\"text-align:left;\"> PU17_CLE2B21130055_2017-10-16.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855894 </td>\n   <td style=\"text-align:left;\"> 26.81 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855897 </td>\n   <td style=\"text-align:left;\"> PU18_NEO1F09120035_2017-10-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855897 </td>\n   <td style=\"text-align:left;\"> 1.09 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855900 </td>\n   <td style=\"text-align:left;\"> PU18_NEO1F16120039_2017-10-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855900 </td>\n   <td style=\"text-align:left;\"> 33.71 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855903 </td>\n   <td style=\"text-align:left;\"> PU19_NEO1F09120034_2017-10-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855903 </td>\n   <td style=\"text-align:left;\"> 39.96 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855906 </td>\n   <td style=\"text-align:left;\"> PU19_NEO1F16120038_2017-10-20.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855906 </td>\n   <td style=\"text-align:left;\"> 22.39 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855909 </td>\n   <td style=\"text-align:left;\"> PU20_MOS2D09170393_2017-11-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855909 </td>\n   <td style=\"text-align:left;\"> 19.72 MB </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855912 </td>\n   <td style=\"text-align:left;\"> PU20_MOS2D09170398_2017-11-17.gt3x.gz </td>\n   <td style=\"text-align:right;\"> 21855912 </td>\n   <td style=\"text-align:left;\"> 41.75 MB </td>\n  </tr>\n</tbody>\n</table>"
```

We need to add the data path so that it's a full file name:



```r
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
df %>% knitr::kable() %>% head()
```

```
[1] "<table>\n <thead>\n  <tr>\n   <th style=\"text-align:left;\"> download_url </th>\n   <th style=\"text-align:left;\"> file </th>\n   <th style=\"text-align:left;\"> id </th>\n   <th style=\"text-align:left;\"> serial </th>\n   <th style=\"text-align:left;\"> date </th>\n   <th style=\"text-align:left;\"> size </th>\n   <th style=\"text-align:left;\"> group </th>\n   <th style=\"text-align:left;\"> article_id </th>\n   <th style=\"text-align:left;\"> outfile </th>\n  </tr>\n </thead>\n<tbody>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855555 </td>\n   <td style=\"text-align:left;\"> AI1_NEO1B41100255_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI1 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2016-10-17 </td>\n   <td style=\"text-align:left;\"> 33.59 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855555 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI1_NEO1B41100255_2016-10-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855558 </td>\n   <td style=\"text-align:left;\"> AI1_NEO1F09120035_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI1 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2016-10-17 </td>\n   <td style=\"text-align:left;\"> 36.04 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855558 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI1_NEO1F09120035_2016-10-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855561 </td>\n   <td style=\"text-align:left;\"> AI2_NEO1B41100262_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI2 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2016-10-17 </td>\n   <td style=\"text-align:left;\"> 39.84 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855561 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI2_NEO1B41100262_2016-10-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855564 </td>\n   <td style=\"text-align:left;\"> AI2_NEO1F16120038_2016-10-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI2 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2016-10-17 </td>\n   <td style=\"text-align:left;\"> 41.67 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855564 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI2_NEO1F16120038_2016-10-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855567 </td>\n   <td style=\"text-align:left;\"> AI3_CLE2B21130054_2017-06-02.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI3 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-06-02 </td>\n   <td style=\"text-align:left;\"> 46.45 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855567 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI3_CLE2B21130054_2017-06-02.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855573 </td>\n   <td style=\"text-align:left;\"> AI3_CLE2B21130055_2017-06-02.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI3 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-06-02 </td>\n   <td style=\"text-align:left;\"> 44.68 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855573 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI3_CLE2B21130055_2017-06-02.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855576 </td>\n   <td style=\"text-align:left;\"> AI4_MOS2D09170393_2017-06-06.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI4 </td>\n   <td style=\"text-align:left;\"> MOS2D09170393 </td>\n   <td style=\"text-align:left;\"> 2017-06-06 </td>\n   <td style=\"text-align:left;\"> 36.13 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855576 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI4_MOS2D09170393_2017-06-06.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855582 </td>\n   <td style=\"text-align:left;\"> AI4_MOS2D09170398_2017-06-06.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI4 </td>\n   <td style=\"text-align:left;\"> MOS2D09170398 </td>\n   <td style=\"text-align:left;\"> 2017-06-06 </td>\n   <td style=\"text-align:left;\"> 36.47 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855582 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI4_MOS2D09170398_2017-06-06.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855588 </td>\n   <td style=\"text-align:left;\"> AI5_NEO1B41100262_2017-06-13.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI5 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2017-06-13 </td>\n   <td style=\"text-align:left;\"> 33.70 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855588 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI5_NEO1B41100262_2017-06-13.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855591 </td>\n   <td style=\"text-align:left;\"> AI5_NEO1F16120038_2017-06-13.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI5 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-06-13 </td>\n   <td style=\"text-align:left;\"> 32.65 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855591 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI5_NEO1F16120038_2017-06-13.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855639 </td>\n   <td style=\"text-align:left;\"> AI6_NEO1B41100255_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI6 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2017-06-17 </td>\n   <td style=\"text-align:left;\"> 44.02 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855639 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI6_NEO1B41100255_2017-06-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855642 </td>\n   <td style=\"text-align:left;\"> AI6_NEO1F16120039_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI6 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-06-17 </td>\n   <td style=\"text-align:left;\"> 35.96 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855642 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI6_NEO1F16120039_2017-06-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855645 </td>\n   <td style=\"text-align:left;\"> AI7_MOS2D09170393_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI7 </td>\n   <td style=\"text-align:left;\"> MOS2D09170393 </td>\n   <td style=\"text-align:left;\"> 2017-06-17 </td>\n   <td style=\"text-align:left;\"> 39.66 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855645 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI7_MOS2D09170393_2017-06-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855648 </td>\n   <td style=\"text-align:left;\"> AI7_MOS2D09170398_2017-06-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI7 </td>\n   <td style=\"text-align:left;\"> MOS2D09170398 </td>\n   <td style=\"text-align:left;\"> 2017-06-17 </td>\n   <td style=\"text-align:left;\"> 38.59 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855648 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI7_MOS2D09170398_2017-06-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855651 </td>\n   <td style=\"text-align:left;\"> AI8_CLE2B21130054_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI8 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-08-14 </td>\n   <td style=\"text-align:left;\"> 33.83 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855651 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI8_CLE2B21130054_2017-08-14.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855654 </td>\n   <td style=\"text-align:left;\"> AI8_CLE2B21130055_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI8 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-08-14 </td>\n   <td style=\"text-align:left;\"> 33.84 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855654 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI8_CLE2B21130055_2017-08-14.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855657 </td>\n   <td style=\"text-align:left;\"> AI9_NEO1B41100255_2017-06-27.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI9 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2017-06-27 </td>\n   <td style=\"text-align:left;\"> 36.65 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855657 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI9_NEO1B41100255_2017-06-27.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855660 </td>\n   <td style=\"text-align:left;\"> AI9_NEO1F16120039_2017-06-27.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI9 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-06-27 </td>\n   <td style=\"text-align:left;\"> 33.61 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855660 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI9_NEO1F16120039_2017-06-27.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855663 </td>\n   <td style=\"text-align:left;\"> AI10_CLE2B21130054_2017-07-05.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI10 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-07-05 </td>\n   <td style=\"text-align:left;\"> 38.40 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855663 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI10_CLE2B21130054_2017-07-05.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855666 </td>\n   <td style=\"text-align:left;\"> AI10_CLE2B21130055_2017-07-05.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI10 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-07-05 </td>\n   <td style=\"text-align:left;\"> 36.25 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855666 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI10_CLE2B21130055_2017-07-05.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855669 </td>\n   <td style=\"text-align:left;\"> AI11_MOS2D09170393_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI11 </td>\n   <td style=\"text-align:left;\"> MOS2D09170393 </td>\n   <td style=\"text-align:left;\"> 2017-09-25 </td>\n   <td style=\"text-align:left;\"> 35.82 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855669 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI11_MOS2D09170393_2017-09-25.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855672 </td>\n   <td style=\"text-align:left;\"> AI11_MOS2D09170398_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI11 </td>\n   <td style=\"text-align:left;\"> MOS2D09170398 </td>\n   <td style=\"text-align:left;\"> 2017-09-25 </td>\n   <td style=\"text-align:left;\"> 35.21 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855672 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI11_MOS2D09170398_2017-09-25.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855675 </td>\n   <td style=\"text-align:left;\"> AI12_NEO1F09120034_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI12 </td>\n   <td style=\"text-align:left;\"> NEO1F09120034 </td>\n   <td style=\"text-align:left;\"> 2017-09-25 </td>\n   <td style=\"text-align:left;\"> 38.94 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855675 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI12_NEO1F09120034_2017-09-25.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855678 </td>\n   <td style=\"text-align:left;\"> AI12_NEO1F09120035_2017-09-25.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI12 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2017-09-25 </td>\n   <td style=\"text-align:left;\"> 37.06 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855678 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI12_NEO1F09120035_2017-09-25.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855681 </td>\n   <td style=\"text-align:left;\"> AI13_CLE2B21130054_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI13 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-09-23 </td>\n   <td style=\"text-align:left;\"> 43.46 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855681 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI13_CLE2B21130054_2017-09-23.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855684 </td>\n   <td style=\"text-align:left;\"> AI13_CLE2B21130055_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI13 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-09-23 </td>\n   <td style=\"text-align:left;\"> 44.94 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855684 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI13_CLE2B21130055_2017-09-23.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855687 </td>\n   <td style=\"text-align:left;\"> AI14_NEO1F16120038_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI14 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-09-23 </td>\n   <td style=\"text-align:left;\"> 41.77 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855687 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI14_NEO1F16120038_2017-09-23.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855690 </td>\n   <td style=\"text-align:left;\"> AI14_NEO1F16120039_2017-09-23.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI14 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-09-23 </td>\n   <td style=\"text-align:left;\"> 41.24 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855690 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI14_NEO1F16120039_2017-09-23.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855693 </td>\n   <td style=\"text-align:left;\"> AI15_MOS2D09170393_2017-10-30.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI15 </td>\n   <td style=\"text-align:left;\"> MOS2D09170393 </td>\n   <td style=\"text-align:left;\"> 2017-10-30 </td>\n   <td style=\"text-align:left;\"> 27.94 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855693 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI15_MOS2D09170393_2017-10-30.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855696 </td>\n   <td style=\"text-align:left;\"> AI15_MOS2D09170398_2017-10-30.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI15 </td>\n   <td style=\"text-align:left;\"> MOS2D09170398 </td>\n   <td style=\"text-align:left;\"> 2017-10-30 </td>\n   <td style=\"text-align:left;\"> 26.89 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855696 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI15_MOS2D09170398_2017-10-30.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855753 </td>\n   <td style=\"text-align:left;\"> AI16_MOS2D20170459_2017-11-08.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI16 </td>\n   <td style=\"text-align:left;\"> MOS2D20170459 </td>\n   <td style=\"text-align:left;\"> 2017-11-08 </td>\n   <td style=\"text-align:left;\"> 33.53 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855753 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI16_MOS2D20170459_2017-11-08.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855762 </td>\n   <td style=\"text-align:left;\"> AI16_MOS2D20170460_2017-11-08.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI16 </td>\n   <td style=\"text-align:left;\"> MOS2D20170460 </td>\n   <td style=\"text-align:left;\"> 2017-11-08 </td>\n   <td style=\"text-align:left;\"> 32.87 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855762 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI16_MOS2D20170460_2017-11-08.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855765 </td>\n   <td style=\"text-align:left;\"> AI17_CLE2B21130054_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI17 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 31.97 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855765 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI17_CLE2B21130054_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855768 </td>\n   <td style=\"text-align:left;\"> AI17_CLE2B21130055_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI17 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 32.62 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855768 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI17_CLE2B21130055_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855771 </td>\n   <td style=\"text-align:left;\"> AI18_NEO1F09120034_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI18 </td>\n   <td style=\"text-align:left;\"> NEO1F09120034 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 34.47 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855771 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI18_NEO1F09120034_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855774 </td>\n   <td style=\"text-align:left;\"> AI18_NEO1F09120035_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI18 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 32.12 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855774 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI18_NEO1F09120035_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855777 </td>\n   <td style=\"text-align:left;\"> AI19_NEO1F16120038_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI19 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 38.46 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855777 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI19_NEO1F16120038_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855780 </td>\n   <td style=\"text-align:left;\"> AI19_NEO1F16120039_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI19 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 37.39 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855780 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI19_NEO1F16120039_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855783 </td>\n   <td style=\"text-align:left;\"> AI20_MOS2D20170459_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI20 </td>\n   <td style=\"text-align:left;\"> MOS2D20170459 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 37.41 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855783 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI20_MOS2D20170459_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855786 </td>\n   <td style=\"text-align:left;\"> AI20_MOS2D20170460_2017-11-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> AI20 </td>\n   <td style=\"text-align:left;\"> MOS2D20170460 </td>\n   <td style=\"text-align:left;\"> 2017-11-20 </td>\n   <td style=\"text-align:left;\"> 35.79 MB </td>\n   <td style=\"text-align:left;\"> group_without_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855786 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_without_prosthesis/AI20_MOS2D20170460_2017-11-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855795 </td>\n   <td style=\"text-align:left;\"> PU1_NEO1F09120035_2016-04-18.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU1 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2016-04-18 </td>\n   <td style=\"text-align:left;\"> 41.55 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855795 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU1_NEO1F09120035_2016-04-18.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855798 </td>\n   <td style=\"text-align:left;\"> PU1_NEO1F16120038_2016-04-18.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU1 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2016-04-18 </td>\n   <td style=\"text-align:left;\"> 19.03 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855798 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU1_NEO1F16120038_2016-04-18.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855801 </td>\n   <td style=\"text-align:left;\"> PU2_NEO1B41100255_2016-04-21.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU2 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2016-04-21 </td>\n   <td style=\"text-align:left;\"> 6.34 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855801 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU2_NEO1B41100255_2016-04-21.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855804 </td>\n   <td style=\"text-align:left;\"> PU2_NEO1B41100262_2016-04-21.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU2 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2016-04-21 </td>\n   <td style=\"text-align:left;\"> 43.08 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855804 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU2_NEO1B41100262_2016-04-21.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855807 </td>\n   <td style=\"text-align:left;\"> PU3_CLE2B21130054_2017-03-16.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU3 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-03-16 </td>\n   <td style=\"text-align:left;\"> 11.67 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855807 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU3_CLE2B21130054_2017-03-16.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855810 </td>\n   <td style=\"text-align:left;\"> PU3_CLE2B21130055_2017-03-16.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU3 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-03-16 </td>\n   <td style=\"text-align:left;\"> 14.90 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855810 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU3_CLE2B21130055_2017-03-16.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855813 </td>\n   <td style=\"text-align:left;\"> PU4_NEO1B41100262_2017-03-23.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU4 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2017-03-23 </td>\n   <td style=\"text-align:left;\"> 43.55 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855813 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU4_NEO1B41100262_2017-03-23.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855816 </td>\n   <td style=\"text-align:left;\"> PU4_NEO1F09120034_2017-03-23.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU4 </td>\n   <td style=\"text-align:left;\"> NEO1F09120034 </td>\n   <td style=\"text-align:left;\"> 2017-03-23 </td>\n   <td style=\"text-align:left;\"> 34.04 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855816 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU4_NEO1F09120034_2017-03-23.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855819 </td>\n   <td style=\"text-align:left;\"> PU5_NEO1F09120035_2017-03-24.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU5 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2017-03-24 </td>\n   <td style=\"text-align:left;\"> 16.13 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855819 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU5_NEO1F09120035_2017-03-24.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855822 </td>\n   <td style=\"text-align:left;\"> PU5_NEO1F16120038_2017-03-24.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU5 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-03-24 </td>\n   <td style=\"text-align:left;\"> 33.47 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855822 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU5_NEO1F16120038_2017-03-24.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855825 </td>\n   <td style=\"text-align:left;\"> PU6_CLE2B21130054_2017-03-28.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU6 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-03-28 </td>\n   <td style=\"text-align:left;\"> 44.21 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855825 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU6_CLE2B21130054_2017-03-28.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855828 </td>\n   <td style=\"text-align:left;\"> PU6_CLE2B21130055_2017-03-28.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU6 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-03-28 </td>\n   <td style=\"text-align:left;\"> 34.61 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855828 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU6_CLE2B21130055_2017-03-28.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855831 </td>\n   <td style=\"text-align:left;\"> PU7_NEO1B41100262_2017-05-09.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU7 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2017-05-09 </td>\n   <td style=\"text-align:left;\"> 1.43 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855831 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU7_NEO1B41100262_2017-05-09.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855834 </td>\n   <td style=\"text-align:left;\"> PU7_NEO1F16120038_2017-05-09.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU7 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-05-09 </td>\n   <td style=\"text-align:left;\"> 33.76 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855834 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU7_NEO1F16120038_2017-05-09.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855837 </td>\n   <td style=\"text-align:left;\"> PU8_NEO1B41100262_2017-05-18.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU8 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2017-05-18 </td>\n   <td style=\"text-align:left;\"> 20.26 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855837 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU8_NEO1B41100262_2017-05-18.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855840 </td>\n   <td style=\"text-align:left;\"> PU8_NEO1F16120038_2017-05-18.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU8 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-05-18 </td>\n   <td style=\"text-align:left;\"> 2.18 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855840 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU8_NEO1F16120038_2017-05-18.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855843 </td>\n   <td style=\"text-align:left;\"> PU9_NEO1B41100255_2017-06-05.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU9 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2017-06-05 </td>\n   <td style=\"text-align:left;\"> 39.53 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855843 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU9_NEO1B41100255_2017-06-05.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855846 </td>\n   <td style=\"text-align:left;\"> PU9_NEO1F16120039_2017-06-05.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU9 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-06-05 </td>\n   <td style=\"text-align:left;\"> 30.72 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855846 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU9_NEO1F16120039_2017-06-05.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855849 </td>\n   <td style=\"text-align:left;\"> PU10_NEO1F09120034_2017-06-07.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU10 </td>\n   <td style=\"text-align:left;\"> NEO1F09120034 </td>\n   <td style=\"text-align:left;\"> 2017-06-07 </td>\n   <td style=\"text-align:left;\"> 31.72 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855849 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU10_NEO1F09120034_2017-06-07.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855852 </td>\n   <td style=\"text-align:left;\"> PU10_NEO1F09120035_2017-06-07.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU10 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2017-06-07 </td>\n   <td style=\"text-align:left;\"> 38.88 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855852 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU10_NEO1F09120035_2017-06-07.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855855 </td>\n   <td style=\"text-align:left;\"> PU11_MOS2D09170393_2017-08-11.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU11 </td>\n   <td style=\"text-align:left;\"> MOS2D09170393 </td>\n   <td style=\"text-align:left;\"> 2017-08-11 </td>\n   <td style=\"text-align:left;\"> 44.10 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855855 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU11_MOS2D09170393_2017-08-11.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855858 </td>\n   <td style=\"text-align:left;\"> PU11_MOS2D09170398_2017-08-11.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU11 </td>\n   <td style=\"text-align:left;\"> MOS2D09170398 </td>\n   <td style=\"text-align:left;\"> 2017-08-11 </td>\n   <td style=\"text-align:left;\"> 18.28 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855858 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU11_MOS2D09170398_2017-08-11.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855861 </td>\n   <td style=\"text-align:left;\"> PU12_NEO1B41100255_2017-07-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU12 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2017-07-17 </td>\n   <td style=\"text-align:left;\"> 12.90 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855861 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU12_NEO1B41100255_2017-07-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855864 </td>\n   <td style=\"text-align:left;\"> PU12_NEO1F16120039_2017-07-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU12 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-07-17 </td>\n   <td style=\"text-align:left;\"> 31.59 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855864 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU12_NEO1F16120039_2017-07-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855867 </td>\n   <td style=\"text-align:left;\"> PU13_NEO1B41100262_2017-07-18.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU13 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2017-07-18 </td>\n   <td style=\"text-align:left;\"> 41.62 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855867 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU13_NEO1B41100262_2017-07-18.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855870 </td>\n   <td style=\"text-align:left;\"> PU13_NEO1F16120038_2017-07-18.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU13 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-07-18 </td>\n   <td style=\"text-align:left;\"> 7.67 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855870 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU13_NEO1F16120038_2017-07-18.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855873 </td>\n   <td style=\"text-align:left;\"> PU14_NEO1F09120034_2017-08-02.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU14 </td>\n   <td style=\"text-align:left;\"> NEO1F09120034 </td>\n   <td style=\"text-align:left;\"> 2017-08-02 </td>\n   <td style=\"text-align:left;\"> 36.01 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855873 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU14_NEO1F09120034_2017-08-02.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855876 </td>\n   <td style=\"text-align:left;\"> PU14_NEO1F09120035_2017-08-02.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU14 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2017-08-02 </td>\n   <td style=\"text-align:left;\"> 20.51 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855876 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU14_NEO1F09120035_2017-08-02.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855879 </td>\n   <td style=\"text-align:left;\"> PU15_NEO1F16120038_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU15 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-08-14 </td>\n   <td style=\"text-align:left;\"> 24.27 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855879 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU15_NEO1F16120038_2017-08-14.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855882 </td>\n   <td style=\"text-align:left;\"> PU15_NEO1F16120039_2017-08-14.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU15 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-08-14 </td>\n   <td style=\"text-align:left;\"> 20.54 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855882 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU15_NEO1F16120039_2017-08-14.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855885 </td>\n   <td style=\"text-align:left;\"> PU16_NEO1B41100255_2017-09-27.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU16 </td>\n   <td style=\"text-align:left;\"> NEO1B41100255 </td>\n   <td style=\"text-align:left;\"> 2017-09-27 </td>\n   <td style=\"text-align:left;\"> 15.39 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855885 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU16_NEO1B41100255_2017-09-27.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855888 </td>\n   <td style=\"text-align:left;\"> PU16_NEO1B41100262_2017-09-27.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU16 </td>\n   <td style=\"text-align:left;\"> NEO1B41100262 </td>\n   <td style=\"text-align:left;\"> 2017-09-27 </td>\n   <td style=\"text-align:left;\"> 37.75 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855888 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU16_NEO1B41100262_2017-09-27.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855891 </td>\n   <td style=\"text-align:left;\"> PU17_CLE2B21130054_2017-10-16.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU17 </td>\n   <td style=\"text-align:left;\"> CLE2B21130054 </td>\n   <td style=\"text-align:left;\"> 2017-10-16 </td>\n   <td style=\"text-align:left;\"> 9.06 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855891 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU17_CLE2B21130054_2017-10-16.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855894 </td>\n   <td style=\"text-align:left;\"> PU17_CLE2B21130055_2017-10-16.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU17 </td>\n   <td style=\"text-align:left;\"> CLE2B21130055 </td>\n   <td style=\"text-align:left;\"> 2017-10-16 </td>\n   <td style=\"text-align:left;\"> 26.81 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855894 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU17_CLE2B21130055_2017-10-16.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855897 </td>\n   <td style=\"text-align:left;\"> PU18_NEO1F09120035_2017-10-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU18 </td>\n   <td style=\"text-align:left;\"> NEO1F09120035 </td>\n   <td style=\"text-align:left;\"> 2017-10-17 </td>\n   <td style=\"text-align:left;\"> 1.09 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855897 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU18_NEO1F09120035_2017-10-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855900 </td>\n   <td style=\"text-align:left;\"> PU18_NEO1F16120039_2017-10-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU18 </td>\n   <td style=\"text-align:left;\"> NEO1F16120039 </td>\n   <td style=\"text-align:left;\"> 2017-10-17 </td>\n   <td style=\"text-align:left;\"> 33.71 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855900 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU18_NEO1F16120039_2017-10-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855903 </td>\n   <td style=\"text-align:left;\"> PU19_NEO1F09120034_2017-10-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU19 </td>\n   <td style=\"text-align:left;\"> NEO1F09120034 </td>\n   <td style=\"text-align:left;\"> 2017-10-20 </td>\n   <td style=\"text-align:left;\"> 39.96 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855903 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU19_NEO1F09120034_2017-10-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855906 </td>\n   <td style=\"text-align:left;\"> PU19_NEO1F16120038_2017-10-20.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU19 </td>\n   <td style=\"text-align:left;\"> NEO1F16120038 </td>\n   <td style=\"text-align:left;\"> 2017-10-20 </td>\n   <td style=\"text-align:left;\"> 22.39 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855906 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU19_NEO1F16120038_2017-10-20.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855909 </td>\n   <td style=\"text-align:left;\"> PU20_MOS2D09170393_2017-11-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU20 </td>\n   <td style=\"text-align:left;\"> MOS2D09170393 </td>\n   <td style=\"text-align:left;\"> 2017-11-17 </td>\n   <td style=\"text-align:left;\"> 19.72 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855909 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU20_MOS2D09170393_2017-11-17.gt3x.gz </td>\n  </tr>\n  <tr>\n   <td style=\"text-align:left;\"> https://ndownloader.figshare.com/files/21855912 </td>\n   <td style=\"text-align:left;\"> PU20_MOS2D09170398_2017-11-17.gt3x.gz </td>\n   <td style=\"text-align:left;\"> PU20 </td>\n   <td style=\"text-align:left;\"> MOS2D09170398 </td>\n   <td style=\"text-align:left;\"> 2017-11-17 </td>\n   <td style=\"text-align:left;\"> 41.75 MB </td>\n   <td style=\"text-align:left;\"> group_with_prosthesis </td>\n   <td style=\"text-align:left;\"> 21855912 </td>\n   <td style=\"text-align:left;\"> /Users/johnmuschelli/Dropbox/Projects/upper_limb_gt3x_prosthesis/data/group_with_prosthesis/PU20_MOS2D09170398_2017-11-17.gt3x.gz </td>\n  </tr>\n</tbody>\n</table>"
```


## Demographics data


```r
metadata = file.path(data_dir, "Metadata.xlsx")
if (!file.exists(metadata)) {
  out = download.file(meta$download_url, destfile = metadata)
}
meta = readxl::read_excel(metadata)
```

```
New names:
* `` -> ...5
* `` -> ...11
* `` -> ...12
* `` -> ...13
* `` -> ...14
* ...
```

```r
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
  knitr::kable() %>% 
  kableExtra::kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> id </th>
   <th style="text-align:left;"> Gender </th>
   <th style="text-align:right;"> Age </th>
   <th style="text-align:left;"> Absence_side_(*previously_dominant) </th>
   <th style="text-align:left;"> Sensor_type </th>
   <th style="text-align:left;"> Right_Sensor </th>
   <th style="text-align:left;"> Left_Sensor </th>
   <th style="text-align:left;"> Time_since_limb_loss_(years) </th>
   <th style="text-align:right;"> Time_since_prescription_of_a_myoelectric_prosthesis_(years) </th>
   <th style="text-align:left;"> DataRAW_.gt3x </th>
   <th style="text-align:left;"> RAW.csv </th>
   <th style="text-align:left;"> RAW.wav </th>
   <th style="text-align:left;"> Without_Low_Frequency_Extension60s.csv </th>
   <th style="text-align:left;"> 1s.csv </th>
   <th style="text-align:left;"> With_Low_Frequency_Extension60sLFE.csv </th>
   <th style="text-align:left;"> 1sLFE.csv </th>
   <th style="text-align:left;"> Wear_data.csv </th>
   <th style="text-align:left;"> Sleep_diary.csv </th>
   <th style="text-align:left;"> Prosthesis_Wear_Diary.csv </th>
   <th style="text-align:left;"> Sensor_Wear_Diary.csv </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> PU1 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU2 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 35.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU3 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 56 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> 22 </td>
   <td style="text-align:right;"> 17.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU4 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> R* </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120034 </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> 37 </td>
   <td style="text-align:right;"> 28.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> Incomplete </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU5 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 10.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> Incomplete </td>
   <td style="text-align:left;"> Incomplete </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU6 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 51 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 30.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> Incomplete </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU7 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:left;"> R* </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> 24 </td>
   <td style="text-align:right;"> 23.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU8 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 19.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU9 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 49 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 33.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU10 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:left;"> R* </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120034 </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> 25 </td>
   <td style="text-align:right;"> 21.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU11 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:left;"> L* </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D09170393 </td>
   <td style="text-align:left;"> MOS2D09170398 </td>
   <td style="text-align:left;"> 47 </td>
   <td style="text-align:right;"> 39.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> Incomplete </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU12 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU13 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 69 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU14 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 62 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120034 </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> 12 </td>
   <td style="text-align:right;"> 10.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> Incomplete </td>
   <td style="text-align:left;"> Incomplete </td>
   <td style="text-align:left;"> Incomplete </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU15 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 33.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU16 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 34.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> Missing </td>
   <td style="text-align:left;"> Missing </td>
   <td style="text-align:left;"> Missing </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU17 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 67 </td>
   <td style="text-align:left;"> R* </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> 34 </td>
   <td style="text-align:right;"> 33.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU18 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 59 </td>
   <td style="text-align:left;"> R* </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> 15 </td>
   <td style="text-align:right;"> 14.5 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU19 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120034 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 4.5 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PU20 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 72 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D09170393 </td>
   <td style="text-align:left;"> MOS2D09170398 </td>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 5.0 </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI1 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI2 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI3 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 27 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI4 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D09170393 </td>
   <td style="text-align:left;"> MOS2D09170398 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI5 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100262 </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI6 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI7 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D09170393 </td>
   <td style="text-align:left;"> MOS2D09170398 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI8 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 61 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI9 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1B41100255 </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI10 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI11 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 58 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D09170393 </td>
   <td style="text-align:left;"> MOS2D09170398 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI12 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120034 </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI13 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 55 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI14 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 57 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI15 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D09170393 </td>
   <td style="text-align:left;"> MOS2D09170398 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Missing </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI16 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D20170460 </td>
   <td style="text-align:left;"> MOS2D20170459 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI17 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> wGT3X+ </td>
   <td style="text-align:left;"> CLE2B21130054 </td>
   <td style="text-align:left;"> CLE2B21130055 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI18 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:right;"> 36 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F09120034 </td>
   <td style="text-align:left;"> NEO1F09120035 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> Incomplete </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI19 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> R </td>
   <td style="text-align:left;"> GT3X+ </td>
   <td style="text-align:left;"> NEO1F16120038 </td>
   <td style="text-align:left;"> NEO1F16120039 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AI20 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:left;"> L </td>
   <td style="text-align:left;"> wGT3X-BT </td>
   <td style="text-align:left;"> MOS2D20170460 </td>
   <td style="text-align:left;"> MOS2D20170459 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> yes </td>
  </tr>
</tbody>
</table>

# Packages

THe `read.gt3x` and `AGread` packages can read gt3x files, but only the `read.gt3x` package can read in the old GT3X format from NHANES 2003-2006.  Thus, we will use that package to read the `gt3x` format.  If you need additional information, such as temperature, lux, etc, you may want to try `AGread::read_gt3x`.  Additionally, the `read.gt3x` package can read in `gt3x` files that have been zipped, including gzipped (extension `gz`), bzipped (`bz2`), or xzipped (`xz`).

THe `SummarizedActigraphy::read_actigraphy` wraps the `read.gt3x` functionality, and puts the output format to the `AccData` format, which is common in the `GGIR` package.  The `read_actigraphy` also tries to read other formats, by using `GGIR::g.readaccfile` and other `GGIR` functionality.  



```r
data = full_join(meta, df)
```

```
Joining, by = "id"
```

## Read in one file


Here we will read in one file:


```r
iid = sample(nrow(df), 1)
idf = df[iid, ]
if (!file.exists(idf$outfile)) {
  out = curl::curl_download(idf$download_url, destfile = idf$outfile)
}
acc = read.gt3x(idf$outfile, verbose = FALSE, 
                asDataFrame = TRUE, imputeZeroes = TRUE)
acc = read_actigraphy(idf$outfile, verbose = FALSE)
head(acc$data.out)
```

```
Sampling Rate: 30Hz
Firmware Version: 3.2.1
Serial Number Prefix: NEO
       X      Y      Z                time
1 -0.021 -0.683 -0.762 2017-03-24 16:30:00
2 -0.003 -0.625 -0.736 2017-03-24 16:30:00
3  0.003 -0.601 -0.765 2017-03-24 16:30:00
4 -0.003 -0.630 -0.806 2017-03-24 16:30:00
5 -0.015 -0.630 -0.821 2017-03-24 16:30:00
6 -0.012 -0.639 -0.789 2017-03-24 16:30:00
```

```r
options(digits.secs = 2)
head(acc$data.out)
```

```
Sampling Rate: 30Hz
Firmware Version: 3.2.1
Serial Number Prefix: NEO
       X      Y      Z                   time
1 -0.021 -0.683 -0.762 2017-03-24 16:30:00.00
2 -0.003 -0.625 -0.736 2017-03-24 16:30:00.02
3  0.003 -0.601 -0.765 2017-03-24 16:30:00.06
4 -0.003 -0.630 -0.806 2017-03-24 16:30:00.09
5 -0.015 -0.630 -0.821 2017-03-24 16:30:00.13
6 -0.012 -0.639 -0.789 2017-03-24 16:30:00.17
```

```r
acc$freq
```

```
[1] 30
```

Let's look at the number of measurements per second to see the true sampling rate:


```r
res = acc$data.out %>% 
  mutate(dt = floor_date(time, "seconds")) %>% 
  group_by(dt) %>% 
  count()
table(res$n)
```

```

    30 
604800 
```


```r
library(ggplot2)
res = acc$data.out %>% 
  mutate(day = floor_date(time, "day"),
         time = hms::as_hms(time)) %>% 
  mutate(day = difftime(day, day[1], units = "days")) %>% 
  tidyr::gather(key = direction, value = accel, -time, -day)
# res %>% 
#   filter(day == 1) %>% 
#   ggplot(aes(x = time, y = accel, colour = direction)) + 
#   geom_line()
```


Here we can do a simple data check:

```r
acc$header
```

```
# A tibble: 21 x 2
   Field            Value              
   <chr>            <chr>              
 1 Serial Number    NEO1F09120035      
 2 Device Type      GT3XPlus           
 3 Firmware         3.2.1              
 4 Battery Voltage  4.02               
 5 Sample Rate      30                 
 6 Start Date       2017-03-24 16:30:00
 7 Stop Date        2017-03-31 16:30:00
 8 Last Sample Time 2017-03-31 16:30:00
 9 TimeZone         01:00:00           
10 Download Date    2017-04-11 13:12:29
# … with 11 more rows
```

```r
acc$header %>% 
  filter(Field %in% c("Sex", "Age", "Side"))
```

```
# A tibble: 2 x 2
  Field Value 
  <chr> <chr> 
1 Sex   Female
2 Side  Left  
```

```r
data[iid, c("Gender", "Age")]
```

```
# A tibble: 1 x 2
  Gender   Age
  <chr>  <dbl>
1 F         24
```


```r
calculate_ai = function(df, epoch = "1 min") {
  sec_df = df %>% 
    mutate(
      HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, "1 sec")) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      AI = sqrt((var(X) + var(Y) + var(Z))/3),
    )
  sec_df %>% mutate(
    HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, epoch)) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      AI = sum(AI)
    )
}

calculate_mad = function(df, epoch = "1 min") {
  df %>% 
    mutate(         
      r = sqrt(X^2+Y^2+Z^2),
      HEADER_TIME_STAMP = lubridate::floor_date(HEADER_TIME_STAMP, epoch)) %>% 
    group_by(HEADER_TIME_STAMP) %>% 
    summarise(
      SD = sd(r),
      MAD = mean(abs(r - mean(r))),
      MEDAD = median(abs(r - mean(r)))
    )
}
calculate_measures = function(df, epoch = "1 min") {
  ai0 = calculate_ai(df, epoch = epoch)
  mad = calculate_mad(df, epoch = epoch)
  res = full_join(ai0, mad)
  res
}
```

We will calculate MIMS units with the `MIMSunit` package:

```r
df = acc$data.out
df = df %>% 
  rename(HEADER_TIME_STAMP = time) %>% 
  select(HEADER_TIME_STAMP, X, Y, Z)
system.time({measures = calculate_measures(df)})
```

```
`summarise()` ungrouping output (override with `.groups` argument)
`summarise()` ungrouping output (override with `.groups` argument)
`summarise()` ungrouping output (override with `.groups` argument)
```

```
Joining, by = "HEADER_TIME_STAMP"
```

```
   user  system elapsed 
 45.243   4.546  62.276 
```


```r
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
```

```
================================
```

```
Warning: `tbl_df()` is deprecated as of dplyr 1.0.0.
Please use `tibble::as_tibble()` instead.
This warning is displayed once every 8 hours.
Call `lifecycle::last_warnings()` to see where this warning was generated.
```

```
================================================
```

```
    user   system  elapsed 
 696.519  258.977 1504.837 
```

```r
measures = full_join(measures, mims)
```

```
Joining, by = "HEADER_TIME_STAMP"
```




```r
library(corrr)
measures %>% select(-HEADER_TIME_STAMP) %>% 
  correlate()
```

```

Correlation method: 'pearson'
Missing treated using: 'pairwise.complete.obs'
```

```
# A tibble: 5 x 6
  rowname       AI     SD    MAD  MEDAD MIMS_UNIT
  <chr>      <dbl>  <dbl>  <dbl>  <dbl>     <dbl>
1 AI        NA      0.534  0.460  0.446     0.986
2 SD         0.534 NA      0.979  0.927     0.620
3 MAD        0.460  0.979 NA      0.977     0.545
4 MEDAD      0.446  0.927  0.977 NA         0.519
5 MIMS_UNIT  0.986  0.620  0.545  0.519    NA    
```







# References

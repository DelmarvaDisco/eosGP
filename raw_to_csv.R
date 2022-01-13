#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Name: 2021 data clean & aggregate
# Coder: James Maze
# Date: 13 Jan 2021
# Purpose: Aggregate the raw downloads into a clean .csv
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Notes:
#   -


# 1. Libraries and workspace ----------------------------------------------

remove(list = ls())

library(purrr)
library(lubridate)
library(tidyverse)
library(stringr)

source("functions/download_fun")

data_dir <- "data/2021/"

# 2. Read the JL files ----------------------------------------------

eosGP_files <- list.files(paste0(data_dir), full.names = TRUE)

eosGP_files <- eosGP_files[str_detect(eosGP_files, "eosGP")]

data <- eosGP_files %>% 
  map(download_fun) %>% 
  reduce(rbind)


# 3. Concatenate files by site --------------------------------------------


# 4. Convert time zone EDT to EST ---------------------------------------------------


# 5. Read the BC files -----------------------------------------------------


# 6. Combine into one large .csv ------------------------------------------



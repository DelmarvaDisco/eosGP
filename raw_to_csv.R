#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Name: 2021 data clean & aggregate
# Coder: James Maze
# Date: 13 Jan 2021
# Purpose: Aggregate the raw downloads into a clean .csv
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Notes:
#   - Because Campbell loggers appends new downloads to the previous file path, 
#     we need to remove overlap in the data frames
#   - Should we remove data where the sensors were dry?


# 1. Libraries and workspace ----------------------------------------------

remove(list = ls())

library(purrr)
library(lubridate)
library(tidyverse)
library(stringr)

source("functions/download_fun.R")

data_dir <- "data/2021/"

# 2. Read the JL files ----------------------------------------------

eosGP_files <- list.files(paste0(data_dir), full.names = TRUE)

eosGP_files <- eosGP_files[str_detect(eosGP_files, "eosGP")]

data <- eosGP_files %>% 
  map(download_fun) %>% 
  reduce(rbind)


# 3. Remove the redundant data points and bad measurement times -----------------------------------------------

data <- data %>% 
  distinct(Site_ID, TIMESTAMP, RECORD, .keep_all = TRUE) %>% 
  filter(!TIMESTAMP == "TS") %>% #Removes the wonky rows below column names
  transmute(Timestamp = ymd_hms(TIMESTAMP),
         BattV = as.numeric(BattV),
         Logger_TempC = as.numeric(PTemp_C),
         CO2_Conc_ppm = as.numeric(GP_CO2Conc),
         CO2_HiConc_ppm = as.numeric(GP_CO2HiConc),
         GP_TempC = as.numeric(GP_Temp),
         Site_ID = Site_ID,
         file = file) #Remove this column once data is clean 
  

#   3a. DK-SW cleaning ------------------------------------------------------

data_DK <- data %>% 
  filter(Site_ID == "DK_SW") 

#   3b. TS-SW cleaning ------------------------------------------------------

data_TS <- data %>% 
  filter(Site_ID == "TS_SW") 

#   3c. ND-SW cleaning ------------------------------------------------------

data_ND <- data %>% 
  filter(Site_ID == "ND_SW") 




# 4. Convert time zone EDT to EST ---------------------------------------------------


# 5. Read the BC files -----------------------------------------------------


# 6. Combine into one large .csv ------------------------------------------



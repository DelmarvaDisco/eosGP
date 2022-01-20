#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Name: Raw to csv Jackson Lane
# Coder: James Maze
# Date: 13 Jan 2021
# Purpose: Aggregate the raw downloads into a clean .csv for Jackson Lane
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Notes:
#   - Because Campbell loggers appends new downloads to the previous file path, 
#     we need to remove overlap in the data frames
#   - Should we remove data where the sensors were dry?
#   - Crappy data at DK-SW around Aug 2nd 2021, moved raft that day
#   - Spotty data at TS-SW until May 1st 2021, because of bad logger code


# 1. Libraries and workspace ----------------------------------------------

remove(list = ls())

library(xts)
library(dygraphs)
library(purrr)
library(lubridate)
library(tidyverse)
library(stringr)

source("functions/download_fun.R")
source("functions/prelim_plot.R")

data_dir <- "data/2021/"

# 2. Read the JL files ----------------------------------------------

eosGP_files <- list.files(paste0(data_dir), full.names = TRUE)

eosGP_files <- eosGP_files[str_detect(eosGP_files, "_eosGP")]

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
#   - Crappy data at DK-SW around Aug 2nd. Site was dry, moved raft to a deeper spot. 
SiteName <- "DK_SW"

#Create a dygraph to cut bad data points
df <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

prelim_plot(df)

data_DK <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp >= "2021-05-01 13:30:00")


#   3b. TS-SW cleaning ------------------------------------------------------
#   - Spotty data at TS-SW until May 1st, because of bad logger code
SiteName <- "TS_SW"

#Create a dygraph to cut out bad data points
df <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

prelim_plot(df)

data_TS <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp >= "2021-04-14 12:30:00") %>% 
  filter(Timestamp <= "2021-07-04 12:00:00" | Timestamp >= "2021-09-01 12:00:00") %>% 
  filter(Timestamp <= "2021-12-31 12:00:00")

#   3c. ND-SW cleaning ------------------------------------------------------
SiteName <- "ND_SW"

#Create a dygraph to cut bad data points
df <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

prelim_plot(df)

data_ND <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp >= "2021-05-21 12:00:00")


# 3d. Combine JL sites -------------------------------------------------------

data_cleaned <- rbind(data_DK, data_ND, data_TS)

rm(data_DK, data_ND, data_TS, df, SiteName)


# 4. Convert time zone from EDT to EST at JL ---------------------------------------------------

hrs <- hours(1)

data_cleaned_EST <- data_cleaned %>% 
  mutate(Timestamp = Timestamp - hrs)
 
 

# XX. write csv -----------------------------------------------------------

write_csv(data_cleaned_EST, file = paste0(data_dir,"eosGP_JL.csv"))






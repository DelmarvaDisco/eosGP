#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Name: Raw to csv Jackson Lane
# Coder: James Maze
# Date: 13 Jan 2021
# Purpose: Aggregate the raw downloads into a clean .csv for Jackson Lane
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Notes:
#   - Thus far, only cut data where sensors were not at the sites.
#   - Should we remove data where the sensors were dry?
#   - Crappy data at DK-SW around Aug 2nd 2021, moved raft that day
#   - Spotty data at TS-SW until May 1st 2021, because of bad logger code
#   - Should we read in the output tables from Campbell loggers too?


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

#Lists all files in data_dir
files <- list.files(paste0(data_dir), full.names = TRUE)
#Selects only the GP files
eosGP_files <- files[str_detect(files, "_eosGP")]

#Run the download function and combine GP files
data <- eosGP_files %>% 
  map(download_fun) %>% 
  reduce(rbind)

rm(files, eosGP_files)

# 3. Remove the redundant data points and bad measurement times -----------------------------------------------

data <- data %>% 
  #Returns only the rows with unique values across. Eliminates overlapping data.
  distinct(Site_ID, TIMESTAMP, RECORD, .keep_all = TRUE) %>% 
  #Removes the wonky rows below column names
  filter(!TIMESTAMP == "TS") %>% 
  #Reformat columns accordingly
  transmute(Timestamp = ymd_hms(TIMESTAMP),
         BattV = as.numeric(BattV),
         Logger_TempC = as.numeric(PTemp_C),
         CO2_Conc_ppm = as.numeric(GP_CO2Conc),
         CO2_HiConc_ppm = as.numeric(GP_CO2HiConc),
         GP_TempC = as.numeric(GP_Temp),
         Site_ID = Site_ID,
         file = file) #Remove this column once data is clean 
  

#   3a. DK-SW cleaning ------------------------------------------------------
# Notes:
#   - Crappy data at DK-SW around Aug 2nd. Site was dry, moved raft to a deeper spot. 

SiteName <- "DK_SW"

#Create a dygraph to cut bad data points
df <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

#Filter out bad measurements based on dygraph
data_DK <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp <= "2022-01-01 12:30:00")

prelim_plot(data_DK %>% select(c(Timestamp, CO2_HiConc_ppm)))

#   3b. TS-SW cleaning ------------------------------------------------------
#Notes:
#   - Spotty data at TS-SW until May 1st, because of bad logger code

SiteName <- "TS_SW"

#Create a dygraph to cut out bad data points
df <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))


#Filter out bad values based on the dygraph
data_TS <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp <= "2022-01-01 12:30:00")

prelim_plot(data_TS %>% select(c(Timestamp, CO2_HiConc_ppm)))

#   3c. ND-SW cleaning ------------------------------------------------------
#Notes:
#   - 

SiteName <- "ND_SW"

#Create a dygraph to cut bad data points
df <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

data_ND <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp <= "2022-01-01 12:30:00")

prelim_plot(data_ND %>% select(c(Timestamp, CO2_HiConc_ppm)))


# 3d. Combine JL sites -------------------------------------------------------

#Merge sites back together AFTER bad values are cut
data_cleaned <- rbind(data_DK, data_ND, data_TS)

rm(data_DK, data_ND, data_TS, df, SiteName)


# 4. Convert time zone from EDT to EST at JL ---------------------------------------------------

hrs <- hours(1)
# Subtract an hour to convert all data to EST
data_cleaned_EST <- data_cleaned %>% 
  mutate(Timestamp = Timestamp - hrs)

# XX. write csv -----------------------------------------------------------

write_csv(data_cleaned_EST, file = paste0(data_dir,"eosGP_JL.csv"))






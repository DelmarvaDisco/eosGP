#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Name: Raw to csv Jackson Lane
# Coder: James Maze
# Date: 5 May 2022
# Purpose: Aggregate the raw downloads into a clean .csv for Jackson Lane 2022 Deployment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Notes:



# 1. Libraries and work space ----------------------------------------------

remove(list = ls())

library(xts)
library(dygraphs)
library(tidyverse)

source("functions/download_fun.R")
source("functions/prelim_plot.R")

data_dir <- "data/"

# 2. Read the JL files ----------------------------------------------

#Lists all files in data_dir
files <- list.files(paste0(data_dir), full.names = TRUE)
#Selects only the GP files
eosGP_files <- files[str_detect(files, "_eosGP")]
#Selects only data from 2022
eosGP_files <- eosGP_files[str_detect(eosGP_files, "2022")]

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
temp <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

prelim_plot(temp)

#Filter out bad measurements based on dygraph
data_DK <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp >= "2022-02-20 00:00:00")

rm(SiteName, temp)

#   3b. TS-SW cleaning ------------------------------------------------------

SiteName <- "TS_SW"

#Create a dygraph to cut out bad data points
temp <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

prelim_plot(temp)

#Filter out bad values based on the dygraph
data_TS <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp >= "2022-02-20 00:00:00")

rm(SiteName, temp)

#   3c. ND-SW cleaning ------------------------------------------------------

SiteName <- "ND_SW"

#Create a dygraph to cut bad data points
temp <- data %>% 
  filter(Site_ID == SiteName) %>% 
  select(c(Timestamp, CO2_HiConc_ppm))

prelim_plot(temp)

data_ND <- data %>% 
  filter(Site_ID == SiteName) %>% 
  filter(Timestamp >= "2022-02-20 00:00:00")

rm(SiteName, temp)

# 3d. Combine JL sites -------------------------------------------------------

#Merge sites back together AFTER bad values are cut
data_cleaned <- rbind(data_DK, data_ND, data_TS)

gg_cleaned <- ggplot(data = data_cleaned, 
                     mapping = aes(x = Timestamp,
                                   y = CO2_HiConc_ppm, 
                                   color = Site_ID)) +
  geom_line() +
  theme_bw()  
  

(gg_cleaned)

rm(data_DK, data_ND, data_TS, df, SiteName)




# 4. Convert time zone from EDT to EST at JL ---------------------------------------------------


hrs <- hours(1)
# Subtract an hour to convert all data to EST
data_cleaned_EST <- data_cleaned %>% 
  mutate(Timestamp = Timestamp - hrs)

# XX. write csv -----------------------------------------------------------








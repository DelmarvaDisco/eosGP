#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Name: Raw to csv Baltimore Corner
# Coder: James Maze
# Date: 20 Jan 2021
# Purpose: Instrumentation problems at Baltimore Corner and the raw data is messy. Clean up.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Notes:
#   - Holyshit this is a dumpster fire
#   - For some reason, the HB-SW CO2 does not work in portal. Had to download all the data
#   - Need to figure out how the IWT portal handles EST vs EDT

# 1. Libraries and work space ----------------------------------------------

remove(list = ls())

library(xts)
library(dygraphs)
library(lubridate)
library(tidyverse)
library(stringr)

source("functions/prelim_plot.R")

data_dir <- "data/2021/"

# 2. Read in the data -----------------------------------------------------

data_exHB <- read_csv(paste0(data_dir,"BC_CO2_20210802_20211217.csv")) %>% 
  mutate("Timestamp" = mdy_hm(`Measurement Time`)) %>% 
  select(-c(`Measurement Time`, )) %>% 
  rename("XB_SW_CO2" = `Gnarly Bay - 145C CO2`) %>% 
  rename


data_exHB <- data_exHB %>% 
  pivot_longer(cols = )

letc <- ggplot(data = data_exHB,
               mapping = aes(x = Timestamp, 
                             y = GB_SW_CO2)) +
  geom_line()

(letc)









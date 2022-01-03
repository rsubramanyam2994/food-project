library(plyr)
library(dplyr)
source("./usfda-api/sr-legacy-scraper/fns-helpers.R")
options(stringsAsFactors = FALSE)

foundation_foods_flat_df <- readRDS("/Users/subramanyam/subbu/food-project/cache/sr_legacy_merged")
nutrient_codes_df <- readRDS("/Users/subramanyam/subbu/food-project/cache/nutrient_codes_df")
unique_foods <- readRDS("/Users/subramanyam/subbu/food-project/cache/unique_foods") 
food_portions_raw <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions_raw") 

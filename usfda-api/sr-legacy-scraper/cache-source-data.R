source("./usfda-api/sr-legacy-scraper/fns-helpers.R")

library(stringr)
library(plyr)
library(dplyr)


source_json <- jsonlite::fromJSON(readLines(paste0("/Users/subramanyam/Downloads/FoodData_Central_sr_legacy_food_json_2021-10-28.json")))  

foundation_foods_df <- read_foundation_food_data(source_json)
saveRDS(foundation_foods_df, "/Users/subramanyam/subbu/food-project/cache/foundation_foods_df")

food_ndb_mapping <- get_food_ndb_mapping(c("fruits", "vegetables", "nuts", "grains", "oil", "processed-grains", "legumes", "processed", "custom"))
saveRDS(food_ndb_mapping, "/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 

metadata <- get_metadata(source_json)

food_portions = get_food_portions(source_json, metadata) %>% filter(ndb_number %in% food_ndb_mapping$ndb_number) %>% 
  mutate(modifier = str_replace(modifier, "tablespoon", "tbsp"))
saveRDS(food_portions, "/Users/subramanyam/subbu/food-project/cache/food_portions")

# conversion_factors <- get_conversion_factors(source_json)

unique_nutrients <- unique(foundation_foods_df[c("nutrient_name", "nutrient_number")])
unique_foods <- unique(foundation_foods_df[c("food_category", "food_description", "ndb_number")])
measureable_nutrients <- get_measured_nutrients()

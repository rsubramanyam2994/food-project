source("./usfda-api/R/fns-source-transform.R")

library(stringr)
library(plyr)
library(dplyr)


wd = paste0(getwd(), "/cache/")

source_json <- jsonlite::fromJSON(readLines(paste0("/Users/subramanyam/Downloads/FoodData_Central_sr_legacy_food_json_2021-10-28.json")))
saveRDS(source_json, paste0(wd, "source_json"))

foundation_foods_df <- read_foundation_food_data(source_json)
saveRDS(foundation_foods_df, paste0(wd, "foundation_foods_df"))

food_ndb_mapping <- get_food_ndb_mapping(c("fruits", "vegetables", "nuts", "grains", "oil", "processed-grains", "legumes", "processed", "dairy", "custom"))
saveRDS(food_ndb_mapping, paste0(wd, "food_ndb_mapping")) 

metadata <- get_metadata(source_json)

food_portions = get_food_portions(source_json, metadata) %>% filter(ndb_number %in% food_ndb_mapping$ndb_number) %>% 
  mutate(modifier = str_replace(modifier, "tablespoon", "tbsp"))
saveRDS(food_portions, paste0(wd, "food_portions"))

conversion_factors <- get_conversion_factors(source_json)
saveRDS(conversion_factors, paste0(wd, "conversion_factors"))

unique_nutrients <- unique(foundation_foods_df[c("nutrient_name", "nutrient_number")])
saveRDS(unique_nutrients, paste0(wd, "unique_nutrients"))

unique_foods <- unique(foundation_foods_df[c("food_category", "food_description", "ndb_number")])
saveRDS(unique_foods, paste0(wd, "unique_foods"))


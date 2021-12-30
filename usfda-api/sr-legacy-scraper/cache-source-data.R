source("./usfda-api/sr-legacy-scraper/fns-helpers.R")

library(stringr)
library(plyr)
library(dplyr)


# source_json <- jsonlite::fromJSON(readLines(paste0("/Users/subramanyam/Downloads/FoodData_Central_sr_legacy_food_json_2021-10-28.json")))  
# saveRDS(source_json, "/Users/subramanyam/subbu/food-project/cache/source_json")

source_json <- readRDS("/Users/subramanyam/subbu/food-project/cache/source_json")

foundation_foods_df <- read_foundation_food_data(source_json)
saveRDS(foundation_foods_df, "/Users/subramanyam/subbu/food-project/cache/foundation_foods_df")

food_ndb_mapping <- get_food_ndb_mapping(c("fruits", "vegetables", "nuts", "grains", "oil", "processed-grains", "legumes", "processed", "dairy", "custom"))
saveRDS(food_ndb_mapping, "/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 

metadata <- get_metadata(source_json)

food_portions = get_food_portions(source_json, metadata) %>% filter(ndb_number %in% food_ndb_mapping$ndb_number) %>% 
  mutate(modifier = str_replace(modifier, "tablespoon", "tbsp"))
saveRDS(food_portions, "/Users/subramanyam/subbu/food-project/cache/food_portions")

conversion_factors <- get_conversion_factors(source_json)
saveRDS(conversion_factors, "/Users/subramanyam/subbu/food-project/cache/conversion_factors")


unique_nutrients <- unique(ingredient_nutrition_info[c("nutrient_name", "nutrient_number")])
unique_foods <- unique(ingredient_nutrition_info[c("food_category", "food_description", "ndb_number")])


till_lunch = data.frame(
  time = c("breakfast", "breakfast", "breakfast", "morning-snack", "lunch", "lunch", "lunch", "lunch", "lunch", "lunch"),
  food_name = c("blue-milk", "semolina-semiya", "sambar", "apple-without-skin", "white-rice", "sambar", "beans-carrot-curry", "curd", "my-dal-mix", "papad"),
  quantity = c("0.33 cup", "1 cup", "0.75 cup", "200 g", "4 tbsp", "0.75 cup", "0.75 cup", "0.33 cup", 1, 1),
  stringsAsFactors = FALSE
)

after_lunch = data.frame(
  time = c("evening-snack", "evening-snack", "evening-snack", "evening-snack", "dinner", "dinner", "dinner", "dinner"),
  food_name = c("blue-milk", "my-nut-berry-mix", "banana", "pomegranate", "millet-pongal", "tomato-onion-chutney", "curd", "papad"),
  quantity = c("0.33 cup", 1, "80 g", "50 g", "1.25 cup", "2 tbsp", "0.33 cup", 1),
  stringsAsFactors = FALSE
)

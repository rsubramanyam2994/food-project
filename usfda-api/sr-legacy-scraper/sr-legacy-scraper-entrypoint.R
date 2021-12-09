library(plyr)
library(dplyr)
source("./usfda-api/sr-legacy-scraper/fns-helpers.R")
options(stringsAsFactors = FALSE)

foundation_foods_flat_df <- readRDS("/Users/subramanyam/subbu/food-project/cache/sr_legacy_merged")
nutrient_codes_df <- readRDS("/Users/subramanyam/subbu/food-project/cache/nutrient_codes_df")
unique_foods <- readRDS("/Users/subramanyam/subbu/food-project/cache/unique_foods") 
food_portions_raw <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions_raw") 

# a <- foundation_foods_flat_df %>% filter(ndb_number %in% c("16144", "16069", "16080"))
# a <- unique_foods %>% filter(food_category == "Legumes and Legume Products")
# b <- foundation_foods_flat_df %>% filter(ndb_number == "20038")
# 
# a <- foundation_foods_flat_df %>% filter(str_detect(nutrient_name, "18:3")) %>% filter(str_detect(nutrient_name, "n-6"))

food_ndb_mapping <- data.frame()

for (x in c("fruits", "vegetables", "nuts", "grains", "oil", "processed-grains", "legumes")) {
  food_ndb_mapping = rbind(food_ndb_mapping, read_food_ndb_mapping(x))
}  

# missing_summary <- ddply(food_ndb_mapping, "ndb_number", function(x) {
#   foundation_food = foundation_foods_flat_df %>% filter(ndb_number == x$ndb_number)
#   codes_present = foundation_food$nutrient_number
#   codes_required = nutrient_codes_df$nutrient_code
#   missing_codes_idx = which(!codes_required %in% codes_present)
#   missing_codes = codes_required[missing_codes_idx]
#   missing_nutrient_names_df = nutrient_codes_df %>% filter(nutrient_code %in% missing_codes)
#   missing_nutrient_names = missing_nutrient_names_df$nutrient_name %>% gsub(".*\\.","", .) %>% paste(., collapse = ",")
#   return(data.frame(food_name = x$food_name, missing_info = missing_nutrient_names))
# })


non_cup_food_categories = c("Fruits and Fruit Juices", "Nut and Seed Products", "Vegetables and Vegetable Products")
food_portions = food_portions_raw %>% filter(ndb_number %in% food_ndb_mapping$ndb_number) %>% 
  filter(!(food_category %in% non_cup_food_categories)) %>% mutate(modifier = str_replace(modifier, "tablespoon", "tbsp")) %>% select(food_category, food_description, ndb_number, modifier, gramWeight) %>% filter(ndb_number != "16087")

saveRDS(food_portions, "/Users/subramanyam/subbu/food-project/cache/food_portions")


table(food_portions_required$missing)



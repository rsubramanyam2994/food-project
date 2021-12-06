source("./usfda-api/helpers.R")
library(jsonlite)
library(dplyr)

# Whitelist of files needed - fndds_ingredient_nutrient_value,

# TODO: Map API output to what you see on the UI to the template you have come up with. First for micro and then for macro. Map your template to bunch of nutrient codes
# TODO: Map API output to cup-to-grams or measure_unit.csv to cup-to-grams
# This database provides for all fruits and vegetables
# Foods to add apart from this - rice varieties, dal varieties, oil varieties, milk.
# TODO: How to track food made from mixes

ingredients_info <- read.csv("./data/usfda/fndds_ingredient_nutrient_value.csv", stringsAsFactors = FALSE) %>% clean_colnames
ingredients_info <- ingredients_info[,1:6]

nutrients_info <- read.csv("./data/usfda/nutrient.csv", stringsAsFactors = FALSE) %>% clean_colnames %>% mutate(nutrient_code = as.integer(nutrient_nbr) %>% as.character)
# nutrient_codes <- nutrients_info %>% filter(!is.na(nutrient_code)) %>% select(nutrient_code) %>% distinct
# unique_nutrient_codes <- nutrient_codes$nutrient_code
# length(unique_nutrient_codes)

merged_df <- merge(ingredients_info, nutrients_info) %>% select(ingredient_code, sr_description, name, unit_name, nutrient_value, nutrient_code)
unique_foods <- merged_df %>% group_by(sr_description) %>% summarise(ndb_number = ingredient_code[1]) %>% arrange(ndb_number)

# food_ndb_mapping = read_food_ndb_mapping("vegetables")
# soluble_fiber_to_total_ratio = read_fiber_ratio_file("vegetables")
# populate_macros(merged_df, food_ndb_mapping, soluble_fiber_to_total_ratio, "vegetables")

x = "nuts"
for (x in c("fruits", "vegetables", "nuts")) {
  food_ndb_mapping = read_food_ndb_mapping(x)
  soluble_fiber_to_total_ratio = read_fiber_ratio_file(x)
  populate_macros(merged_df, food_ndb_mapping, soluble_fiber_to_total_ratio, x)
}


# Mung beans sprouted raw, green gram sprouts - 11043
# Moong dal is made from ^

# Fiber sources
# 1. Beetroot - https://healthfully.com/370840-soluble-fiber-beets.html

# Workflow
# 1. update ndb number to food
# 2. add fiber ratio
# 3. Run cup to grams and ensure that the food has a one cup entry.


# food_nutrient <- read.csv("./data/usfda/food_nutrient.csv") %>% clean_colnames

# TODO: How to use food_nutrient_conversion_factor_id
# food_calorie_conversion_factor <- read.csv("./data/usfda/food_calorie_conversion_factor.csv") %>% clean_colnames
# food_nutrient_conversion_factor  <- read.csv("./data/usfda/food_nutrient_conversion_factor.csv") %>% clean_colnames
# food_fat_conversion_factor  <- read.csv("./data/usfda/food_fat_conversion_factor.csv") %>% clean_colnames

# TODO: Can we filter based on this?
# food_category <- read.csv("./data/usfda/food_category.csv") %>% clean_colnames

# TODO: What is food_component
# food_component <- read.csv("./data/usfda/food_component.csv") %>% clean_colnames




source("./usfda-api/sr-legacy-scraper/fns-helpers.R")

library(stringr)
library(plyr)
library(dplyr)
options(stringsAsFactors = FALSE)

ingredient_portions <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions")
ingredient_ndb_mapping <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 
ingredient_nutrition_info <- readRDS("/Users/subramanyam/subbu/food-project/cache/foundation_foods_df")
# conversion_factors <- readRDS("/Users/subramanyam/subbu/food-project/cache/conversion_factors")
measureable_nutrients = get_measured_nutrients()

diet = rbind(till_lunch, after_lunch) %>% split_quantity
high_level_summary = get_nutrition_info(diet, ingredient_ndb_mapping, ingredient_portions, ingredient_nutrition_info)


recipe_macros <- (get_macros_summary(high_level_summary))$macro_analysis
recipe_fat <- (get_macros_summary(high_level_summary))$fat_analysis


# summary per recipe
# summary per meal time
# day summary

# Types of summary
# level 1 summary - all types of fat, protein, carb, sodium, fiber, carbohydrates, calories
# TODO: Add required fat in level in summary  
  
# micro summary
# TODO: Add antioxidants to micro summary  

recipe <- read_recipe("/Users/subramanyam/subbu/food-project/data/recipes/breakfast/pearl-millet-semiya.json", ingredient_ndb_mapping)

gram_multiplication_factors <- get_gram_multiplication_factor(recipe$ingredients_df, ingredient_portions)

high_level_summary <- get_high_level_summary(gram_multiplication_factors, ingredient_nutrition_info, get_measured_nutrients(), recipe)


# filter for relevant ndb_numbers in ingredient_nutrition_info, merge based on ndb_number, multiply amount by mult_factor
# group by nutrient_codes, nutrient_name, merge with measureable_nutrients <- get_measured_nutrients(), filter for macros / micros using search to see summary
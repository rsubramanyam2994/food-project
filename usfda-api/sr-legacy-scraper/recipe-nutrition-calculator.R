source("./usfda-api/sr-legacy-scraper/fns-helpers.R")

library(stringr)
library(plyr)
library(dplyr)

ingredient_portions <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions")
ingredient_ndb_mapping <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 
ingredient_nutrition_info <- readRDS("/Users/subramanyam/subbu/food-project/cache/foundation_foods_df")
# conversion_factors <- readRDS("/Users/subramanyam/subbu/food-project/cache/conversion_factors")

daily_diet = data.frame(
  time = c(),
  recipe = c(""),
  servings = c("1 cup", "")
)


# summary per recipe
# summary per meal time
# level 1 summary - all types of fat, protein, carb, sodium, fiber, carbohydrates
# micro summary

recipe <- read_recipe("/Users/subramanyam/subbu/food-project/data/recipes/breakfast/pearl-millet-semiya.json", ingredient_ndb_mapping)

gram_multiplication_factors <- get_gram_multiplication_factor(recipe$ingredients_df, ingredient_portions)

high_level_summary <- get_high_level_summary(gram_multiplication_factors, ingredient_nutrition_info, get_measured_nutrients(), recipe)

recipe_macros <- (get_macros_summary(high_level_summary, conversion_factors, recipe))$macro_analysis
recipe_fat <- (get_macros_summary(high_level_summary, conversion_factors, recipe))$fat_analysis


# filter for relevant ndb_numbers in ingredient_nutrition_info, merge based on ndb_number, multiply amount by mult_factor
# group by nutrient_codes, nutrient_name, merge with measureable_nutrients <- get_measured_nutrients(), filter for macros / micros using search to see summary
library(stringr)
library(plyr)
library(dplyr)

source("./usfda-api/R/fns-load-env.R")
source("./usfda-api/R/fns-core.R")
source("./usfda-api/R/fns-recipe-nutrition.R") # gives split_quantity to fns-temp.R
source("./usfda-api/R/fns-temp.R")
source("./usfda-api/R/fns-summary.R")

menu_for_a_day <- get_sample_menu_for_a_day()
high_level_summary <- get_high_level_summary(menu_for_a_day)
per_recipe_macros_summary <- get_macro_summary_per_recipe(high_level_summary)
per_meal_macros_summary <- get_macro_summary_per_meal_time(high_level_summary)

# per_recipe_minerals_summary <- get_minerals_summary_per_recipe(high_level_summary)

# Ensure that units used in recipes for sodium and other such things are same as the ones given in usfda data
# Compare units in RDA against units in usfda data
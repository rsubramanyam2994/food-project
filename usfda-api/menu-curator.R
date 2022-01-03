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
per_recipe_summary <- get_summary_per_recipe(high_level_summary)
per_meal_summary <- get_summary_per_meal_time(high_level_summary)

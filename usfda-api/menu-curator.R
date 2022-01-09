library(stringr)
library(plyr)
library(dplyr)

source("./usfda-api/R/fns-load-env.R")
source("./usfda-api/R/fns-core.R")
source("./usfda-api/R/fns-recipe-nutrition.R") # gives split_quantity to fns-temp.R
source("./usfda-api/R/fns-temp.R")
source("./usfda-api/R/fns-summary.R")

menu_for_a_day <- read.csv(paste0(getwd(), "/curations/menu_1.csv"), stringsAsFactors = F) %>% split_quantity
high_level_summary <- get_high_level_summary(menu_for_a_day)
per_recipe_macros_summary <- get_macro_summary_per_recipe(high_level_summary)
per_meal_macros_summary <- get_macro_summary_per_meal_time(high_level_summary)
minerals_summary <- get_minerals_summary(high_level_summary)

# Compare units in RDA against units in usfda data
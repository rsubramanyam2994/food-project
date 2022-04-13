library(stringr)
library(plyr)
library(dplyr)

source("./usfda-api/R/fns-load-env.R")
source("./usfda-api/R/fns-core.R")
source("./usfda-api/R/fns-recipe-nutrition.R")
source("./usfda-api/R/fns-summary.R")

menu_for_a_day <- read.csv(paste0(getwd(), "/curations-2.0/involved-menus/menu-1.csv"), stringsAsFactors = F) %>% split_quantity
high_level_summary <- get_high_level_summary(menu_for_a_day)

per_recipe_macros_summary <- get_macro_summary_per_recipe(high_level_summary)
per_meal_macros_summary <- get_macro_summary_per_meal_time(high_level_summary)

body_weight <- 70
macros_summary <- get_macros_summary(high_level_summary)

fat_micros_summary <- get_fat_micros_summary(high_level_summary)
minerals_summary <- get_minerals_summary(high_level_summary)
vitamins_summary <- get_vitamins_summary(high_level_summary, body_weight)

protein_grams_daily_requirement <- 60
proteins_summary <- get_proteins_summary(high_level_summary, protein_grams_daily_requirement)

micros_summary <- rbind.fill(fat_micros_summary, minerals_summary, vitamins_summary, proteins_summary)

macro_deficiency_stats <- get_macros_deficiency_stats(macros_summary)
micro_deficiency_stats <- get_micros_deficiency_stats(micros_summary)


# TODO:
# Antioxidants RDA analysis

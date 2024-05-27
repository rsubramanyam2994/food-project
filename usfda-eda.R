source("./R/fns-source-transform.R")

library(stringr)
library(plyr)
library(dplyr)

wd = paste0(getwd(), "/cache/")

source_json <- readRDS(paste0(wd, "source_json"))

foundation_foods_df <- read_foundation_food_data(source_json)
saveRDS(foundation_foods_df, paste0(wd, "foundation_foods_df"))

food_ndb_mapping <- get_food_ndb_mapping(c("fruits", "vegetables", "nuts", "grains", "oil", "processed-grains", "legumes", "processed", "dairy", "spices", "custom", "supplements"))
saveRDS(food_ndb_mapping, paste0(wd, "food_ndb_mapping"))

metadata <- get_metadata(source_json)

food_portions = get_food_portions(source_json, metadata) %>% filter(ndb_number %in% food_ndb_mapping$ndb_number) %>% 
  mutate(modifier = str_replace(modifier, "tablespoon", "tbsp"))
saveRDS(food_portions, paste0(wd, "food_portions"))

# conversion_factors <- get_conversion_factors(source_json)
# saveRDS(conversion_factors, paste0(wd, "conversion_factors"))

## EDA
unique_nutrients <- unique(foundation_foods_df[c("nutrient_name", "nutrient_number", "unit")])

unique_foods <- unique(foundation_foods_df[c("food_category", "food_description", "ndb_number")])

required_categories <- c("Cereal Grains and Pasta", "Fats and Oils", "Fruits and Fruit Juices", "Legumes and Legume Products", "Nut and Seed Products", "Spices and Herbs", "Vegetables and Vegetable Products")

ingredient_nutrition_info <- foundation_foods_df %>% filter(food_category %in% required_categories)

vitamin_a <- ingredient_nutrition_info %>% filter(nutrient_number == "320") %>% filter(amount > 0) %>% 
  arrange(desc(amount)) %>% filter(food_category == "Vegetables and Vegetable Products") %>% filter(str_detect(food_description, "raw")) %>% select(food_description, amount)

vitamin_d <- ingredient_nutrition_info %>% filter(nutrient_number == "324") %>% filter(amount > 0) %>% 
  arrange(desc(amount))

vitamin_e <- ingredient_nutrition_info %>% filter(nutrient_number == "323") %>% filter(amount > 0) %>% 
  arrange(desc(amount)) %>% filter(food_category == "Nut and Seed Products")

vitamin_k <- ingredient_nutrition_info %>% filter(nutrient_number %in% c("428", "429", "430")) %>% filter(amount > 0) %>% arrange(desc(amount)) %>% 
  filter(food_category == "Vegetables and Vegetable Products") %>% filter(str_detect(food_description, "raw")) %>% select(food_description, amount)

vitamin_b_1 <- ingredient_nutrition_info %>% filter(nutrient_number == "404") %>% filter(amount > 0) %>% arrange(desc(amount))

vitamin_b_2 <- ingredient_nutrition_info %>% filter(nutrient_number == "405") %>% filter(amount > 0) %>% arrange(desc(amount))

vitamin_b_3 <- ingredient_nutrition_info %>% filter(nutrient_number == "406") %>% filter(amount > 0) %>% arrange(desc(amount))

vitamin_b_5 <- ingredient_nutrition_info %>% filter(nutrient_number == "410") %>% filter(amount > 0) %>% arrange(desc(amount))

vitamin_b_6 <- ingredient_nutrition_info %>% filter(nutrient_number == "415") %>% filter(amount > 0) %>% arrange(desc(amount))

vitamin_b_12 <- ingredient_nutrition_info %>% filter(nutrient_number == "418") %>% filter(amount > 0) %>% arrange(desc(amount))

folate_b9 <- ingredient_nutrition_info %>% filter(nutrient_number == "435") %>% filter(amount > 0) %>% arrange(desc(amount)) %>% 
  filter(food_category %in% c("Vegetables and Vegetable Products", "Cereal Grains and Pasta", "Fruits and Fruit Juices", "Legumes and Legume Products")) %>% 
  filter(str_detect(food_description, "raw")) %>% select(food_category, food_description, amount)

fiber <- ingredient_nutrition_info %>% filter(nutrient_number == "291") %>% filter(amount > 0) %>% arrange(desc(amount))

vitamin_c <- ingredient_nutrition_info %>% filter(nutrient_number == "401") %>% filter(amount > 0) %>% arrange(desc(amount))

calcium <- ingredient_nutrition_info %>% filter(nutrient_number == "301") %>% filter(amount > 0) %>% arrange(desc(amount)) %>% 
  filter(food_category %in% c("Vegetables and Vegetable Products", "Cereal Grains and Pasta", "Fruits and Fruit Juices", "Legumes and Legume Products")) %>% 
  filter(str_detect(food_description, "raw")) %>% select(food_category, food_description, amount)

potassium <- ingredient_nutrition_info %>% filter(nutrient_number == "306") %>% filter(amount > 0) %>% arrange(desc(amount))

magnesium <- ingredient_nutrition_info %>% filter(nutrient_number == "304") %>% filter(amount > 0) %>% arrange(desc(amount))

phosphorous <- ingredient_nutrition_info %>% filter(nutrient_number == "305") %>% filter(amount > 0) %>% arrange(desc(amount))

zinc <- ingredient_nutrition_info %>% filter(nutrient_number == "309") %>% filter(amount > 0) %>% arrange(desc(amount))

copper <- ingredient_nutrition_info %>% filter(nutrient_number == "312") %>% filter(amount > 0) %>% arrange(desc(amount))

manganese <- ingredient_nutrition_info %>% filter(nutrient_number == "315") %>% filter(amount > 0) %>% arrange(desc(amount))

iron <- ingredient_nutrition_info %>% filter(nutrient_number == "303") %>% filter(amount > 0) %>% arrange(desc(amount)) %>% 
  select(food_category, food_description, amount)

fluoride <- ingredient_nutrition_info %>% filter(nutrient_number == "313") %>% filter(amount > 0) %>% arrange(desc(amount))

selenium <- ingredient_nutrition_info %>% filter(nutrient_number == "317") %>% filter(amount > 0) %>% arrange(desc(amount))

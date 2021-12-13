ingredient_portions <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions")
ingredient_ndb_mapping <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 
ingredient_nutrition_info <- readRDS("/Users/subramanyam/subbu/food-project/cache/foundation_foods_df")
measureable_nutrients <- get_measured_nutrients()

recipe <- data.frame(
  ingredient = c("sugar", "salt", "turmeric", "white-rice", "lemon-juice", "groundnut-oil", "potato", "groundnut"),
  quantity = c("1 tsp", "0.5 tsp", "0.25 tsp", "1 cup", "1 tbsp", "2 tsp", "50 grams", "1 tbsp")
)

recipe <- data.frame(
  ingredient = c("vermicelli", "peas", "extra-virgin-olive-oil", "salt"),
  quantity = c("1 cup", "1 tbsp", "1 tbsp", "1.5 tsp")
)

recipe_with_ndb_mapping = merge(recipe, ingredient_ndb_mapping, by.x = "ingredient", by.y = "food_name") %>% split_quantity

gram_multiplication_factors <- get_gram_multiplication_factor(recipe_with_ndb_mapping, ingredient_portions) %>% merge(., recipe_with_ndb_mapping, by = c("ndb_number"))

recipe_nutrition_info <- ingredient_nutrition_info %>% filter(ndb_number %in% gram_multiplication_factors$ndb_number) %>% merge(., gram_multiplication_factors %>% select(-c(amount, unit)), by = c("ndb_number")) %>% mutate(nutrient_number = as.character(nutrient_number)) %>% merge(., measureable_nutrients, by = c("nutrient_number")) %>% 
  transmute(name = ingredient, nutrient = nutrient_name.x, path = nutrient_name.y, amount = amount * mult_factor, unit = unit)

# filter for relevant ndb_numbers in ingredient_nutrition_info, merge based on ndb_number, multiply amount by mult_factor
# group by nutrient_codes, nutrient_name, merge with measureable_nutrients <- get_measured_nutrients(), filter for macros / micros using search to see summary
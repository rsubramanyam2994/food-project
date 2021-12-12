ingredient_portions <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions")
ingredient_ndb_mapping <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 
ingredient_nutrition_info <- readRDS("/Users/subramanyam/subbu/food-project/cache/foundation_foods_df")

poha <- data.frame(
  ingredient = c("sugar", "salt", "turmeric", "white-rice", "lemon-juice", "groundnut-oil", "potato", "groundnut"),
  quantity = c("1 tsp", "0.5 tsp", "0.25 tsp", "1 cup", "1 tbsp", "2 tsp", "50 grams", "1 tbsp")
)

recipe_with_ndb_mapping = merge(poha, ingredient_ndb_mapping, by.x = "ingredient", by.y = "food_name") %>% split_quantity
gram_multiplication_factors <- get_gram_multiplication_factor(recipe_with_ndb_mapping, ingredient_portions)

# filter for relevant ndb_numbers in ingredient_nutrition_info, merge based on ndb_number, multiply amount by mult_factor
# group by nutrient_codes, nutrient_name, merge with measureable_nutrients <- get_measured_nutrients(), filter for macros / micros using search to see summary
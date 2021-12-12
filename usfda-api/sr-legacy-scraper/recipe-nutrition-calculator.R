ingredient_portions <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_portions") %>% rename(gram_weight = gramWeight)
ingredient_ndb_mapping <- readRDS("/Users/subramanyam/subbu/food-project/cache/food_ndb_mapping") 
ingredient_nutrition_info <- readRDS("/Users/subramanyam/subbu/food-project/cache/sr_legacy_merged")


# read custom gathered data -> portions, ingredients info and mapping, rbind to above caches

recipe_1 <- data.frame(
  ingredient = c("sugar", "salt", "turmeric", "white-rice", "lemon-juice", "groundnut-oil", "potato", "groundnut"),
  quantity = c("1 tsp", "0.5 tsp", "0.25 tsp", "1 cup", "1 tbsp", "50 grams", "1 tbsp")
)

get_gram_multiplication_factor()


recipe_2 <- data.frame(
  ingredient = c("sugar", "milk"),
  quantity = c("0.75 tsp", "80 ml")
)



# read food to ndb number mapping

# read recipe, split quantity into units and weights in recipe, get ndb_number mapping for each food description, replace recipe with ndb_numbers

# filter for given ndb numbers from foundation_food, get_conversion_factor per ndb_number, write helpers for cross unit conversion to eventually get grams. output -> ndb_number, gram multiplication factor

# ddply, group by ndb_number, multiply above factor

# macro summary, use unit column to show units

# micro summary, use unit column to show units


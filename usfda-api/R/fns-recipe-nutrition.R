split_quantity <- function(df) {
  unit <- str_replace(df$quantity, "(.*?)\\s", "") %>% str_trim(., "both") 
  amount <- str_replace(df$quantity, "\\s(.*)", "") %>% str_trim(., "both") %>% as.numeric
  
  df %>% select(-quantity) %>% mutate(amount = amount, unit = unit)
}

# TODO: Update signature to make it testable 
convert_to_cups <- function(menu) {
  
  ddply(menu, c("time", "food_name"), function(df) {
    
    if (df$unit == "discrete") {
      return(df)
    }
    
    if (df$unit == "cup") {
      return(df %>% mutate(time = df$time, food_name = df$food_name))
    }
    
    if(df$unit == "tbsp") {
      return(df %>% mutate(time = df$time, food_name = df$food_name, amount = amount / 16, unit = "cup") )
    }
    
    if(df$unit == "tsp") {
      return(df %>% mutate(time = df$time, food_name = df$food_name, amount = amount / 48, unit = "cup"))
    }
    
    if (df$unit == "g") {
      return(df)
    }
  })
}


check_if_all_ingredients_has_mapping <- function(df1, df2) {
  if (nrow(df1) != nrow(df2)) {
    stop(str_interp("Recipe has ingredients that aren't mapped - ${df2$ingredient[which(!df2$ingredient %in% df1$ingredient)]}"))
  }
  
  return(df1)
}


read_recipe <- function(recipe_name) {
  
  available_recipes <- list.files("/Users/subramanyam/subbu/food-project/recipes-3.0", recursive = T, full.names = T)
  index = available_recipes %>% str_detect(., recipe_name) %>% which
  
  if (length(index) == 0) {
    stop(str_interp("${recipe_name} not found"))
  }
  
  # if discrete, oneCupWeightInGrams, totalWeightInGrams can be null, numberOfPeopleWhoCanBeServed = 1
  # handle as recipe
  file_path <- available_recipes[index]
  recipe_file <- jsonlite::fromJSON(readLines(file_path))
  recipe <- recipe_file$ingredients %>% transmute(ingredient = id, quantity = quantity)
  
  recipe_with_ndb_mapping = merge(recipe, ingredient_ndb_mapping, by.x = "ingredient", by.y = "food_name") %>% split_quantity %>% check_if_all_ingredients_has_mapping(., recipe)
  
  recipe_file["ingredients"] = NULL
  
  return(list(ingredients_df = recipe_with_ndb_mapping, metadata = recipe_file))
}


get_high_level_recipe_summary <- function(menu) {
  
  made_from_recipes <- menu %>% filter(!(food_name %in% ingredient_ndb_mapping$food_name)) %>% convert_to_cups
  
  ddply(made_from_recipes, c("time", "food_name"), function(meal) {
    
    print(str_interp("Processing ${meal$food_name}"))
    
    recipe <- read_recipe(meal$food_name)
    recipe$ingredients_df = recipe$ingredients_df %>% mutate(time = meal$time, recipe = meal$food_name)
    mult_factors <- get_gram_multiplication_factor(recipe$ingredients_df)
    portion_factor <- get_portion_factor(recipe, meal)
    
    high_level_summary <- ingredient_nutrition_info %>% filter(ndb_number %in% mult_factors$ndb_number) %>% merge(., mult_factors %>% select(-c(amount, unit)), by = c("ndb_number")) %>% mutate(nutrient_number = as.character(nutrient_number)) %>% merge(., measureable_nutrients, by = c("nutrient_number")) %>% 
      transmute(time = time, recipe = recipe, ingredient = ingredient, nutrient = nutrient_name.x, path = nutrient_name.y, 
                nutrient_number = nutrient_number, amount = round(amount * mult_factor * portion_factor, 2), unit = unit, ndb_number = ndb_number, portion_factor = portion_factor, mult_factor = mult_factor)
    
    return(high_level_summary)
  }) %>% select(-food_name)
  
}


get_high_level_raw_foods_summary <- function(menu) {
  
  eaten_raw <- menu %>% filter(food_name %in% ingredient_ndb_mapping$food_name) %>% merge(., ingredient_ndb_mapping, by.x = "food_name", by.y = "food_name") %>% mutate(recipe = food_name, ingredient = food_name) %>% select(-food_name)
  
  if (nrow(eaten_raw) == 0) {
    return(data.frame())
  }
  
  mult_factors <- get_gram_multiplication_factor(eaten_raw)
  
  ingredient_nutrition_info %>% filter(ndb_number %in% mult_factors$ndb_number) %>% merge(., mult_factors %>% select(-c(amount, unit)), by = c("ndb_number")) %>% mutate(nutrient_number = as.character(nutrient_number)) %>% merge(., measureable_nutrients, by = c("nutrient_number")) %>% 
    transmute(time = time, recipe = recipe, ingredient = ingredient, nutrient = nutrient_name.x, path = nutrient_name.y, nutrient_number = nutrient_number, amount = round(amount * mult_factor, 2), unit = unit, ndb_number = ndb_number, portion_factor = 1, mult_factor = mult_factor)
}


get_high_level_summary <- function(menu) {
  
  ddply(menu, c("time", "food_name"), function(meal) {
    if(nrow(meal) != 1) {
      stop("time cross meals rows greater than 1, please combine the inputs into one")
    }
  })
  
  return(rbind(
    menu %>% get_high_level_raw_foods_summary(),
    menu %>% get_high_level_recipe_summary()
  ))
}
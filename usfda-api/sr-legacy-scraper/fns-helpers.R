read_food_ndb_mapping <- function(string) {
  ndb_mapping_file <- jsonlite::fromJSON(readLines(paste0("./data/usfda-mapping/", string, "/ndb-mapping.json")))
  food_names <- names(ndb_mapping_file)
  names(ndb_mapping_file) <- NULL

  food_ndb_mapping <- data.frame(
    food_name = as.character(food_names),
    ndb_number = unlist(ndb_mapping_file)
  ) %>% mutate(food_name = as.character(food_name))

  return(food_ndb_mapping)
}

read_fiber_ratio_file <- function(string) {
  fiber_ratio_file <- jsonlite::fromJSON(readLines(paste0("./data/usfda-mapping/", string, "/soluble-to-total-fiber-ratio.json")))
  food_names <- names(fiber_ratio_file)
  names(fiber_ratio_file) <- NULL

  soluble_fiber_to_total_ratio <- data.frame(
    food_name = food_names,
    ratio = unlist(fiber_ratio_file)
  ) %>% mutate(food_name = as.character(food_name))

  return(soluble_fiber_to_total_ratio)

}

get_missing_summary <- function(food_ndb_mapping) {
  ddply(food_ndb_mapping, "ndb_number", function(x) {
    foundation_food = foundation_foods_flat_df %>% filter(ndb_number == x$ndb_number)
    codes_present = foundation_food$nutrient_number
    codes_required = nutrient_codes_df$nutrient_code
    missing_codes_idx = which(!codes_required %in% codes_present)
    missing_codes = codes_required[missing_codes_idx]
    missing_nutrient_names_df = nutrient_codes_df %>% filter(nutrient_code %in% missing_codes)
    missing_nutrient_names = missing_nutrient_names_df$nutrient_name %>% gsub(".*\\.","", .) %>% paste(., collapse = ",")
    return(data.frame(food_name = x$food_name, missing_info = missing_nutrient_names))
  })
  
}

get_food_portions <- function(sr_legacy_data, metadata) {
  j <- 1
  food_portions_usfda <- ldply(sr_legacy_data$SRLegacyFoods$foodPortions, function(x) {
    
    # print(j)
    # x = sr_legacy_data$SRLegacyFoods$foodPortions[[96]]
    df = NA
    if ("measureUnit" %in% names(x)) {
      df = x %>% select(-measureUnit) %>% cbind(x$measureUnit)
    } else {
      df = x
    }
    
    if(nrow(df) == 0) {
      df = data.frame(food_description = metadata$food_description[j], ndb_number = metadata$ndb_number[j],
                      food_category = metadata$food_category[j], missing = TRUE)
      j <<- j + 1
      return(df)
    }
    
    df$food_description = metadata$food_description[j]
    df$ndb_number = metadata$ndb_number[j]
    df$food_category = metadata$food_category[j]
    df$missing = FALSE
    
    j <<- j + 1
    
    return(df)
    
  }) %>% select(food_category, food_description, ndb_number, modifier, gram_weight = gramWeight)
  
  food_portions_custom <- jsonlite::fromJSON(readLines("./data/custom-gathered-data/portions.json"))
  
  return(rbind(food_portions_usfda, food_portions_custom) %>% mutate(gram_weight = str_trim(gram_weight, "both") %>% as.numeric))
}

get_food_ndb_mapping <- function(food_types) {
  food_ndb_mapping <- data.frame()
  
  for (x in food_types) {
    food_ndb_mapping = rbind(food_ndb_mapping, read_food_ndb_mapping(x))
  }  
  
  return(food_ndb_mapping)

}

get_metadata <- function(sr_legacy_data) {
  data.frame(
    food_category = sr_legacy_data$SRLegacyFoods$foodCategory$description,
    ndb_number = sr_legacy_data$SRLegacyFoods$ndbNumber,
    food_description = sr_legacy_data$SRLegacyFoods$description
  )
}


get_conversion_factors <- function(sr_legacy_data) {
  metadata <- get_metadata(sr_legacy_data)
  
  i <- 0
  
  output <- ldply(sr_legacy_data$SRLegacyFoods$nutrientConversionFactors, function(x) {
    i <<- i + 1

    if (nrow(x) == 0) {
      return(metadata[i, ])
    }

    conv_factor_df <- x %>% filter(type == ".CalorieConversionFactor")

    if (nrow(conv_factor_df) == 0) {
      return(cbind(metadata[i, ]))
    }
    
    if (nrow(conv_factor_df) != 1) {
      print(conv_factor_df)
      stop("which case is this")
    }

    return(conv_factor_df %>% cbind(metadata[i, ]))

  })
  
}

read_foundation_food_data <- function(usfda_data) {
  
  custom_data <- jsonlite::fromJSON(readLines("/Users/subramanyam/subbu/food-project/data/custom-gathered-data/ingredient-nutrients.json")) %>% ldply %>% select(-.id) %>% 
    mutate()
  
  metadata <- get_metadata(source_json)
  
  i <- 1
  usfda_foundation_foods <- ldply(usfda_data$SRLegacyFoods$foodNutrients, function(x) {
    x <- metadata[i, ] %>% cbind(
      data.frame(nutrient_number = x$nutrient$number,
                 nutrient_name = x$nutrient$name,
                 unit = x$nutrient$unitName,
                 amount = x$amount))
    i <<- i + 1
    return(x)
  })
  
  return(rbind(usfda_foundation_foods, custom_data))
  
}


get_measured_nutrients <- function() {
  nutrient_codes_to_extract_list <- jsonlite::fromJSON("/Users/subramanyam/subbu/food-project/data/usfda-mapping/nutrient-code-mapping.json") %>% unlist(., recursive = TRUE)
  nutrient_codes_df <- data.frame(nutrient_number = nutrient_codes_to_extract_list %>% as.character, row.names = NULL) %>% 
    mutate(nutrient_name = names(nutrient_codes_to_extract_list)) %>% filter(nutrient_number != "missing")
  
  return(nutrient_codes_df)
  
}

split_quantity <- function(df) {
  unit <- str_replace(df$quantity, "(.*?)\\s", "") %>% str_trim(., "both") 
  amount <- str_replace(df$quantity, "\\s(.*)", "") %>% str_trim(., "both") %>% as.numeric
  
  df %>% select(-quantity) %>% mutate(amount = amount, unit = unit)
}

get_gram_multiplication_factor <- function(recipe_with_ndb_mapping, ingredient_portions) {
  relevant_food_portions <- ingredient_portions %>% filter(ndb_number %in% recipe_with_ndb_mapping$ndb_number)
  
  output <- ddply(recipe_with_ndb_mapping, c("ndb_number"), function(df) {

    print(str_interp("Computing factor for ${df$ingredient}"))
    
    from_unit = df$unit
    from_amount = df$amount
    
    if (from_unit == "g" || from_unit == "grams" || from_unit == "gram") {
      return(data.frame(ndb_number = df$ndb_number, mult_factor = from_amount / 100))
    }
    
    available_to_units = relevant_food_portions %>% filter(ndb_number == df$ndb_number)
    
    if (from_unit == "tsp") {
      if ("tsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tsp", "gram_weight"] * from_amount) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tbsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tbsp", "gram_weight"] * from_amount * 0.33) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("cup" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "cup", "gram_weight"] * from_amount * 0.0208333) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      stop(str_interp("No available to_unit for ${df$ingredient}"))
    }
    
    if (from_unit == "tbsp") {
      if ("tbsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tbsp", "gram_weight"] * from_amount) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tsp", "gram_weight"] * from_amount * 3) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("cup" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "cup", "gram_weight"] * from_amount * 0.0625) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      stop(str_interp("No available to_unit for ${df$ingredient}"))
    }
    
    if (from_unit == "cup") {
      if ("cup" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "cup", "gram_weight"] * from_amount) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tbsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tbsp", "gram_weight"] * from_amount * 16) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tsp", "gram_weight"] * from_amount * 48) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      stop(str_interp("No available to_unit for ${df$ingredient}"))
    }
    
    stop("Invalid from unit for ${df$ingredient}")
    
    # same for tbsp and cup
    
  })
  

  return(output %>% merge(recipe_with_ndb_mapping))
  
}

check_if_all_ingredients_has_mapping <- function(df1, df2) {
  if (nrow(df1) != nrow(df2)) {
    stop("Recipe has ingredients that aren't mapped")
  }
  
  return(df1)
}

read_recipe <- function(file_path, ingredient_ndb_mapping) {
  recipe_file <- jsonlite::fromJSON(readLines(file_path))
  recipe <- recipe_file$ingredients %>% transmute(ingredient = id, quantity = quantity)
  
  recipe_with_ndb_mapping = merge(recipe, ingredient_ndb_mapping, by.x = "ingredient", by.y = "food_name") %>% split_quantity %>% check_if_all_ingredients_has_mapping(., recipe)
  
  recipe_file["ingredients"] = NULL
  
  return(list(ingredients_df = recipe_with_ndb_mapping, metadata = recipe_file))
}

get_high_level_summary <- function(gram_multiplication_factors, ingredient_nutrition_info, measureable_nutrients, recipe) {
  ingredient_nutrition_info %>% filter(ndb_number %in% gram_multiplication_factors$ndb_number) %>% merge(., gram_multiplication_factors %>% select(-c(amount, unit)), by = c("ndb_number")) %>% mutate(nutrient_number = as.character(nutrient_number)) %>% merge(., measureable_nutrients, by = c("nutrient_number")) %>% 
    transmute(name = ingredient, nutrient = nutrient_name.x, path = nutrient_name.y, amount = round(amount * mult_factor / recipe$metadata$numberOfPeopleWhoCanBeServed, 2), unit = unit)
}


get_macros_summary <- function(high_level_summary, conversion_factors, recipe_df) {
  
  # TODO: Use conversion factor numbers to compute ratio instead of 4:4:9
  # conversion_factor <- conversion_factors %>% filter(ndb_number %in% recipe_df$ndb_number)
  
  conversion_factor_df <- data.frame(nutrient = c("carbohydrates", "protein", "fat"), factor = c(4, 4, 9))
  
  recipe_summary <- high_level_summary %>% filter(str_detect(path, "macros|calories")) %>% group_by(nutrient, path) %>% summarise(amount = sum(amount), unit = unit[1]) %>% mutate(nutrient = str_replace_all(path, "macros.", "")) %>% 
    filter(!(nutrient %in% c("carbohydrates.sugar", "carbohydrates.starch"))) %>% as.data.frame
  
  macro_analysis <- recipe_summary %>% filter(str_detect(nutrient, "total|protein")) %>% 
    mutate(nutrient = str_replace(nutrient, ".total", "")) %>% merge(conversion_factor_df) %>% 
    mutate(calories = amount * factor) %>% 
    mutate(perc = 100 * (calories / sum(calories)) %>% round(., 2)) %>% select(-c(path)) %>% 
    mutate(recipe_name = recipe$metadata$name)
  
  fat_analysis <- recipe_summary %>% filter(str_detect(nutrient, "fat")) %>% filter(!(nutrient %in% c("fat.total", "fat.trans-fat"))) %>% mutate(perc = 100 * (amount / sum(amount)) %>% round(., 2)) %>% 
    mutate(nutrient = str_replace(nutrient, "fat.", "")) %>% select(-path) %>% mutate(analysis = "fat_analysis") %>% 
    mutate(recipe_name = recipe$metadata$name)
  
  return(list(macro_analysis = macro_analysis, fat_analysis = fat_analysis))
  
}

get_nutrition_info <- function(diet) {
  
  a <- ddply(diet, c("time", "recipe"), function(meal) {
    
    if(nrow(meal) != 1) {
      stop("time cross meals rows greater than 1, please combine the inputs into one")
    }
    
    recipe_name <- meal$recipe
    
    return(meal)
    
    recipe <- read_recipe("/Users/subramanyam/subbu/food-project/data/recipes/breakfast/pearl-millet-semiya.json", ingredient_ndb_mapping)
    
    gram_multiplication_factors <- get_gram_multiplication_factor(recipe$ingredients_df, ingredient_portions)
    
    high_level_summary <- get_high_level_summary(gram_multiplication_factors, ingredient_nutrition_info, get_measured_nutrients(), recipe)
    
    recipe_macros <- (get_macros_summary(high_level_summary, conversion_factors, recipe))$macro_analysis
    recipe_fat <- (get_macros_summary(high_level_summary, conversion_factors, recipe))$fat_analysis
    
    
  })
  
  
}

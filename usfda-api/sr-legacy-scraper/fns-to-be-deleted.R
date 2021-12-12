clean_colnames <- function (df) {
  clean_colnames <- tolower(colnames(df)) %>% str_replace_all(., "\\.", "_")
  colnames(df) <- clean_colnames
  return(df)
}

get_nutrient_code_value <- function(df, code) {
  a <- df %>% filter(nutrient_code == as.character(code)) %>% slice(1)
  if (nrow(a) == 0) {
    return(NULL)
  }
  return(a$nutrient_value %>% as.numeric)
}

populate_macros <- function(merged_df, food_ndb_mapping, soluble_fiber_to_total_ratio, file_path_prefix) {
  
  for (i in seq(1: nrow(food_ndb_mapping))) {
    
    id = food_ndb_mapping[i, ]$food_name
    
    print(str_interp("Creating ${id}"))
    
    food_info <- merged_df %>% filter(ingredient_code == food_ndb_mapping[i, ]$ndb_number)
    total_fiber = get_nutrient_code_value(food_info, 291)
    
    natural_sugars <- 
      total_carbs <- get_nutrient_code_value(food_info, 205)
    
    total_protein <- get_nutrient_code_value(food_info, 203)
    total_cals <- get_nutrient_code_value(food_info, 208)
    
    total_fat <- get_nutrient_code_value(food_info, 204)
    
    soluble_fiber_fraction <- (soluble_fiber_to_total_ratio %>% filter(food_name == id))$ratio
    
    macrocontents <- list(
      id = id,
      fat = list(
        "saturated-fat" = get_nutrient_code_value(food_info, 606),
        "mono-unsaturated" = get_nutrient_code_value(food_info, 645),
        "poly-unsaturated" = get_nutrient_code_value(food_info, 646),
        "total" = total_fat
      ),
      protein = total_protein,
      carbohydrates = list(
        "natural-sugars" = get_nutrient_code_value(food_info, 269),
        "added-sugars" = 0,
        "starch" = total_carbs - natural_sugars,
        "fiber" = list(
          "soluble-fiber" = soluble_fiber_fraction * total_fiber,
          "insoluble-fiber" = (1 - soluble_fiber_fraction) * total_fiber
        ),
        "total" = total_carbs
      ),
      cholesterol = get_nutrient_code_value(food_info, 601),
      calories = total_cals
    )
    
    fileConn <- file(paste0("./data/macros/", file_path_prefix, "/", id, ".json"))
    writeLines(jsonlite::toJSON(macrocontents, pretty=TRUE, auto_unbox=TRUE), fileConn)
    close(fileConn)
    
    # Note: Not including theobromine, caffeine, retinol, *carotene*, lycopene, lutein, zeaxanthin
    # TODO: Find values for proteins and missing vitamins and minerals
    # TODO: Classify omega-3 and omega-6 subdivisions for fat
    
    microcontents <- list(
      id = id,
      protein = list(
        essential = list(
          "histidine" = NULL, 
          "isoleucine" = NULL, 
          "leucine" = NULL, 
          "lysine" = NULL, 
          "methionine" = NULL, 
          "phenylalanine" = NULL, 
          "threonine" = NULL, 
          "tryptophan" = NULL, 
          "valine" = NULL
        ),
        "non-essential" = list(
          "alanine" = NULL,
          "asparagine" = NULL,
          "aspartic-acid" = NULL,
          "glutamic-acid" = NULL
        ),
        conditional = list(
          "arginine" = NULL,
          "cysteine" = NULL,
          "glutamine" = NULL,
          "tyrosine" = NULL,
          "glycine" = NULL,
          "ornithine" = NULL,
          "proline" = NULL,
          "serine" = NULL
        )
      ),
      minerals = list(
        macrominerals = list(
          "calcium" = get_nutrient_code_value(food_info, 301),
          "phosphorous" = get_nutrient_code_value(food_info, 305),
          "magnesium" = get_nutrient_code_value(food_info, 304),
          "sodium" = get_nutrient_code_value(food_info, 307),
          "potassium" = get_nutrient_code_value(food_info, 306),
          "chloride" = NULL,
          "sulfur" = NULL
        ),
        traceminerals = list(
          "iron" = get_nutrient_code_value(food_info, 303),
          "manganese" = NULL,
          "copper" = get_nutrient_code_value(food_info, 312),
          "iodine" = NULL, 
          "zinc" = get_nutrient_code_value(food_info, 309),
          "cobalt" = NULL, 
          "fluoride" = NULL,
          "selenium" = get_nutrient_code_value(food_info, 317)
        )
      ),
      others = list(
        theobromine = get_nutrient_code_value(food_info, 263),
        caffeine = get_nutrient_code_value(food_info, 262)
      ),
      vitamins = list(
        "fat-soluble" = list(
          "vitamin-A" = get_nutrient_code_value(food_info, 320),
          "vitamin-D" = get_nutrient_code_value(food_info, 328),
          "vitamin-E" = get_nutrient_code_value(food_info, 323),
          "vitamin-K" = get_nutrient_code_value(food_info, 430)
        ),
        "water-soluble" = list(
          "vitamin-C" = get_nutrient_code_value(food_info, 401),
          "vitamin-B1" = get_nutrient_code_value(food_info, 404),
          "vitamin-B2" = get_nutrient_code_value(food_info, 405),
          "vitamin-B3" = get_nutrient_code_value(food_info, 406),
          "vitamin-B6" = get_nutrient_code_value(food_info, 415),
          "vitamin-B9" = get_nutrient_code_value(food_info, 417),
          "vitamin-B12" = get_nutrient_code_value(food_info, 418),
          "vitamin-B5" = NULL,
          "vitamin-B7" = NULL
        ),
        others = list(
          choline = get_nutrient_code_value(food_info, 421)
        )
      )
    )
    
    
    fileConn <- file(paste0("./data/micros/", file_path_prefix, "/", id, ".json"))
    writeLines(jsonlite::toJSON(microcontents, pretty=TRUE, auto_unbox=TRUE), fileConn)
    close(fileConn)
    
  }
}
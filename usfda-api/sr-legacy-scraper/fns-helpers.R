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
  
  return(rbind(food_portions_usfda, food_portions_custom))
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
  
  i <- 0
  
  output <- ldply(sr_legacy_data$SRLegacyFoods$nutrientConversionFactors, function(x) {
    i <<- i + 1

    if (nrow(x) == 0) {
      return(data.frame(s_no = i, proteinValue = NA))
    }

    conv_factor_df <- x %>% filter(type == ".CalorieConversionFactor")

    if (nrow(conv_factor_df) == 0) {
      return(data.frame(foo = NA))
    }

    return(conv_factor_df)

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
  nutrient_codes_df <- data.frame(nutrient_code = nutrient_codes_to_extract_list, row.names = NULL) %>% 
    mutate(nutrient_name = names(nutrient_codes_to_extract_list)) %>% filter(nutrient_code != "missing")
  
  return(nutrient_codes_df)
  
}
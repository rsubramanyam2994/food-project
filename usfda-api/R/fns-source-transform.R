read_foundation_food_data <- function(source_json) {
  
  custom_data <- read.csv("/Users/subramanyam/subbu/food-project/data/custom-gathered-data/ingredient-nutrients.csv") %>% mutate(ndb_number = as.integer(ndb_number), amount = as.numeric(amount))
  
  # custom_data <- jsonlite::fromJSON(readLines("/Users/subramanyam/subbu/food-project/data/custom-gathered-data/ingredient-nutrients.json")) %>% ldply %>% select(-.id)
  
  metadata <- get_metadata(source_json)
  
  i <- 1
  usfda_foundation_foods <- ldply(source_json$SRLegacyFoods$foodNutrients, function(x) {
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


get_metadata <- function(sr_legacy_data) {
  data.frame(
    food_category = sr_legacy_data$SRLegacyFoods$foodCategory$description,
    ndb_number = sr_legacy_data$SRLegacyFoods$ndbNumber,
    food_description = sr_legacy_data$SRLegacyFoods$description
  )
}


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


get_food_ndb_mapping <- function(food_types) {
  food_ndb_mapping <- data.frame()
  
  for (x in food_types) {
    food_ndb_mapping = rbind(food_ndb_mapping, read_food_ndb_mapping(x))
  }  
  
  return(food_ndb_mapping)
}

get_food_portions <- function(source_json, metadata) {
  j <- 1
  food_portions_usfda <- ldply(source_json$SRLegacyFoods$foodPortions, function(x) {
    
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

library(stringr)

clean_colnames <- function (df) {
  clean_colnames <- tolower(colnames(df)) %>% str_replace_all(., "\\.", "_")
  colnames(df) <- clean_colnames
  return(df)
}

get_nutrient_code_value <- function(df, code) {
  a <- df %>% filter(nutrient_code == as.character(code)) %>% slice(1)
  return(a$nutrient_value %>% as.numeric)
}

populate_macros <- function(merged_df, food_ndb_mapping, soluble_fiber_to_total_ratio, file_path_prefix) {
  
  for (i in seq(1: nrow(food_ndb_mapping))) {
    food_info <- merged_df %>% filter(ingredient_code == food_ndb_mapping[i, ]$ndb_number)
    id = food_ndb_mapping[i, ]$food_name
    
    total_fiber = get_nutrient_code_value(food_info, 291) 
    
    saturated_fat = get_nutrient_code_value(food_info, 606) 
    monounsaturated_fat = get_nutrient_code_value(food_info, 645)
    polyunsaturated_fat = get_nutrient_code_value(food_info, 646)
    
    natural_sugars <- get_nutrient_code_value(food_info, 269)
    total_carbs <- get_nutrient_code_value(food_info, 205)
  
    total_protein <- get_nutrient_code_value(food_info, 203)
    total_cals <- get_nutrient_code_value(food_info, 208)
    
    total_fat <- get_nutrient_code_value(food_info, 204)
    
    soluble_fiber_fraction <- (soluble_fiber_to_total_ratio %>% filter(food_name == id))$ratio
    output <- list(
      id = id,
      fat = list(
        "saturated-fat" = saturated_fat,
        "mono-unsaturated" = monounsaturated_fat,
        "poly-unsaturated" = polyunsaturated_fat,
        "total" = total_fat
      ),
      protein = total_protein,
      carbohydrates = list(
        "natural-sugars" = natural_sugars,
        "added-sugars" = 0,
        "starch" = total_carbs - natural_sugars,
        "fiber" = list(
          "soluble-fiber" = soluble_fiber_fraction * total_fiber,
          "insoluble-fiber" = (1 - soluble_fiber_fraction) * total_fiber
        ),
        "total" = total_carbs
      ),
      calories = total_cals
    )
    
    fileConn <- file(paste0("./data/macros/", file_path_prefix, "/", id, ".json"))
    writeLines(jsonlite::toJSON(output, pretty=TRUE, auto_unbox=TRUE), fileConn)
    close(fileConn)
    
  }
}

read_food_ndb_mapping <- function(string) {
  ndb_mapping_file <- jsonlite::fromJSON(readLines(paste0("./data/usfda-mapping/", string, "/ndb-mapping.json")))
  food_names <- names(ndb_mapping_file)
  names(ndb_mapping_file) <- NULL
  
  food_ndb_mapping <- data.frame(
    food_name = food_names,
    ndb_number = unlist(ndb_mapping_file)
  )
  
  return(food_ndb_mapping)
}

read_fiber_ratio_file <- function(string) {
  fiber_ratio_file <- jsonlite::fromJSON(readLines(paste0("./data/usfda-mapping/", string, "/fiber-ratio.json")))
  food_names <- names(fiber_ratio_file)
  names(fiber_ratio_file) <- NULL
  
  soluble_fiber_to_total_ratio <- data.frame(
    food_name = food_names,
    ratio = unlist(fiber_ratio_file)
  )
  
  return(soluble_fiber_to_total_ratio)
  
}

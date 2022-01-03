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



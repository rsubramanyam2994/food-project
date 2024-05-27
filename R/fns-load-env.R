# To load data frames for recipe nutrition calculator
get_measured_nutrients <- function() {
  nutrient_codes_to_extract_list <- jsonlite::fromJSON(paste0(getwd(), "/data/usfda-mapping/nutrient-code-mapping.json")) %>% unlist(., recursive = TRUE)
  nutrient_codes_df <- data.frame(nutrient_number = nutrient_codes_to_extract_list %>% as.character, row.names = NULL) %>% 
    mutate(nutrient_name = names(nutrient_codes_to_extract_list)) %>% filter(nutrient_number != "missing")
  
  return(nutrient_codes_df)
  
}

measureable_nutrients = get_measured_nutrients()

wd = paste0(getwd(), "/cache/")

ingredient_portions <- readRDS(paste0(wd, "food_portions"))
ingredient_ndb_mapping <- readRDS(paste0(wd, "food_ndb_mapping")) 
ingredient_nutrition_info <- readRDS(paste0(wd, "foundation_foods_df"))
rdas_file_path <- paste0(getwd(), "/data/custom-gathered-data/rda-values.json")


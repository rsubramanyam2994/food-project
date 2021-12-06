library(stringr)
library(plyr)
library(dplyr)


sr_legacy_data <- jsonlite::fromJSON(readLines(paste0("/Users/subramanyam/Downloads/FoodData_Central_sr_legacy_food_json_2021-10-28.json")))

metadata <- data.frame(
  s_no = seq(1:7793),
  food_category = sr_legacy_data$SRLegacyFoods$foodCategory$description,
  ndb_number = sr_legacy_data$SRLegacyFoods$ndbNumber,
  food_description = sr_legacy_data$SRLegacyFoods$description
)

# TODO: Use given conversion factors instead of 4:4:9
# i <- 0
# food_conversion_factor <- ldply(sr_legacy_data$SRLegacyFoods$nutrientConversionFactors, function(x) {
#   i <<- i + 1
#   
#   if (nrow(x) == 0) {
#     return(data.frame(s_no = i, proteinValue = ))
#   }
#   
#   conv_factor_df <- x %>% filter(type == ".CalorieConversionFactor")
#   
#   if (nrow(conv_factor_df) == 0) {
#     return(data.frame(foo = NA))
#   }
# 
#   return(conv_factor_df)
#   
# })


food_nutrients = sr_legacy_data$SRLegacyFoods$foodNutrients

i <- 1
foundation_foods_flat_df <- ldply(sr_legacy_data$SRLegacyFoods$foodNutrients, function(x) {
  x <- metadata[i, ] %>% cbind(
    data.frame(nutrient_number = x$nutrient$number,
               nutrient_name = x$nutrient$name,
               unit = x$nutrient$unitName,
               amount = x$amount))
  i <<- i + 1
  return(x)
})

# a <- foundation_foods_flat_df %>% filter(ndb_number == "12152")

unique_nutrients <- unique(foundation_foods_flat_df[c("nutrient_name", "nutrient_number")])

nutrient_codes_to_extract_list <- jsonlite::fromJSON("/Users/subramanyam/subbu/food-project/data/usfda-mapping/nutrient-code-mapping.json") %>% unlist(., recursive = TRUE)

nutrient_codes_df <- data.frame(nutrient_code = nutrient_codes_to_extract_list, row.names = NULL) %>% 
  mutate(nutrient_name = names(nutrient_codes_to_extract_list))


food_ndb_mapping <- data.frame()

for (x in c("fruits", "vegetables", "nuts")) {
  food_ndb_mapping = rbind(food_ndb_mapping, read_food_ndb_mapping(x))
}  

missing_summary <- ddply(food_ndb_mapping, "ndb_number", function(x) {
  foundation_food = foundation_foods_flat_df %>% filter(ndb_number == x$ndb_number)
  codes_present = foundation_food$nutrient_number
  codes_required = nutrient_codes_df$nutrient_code
  missing_codes_idx = which(!codes_required %in% codes_present)
  missing_codes = codes_required[missing_codes_idx]
  missing_nutrient_names_df = nutrient_codes_df %>% filter(nutrient_code %in% missing_codes)
  missing_nutrient_names = missing_nutrient_names_df$nutrient_name %>% gsub(".*\\.","", .) %>% paste(., collapse = ",")
  return(data.frame(food_name = x$food_name, missing_info = missing_nutrient_names))

})




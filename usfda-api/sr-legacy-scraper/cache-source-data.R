library(stringr)
library(plyr)
library(dplyr)

sr_legacy_data <- jsonlite::fromJSON(readLines(paste0("/Users/subramanyam/Downloads/FoodData_Central_sr_legacy_food_json_2021-10-28.json")))

metadata <- data.frame(
  s_no = seq(1:7793),
  food_category = sr_legacy_data$SRLegacyFoods$foodCategory$description,
  ndb_number = sr_legacy_data$SRLegacyFoods$ndbNumber,
  food_description = sr_legacy_data$SRLegacyFoods$description,
  stringsAsFactors = FALSE
)

# j <- 1
# food_portions_raw <- ldply(sr_legacy_data$SRLegacyFoods$foodPortions, function(x) {
#   
#   print(j)
#   # x = sr_legacy_data$SRLegacyFoods$foodPortions[[96]]
#   df = NA
#   if ("measureUnit" %in% names(x)) {
#     df = x %>% select(-measureUnit) %>% cbind(x$measureUnit)
#   } else {
#     df = x
#   }
#   
#   if(nrow(df) == 0) {
#     df = data.frame(food_description = metadata$food_description[j], ndb_number = metadata$ndb_number[j],
#                     food_category = metadata$food_category[j], missing = TRUE)
#     j <<- j + 1
#     return(df)
#   }
#   
#   df$food_description = metadata$food_description[j]
#   df$ndb_number = metadata$ndb_number[j]
#   df$food_category = metadata$food_category[j]
#   df$missing = FALSE
#   
#   j <<- j + 1
#   
#   return(df)
#   
# })

saveRDS(food_portions_raw, "/Users/subramanyam/subbu/food-project/cache/food_portions_raw")

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

saveRDS(foundation_foods_flat_df, "/Users/subramanyam/subbu/food-project/cache/sr_legacy_merged")

unique_nutrients <- unique(foundation_foods_flat_df[c("nutrient_name", "nutrient_number")])
nutrient_codes_to_extract_list <- jsonlite::fromJSON("/Users/subramanyam/subbu/food-project/data/usfda-mapping/nutrient-code-mapping.json") %>% unlist(., recursive = TRUE)

nutrient_codes_df <- data.frame(nutrient_code = nutrient_codes_to_extract_list, row.names = NULL) %>% 
  mutate(nutrient_name = names(nutrient_codes_to_extract_list)) %>% filter(nutrient_code != "missing")


saveRDS(nutrient_codes_df, "/Users/subramanyam/subbu/food-project/cache/nutrient_codes_df")

unique_foods <- unique(foundation_foods_flat_df[c("food_category", "food_description", "ndb_number")])
saveRDS(unique_foods, "/Users/subramanyam/subbu/food-project/cache/unique_foods")

non_saturated_fat_micro_codes <- c("617", "618", "619", "621", "625", "626", "629", "631", "687", "697", "672", "685", "689", "620", "627", "628", "630", "673", "858", "671", "857", "851", "853", "670", "674", "675", "676", "852", "856", "666", "855", "859")

non_saturated_fats <- unique_nutrients %>% filter(nutrient_number %in% non_saturated_fat_micro_codes) %>% arrange(nutrient_number)

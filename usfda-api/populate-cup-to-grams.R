library(httr)
library(dplyr)
source("./usfda-api/helpers.R")

sr_legacy_food <- read.csv("./data/usfda/sr_legacy_food.csv", stringsAsFactors = FALSE) %>% clean_colnames
foundation_food <- read.csv("./data/usfda/foundation_food.csv", stringsAsFactors = FALSE) %>% clean_colnames %>% select(fdc_id, ndb_number) %>% slice(1)
fdc_id_ndb_number_mapping <- rbind(sr_legacy_food, foundation_food)

# food_portions <- read.csv("./data/usfda/food_portion.csv", stringsAsFactors = FALSE)
# 

# for (i in seq(1:food_ndb_mapping)) {
#   df <- food_ndb_mapping[i, ]
#   fdc_id <- fdc_id_ndb_number_mapping %>% filter(ndb_number == df$ndb_number)
#   if (nrow(fdc_id) > 1) {
#     print(paste0("NDB Number: ", df$ndb_number))
#     stop("More than 1 fdc id for given ndb number")
#   }
#   
#   food_fdc_id <- (fdc_id %>% slice(1))$fdc_id
#   food_portion <- food_portions %>% filter(fdc_id == food_fdc_id)
# }

food_ndb_mapping <- read_food_ndb_mapping("vegetables")
merged_df <- merge(fdc_id_ndb_number_mapping, food_ndb_mapping)

# use this API to get food portions. Filter modifier that contain cup and format it. 
# Ensure all foods have entry for "1 cup" measurement


i = 6
for (i in nrow(merged_df)) {
  fdc_id <- merged_df[i, ]$fdc_id %>% as.character
  content <- content(GET(paste0("https://api.nal.usda.gov/fdc/v1/food/", fdc_id, "?api_key=Pr0An0Q5ThXEnjxhYT5J0faZJeTV3k1dVHsV7lqf&nutrients=205")))
  
  a <- content$foodPortions[[2]] %>% data.frame
  
}





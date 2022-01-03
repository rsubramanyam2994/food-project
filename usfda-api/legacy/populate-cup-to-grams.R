library(httr)
library(plyr)
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

food_ndb_mapping <- rbind(read_food_ndb_mapping("vegetables"), read_food_ndb_mapping("fruits")) %>% rbind(read_food_ndb_mapping("nuts")) 

merged_df <- merge(fdc_id_ndb_number_mapping, food_ndb_mapping)

# use this API to get food portions. Filter modifier that contain cup and format it. 
# Ensure all foods have entry for "1 cup" measurement

result = data.frame()
i = 2

for (i in seq(1:nrow(merged_df))) {
  
  print(str_interp("Fetching food portion info for ${merged_df$food_name[i]}"))
  fdc_id <- merged_df[i, ]$fdc_id %>% as.character
  content <- content(GET(paste0("https://api.nal.usda.gov/fdc/v1/food/", 170393, "?api_key=Pr0An0Q5ThXEnjxhYT5J0faZJeTV3k1dVHsV7lqf")))
  formatted_df <- ldply(content$foodPortions, data.frame) %>% mutate(food_name = merged_df$food_name[i])
  
  result <- dplyr::bind_rows(result, formatted_df) 
  
}

a <- ldply(content$foodNutrients, data.frame)




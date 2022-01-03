// https://api.nal.usda.gov/fdc/v1/foods/search?query=apple&pageSize=2&api_key=Pr0An0Q5ThXEnjxhYT5J0faZJeTV3k1dVHsV7lqf

const axios = require("axios")

// fndds_nutrient_value_* has mapping between ndb number and food description
// sr_legacy_food and foundation_food has mapping between ndn number and food id
// List of all nutrient ids mapped to nutrient description are present in food_nutrient.csv

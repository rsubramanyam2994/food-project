# The Food Project

Based on USFDA data available in - https://fdc.nal.usda.gov/download-datasets.html

ndb_number -> Unique number for an ingredient
nutrient_number -> Unique number for a nutrient

# Follow through cache-source-data

- Download data from above link and update path
- Look at all ingredients and get an idea of the foods. This df might also have branded foods.
- Ensure `food_ndb_mapping` has mappings for all of your ingredients. Add custom ingredients or add mapping for existing ingredients
  -- Add custom ingredients to `data/custom-gathered-data/ingredients.json`. I've added salt and sugar alone here.
  -- Add mapping between ndb_number to a standard name within the food project's terminology in `data/usfda-mapping/<category>/ndb-mapping.json`. I've added files for all the vegetarian ingredients I use.
- Read food portions from usfda data
  -- Can extend this by adding portions to `data/custom-gathered-data/portions.json`
  -- This is to make writing recipes easier, else can always give grams
- EDA
  -- To understand top providers of specific nutrients

# Adding custom recipes

1. Create file in recipes/ and ensure to fill all fields. Refer cauliflower-curry.json as a sample file.
2. Ensure all ingredients have an entry in one-cup-to-grams/ in one of the files, else add one.
3. Create a file for the ingredient in macros.json and micros.json which will later be populated using scripts

How to measure a recipe which involves water absorption? (boiling, steaming, etc)

1. Do steps to add a regular recipe as above along with the additional steps below2
2. Add a flag called waterAbsorption: true to the recipe (or can derive this by doing totalWeight - sum of ingredients)

How to measure a recipe which involves deep frying?

1. Do steps to add a regular recipe as above along with the additional steps below
2. Weigh oil before and after frying and compute oil absorption. Add that amount of oil as an ingredient.


# TODO:

- Antioxidants RDA analysis


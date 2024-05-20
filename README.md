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

# Adding a recipe

- Add file to top level `recipes/` folder
- Use correct names to make up the recipe
- Try to use portions in grams if possible, if not, ensure above portions includes an entry for the unit you're using
- Mark discrete:true for recipes that has discrete items, like a roti or taco.

# Adding a meal plan

- Refer meal plans in the `meal-plans/` folder

# Follow through menu curator

- From the menu, convert recipes into the ingredients that make them up and keep ingredients as is
- Based on the amount consumed of each recipe / ingredient, I compute how much of each type of nutrient is received from every recipe / ingredient.
- Once I have nutritional data per ingredient per recipe per meal time, I compute various summary statistics on the same
- I have hard coded RDA values for an Indian adult using ICMR data in `data/custom-gathered-data/rda-values.json`. I compute summary nutrition stats against RDA to see whether it suffices or not

# TODO:

- RDA for Anti-oxidants

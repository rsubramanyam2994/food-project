# For every meal, do below

## Get all possible combos and their general quantity ranges 

## Get a table of the following format -> combo_id, recipe, min_quantity, max_quantity. Ensure combo_id is unique across meals


## Breakfast

### Create fruit combos that make sense to you (based on cutting and vitamin combos), give approx ranges for each fruit
### Do fruit combos for two cases - fruit bowl as breakfast, fruits as add ons, add appropriate tag and use when creating breakfast

# Have separte fns for getting breakfast, lunch and dinner combos which can re-use some generic functions, but also has meal specific logic. Like lunch will have parupu as a must, breakfast will have fruit bowl option

# Have a fixed nut berry snack in the evening for starters. This is just a fixed combo which can be generalised later. Have this as a get evening snack abstraction

# Now generate all possible combinations of combo ids and quantity ranges. Figure out how to do seq(min, max) where range is not numeric

# For each meal, apply per meal limits to do one initial filter (lunch < 500 calories, dinner < 400 calories, etc -> Get these numbers based on input calories)

# For each combo, compute macro stats and micro stats, write function to compute how good a planned meal is:
## Total calories < input
## Saturated fat < 20 grams
## Protein > 10% and < 20%
## Carbs 45 to 65%
## Fat 20 to 30%
## Should meet all non-spike micros

# Suggest supplements based on above stats - Observe stats and figure out how to write this function

# Spike micros
## Vitamin K, Vitamin A, Vitamin C

# Micros which can be 70-80% met daily but will need supplement to reach 100%
## Zinc, Vitamin B3, Selenium


# Likely deficient ones to be satisifed using fortified foods / supplements
# Vitamin B12, Vitamin E


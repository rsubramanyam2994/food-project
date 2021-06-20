How to add a regular recipe to the database?

1. Create file in recipes/ and ensure to fill all fields. Refer cauliflower-curry.json as a sample file.
2. Ensure all ingredients have an entry in one-cup-to-grams/ in one of the files, else add one.
3. Create a file for the ingredient in macros.json and micros.json which will later be populated using scripts
4. Add recipe to fat secret


How to measure a recipe which involves water absorption? (boiling, steaming, etc)
1. Do steps to add a regular recipe as above along with the additional steps below2
2. Add a flag called waterAbsorption: true to the recipe (or can derive this by doing totalWeight - sum of ingredients)


How to measure a recipe which involves deep frying?
1. Do steps to add a regular recipe as above along with the additional steps below
2. Weigh oil before and after frying and compute oil absorption. Add that amount of oil as an ingredient. 

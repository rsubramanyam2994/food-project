How to add a complete recipe to the database?

1. Create file in recipes/ and ensure to fill all fields. Refer gobi-curry.json as a sample file.
2. Ensure all ingredients have an entry in cup-to-grams/ in one of the files, else add one with a TODO:
3. Create a file for the ingredient in macros.json and micros.json which will later be populated using scripts
4. Add recipe to fat secret


How to measure a recipe which involves water absorption? (boiling, steaming, etc)
1. Do steps to add a regular recipe as above along with the additional steps below
2. Measure 1 cup equivalent of vegetables involved before and after steaming and update cup-to-grams with required entries 
3. Add a flag called waterAbsorption: true to ingredients that absorb water

Note: Based on observations, it's not like volume increases significantly when steamed, weight increases though. Difference between after and before can be considered water absorption with the same 
      quantity as before.

Note: Difference between total weight and weight of ingredients will give an idea of water absorption, but if multiple veggies are involved, we won't know how much goes into one vegetable. 

Note: weightPerCup after cooking will include the absorbed water. While computing macros for the same, reduce water absorption. For Fat secret, add water as additional ingredient by doing 
      (final weight - sum of individual ingredients)

get_gram_multiplication_factor <- function(recipe_with_ndb_mapping) {
  relevant_food_portions <- ingredient_portions %>% filter(ndb_number %in% recipe_with_ndb_mapping$ndb_number)
  
  output <- ddply(recipe_with_ndb_mapping, c("ingredient", "time", "ndb_number"), function(df) {
    
    print(str_interp("Computing factor for ${df$ingredient}"))
    
    from_unit = df$unit
    from_amount = df$amount
    
    if (from_unit == "g" || from_unit == "grams" || from_unit == "gram") {
      return(data.frame(ndb_number = df$ndb_number, mult_factor = from_amount / 100))
    }
    

    available_to_units = relevant_food_portions %>% filter(ndb_number == df$ndb_number) %>% group_by(modifier) %>% 
      slice(n()) %>% ungroup() %>% data.frame()
    
    if (from_unit == "tsp") {
      if ("tsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tsp", "gram_weight"] * from_amount) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tbsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tbsp", "gram_weight"] * from_amount * 0.33) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("cup" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "cup", "gram_weight"] * from_amount * 0.0208333) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      stop(str_interp("No available to_unit for ${df$ingredient}"))
    }
    
    if (from_unit == "tbsp") {
      if ("tbsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tbsp", "gram_weight"] * from_amount) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tsp", "gram_weight"] * from_amount * 3) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("cup" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "cup", "gram_weight"] * from_amount * 0.0625) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      stop(str_interp("No available to_unit for ${df$ingredient}"))
    }
    
    if (from_unit == "cup") {
      if ("cup" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "cup", "gram_weight"] * from_amount) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tbsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tbsp", "gram_weight"] * from_amount * 16) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      if ("tsp" %in% available_to_units$modifier) {
        mult_factor = (available_to_units[available_to_units$modifier == "tsp", "gram_weight"] * from_amount * 48) / 100
        return(data.frame(ndb_number = df$ndb_number, mult_factor = mult_factor))
      }
      
      stop(str_interp("No available to_unit for ${df$ingredient}"))
    }
    
    stop("Invalid from unit for ${df$ingredient}")
    
    # same for tbsp and cup
    
  })
  
  
  return(output %>% merge(recipe_with_ndb_mapping))
  
}

get_portion_factor <- function(recipe, meal) {
  if (is.null(recipe$metadata$discrete)) {
    return((recipe$metadata$oneCupWeightInGramsAfterCooking / recipe$metadata$totalWeightInGrams) * meal$amount)
  }
  
  if (recipe$metadata$discrete == TRUE) {
    return(meal$amount)
  }
  
  stop("discrete error")
}
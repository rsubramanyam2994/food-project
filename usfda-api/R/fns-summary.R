get_nutrient_amount <- function(df, nutrient_code) {
  
  nutrient_df <- df %>% filter(nutrient_number == nutrient_code)
  return(sum(nutrient_df$amount))
}


get_macro_perc <- function(df) {

  protein <- get_nutrient_amount(df, "203")
  carbs <- get_nutrient_amount(df, "205") - get_nutrient_amount(df, "291")
  fiber <- get_nutrient_amount(df, "291")
  
  saturated_fat <- get_nutrient_amount(df, "606")
  mufa <- get_nutrient_amount(df, "645")
  pufa <- get_nutrient_amount(df, "646")
  total_fat <- saturated_fat + mufa + pufa
  
  calories <- get_nutrient_amount(df, "208")
  
  total_calories <- protein * 4 + total_fat * 9 + carbs * 4
  
  protein_calories_perc = round(100 * protein * 4 / total_calories, 2)
  fat_calories_perc = round(100 * total_fat * 9 / total_calories, 2)
  carbs_calories_perc = round(100 * carbs * 4 / total_calories, 2)
  mufa_calories_perc = round(100 * mufa * 9 / total_calories, 2)
  pufa_calories_perc = round(100 * pufa * 9 / total_calories, 2)
  
  return(data.frame(protein = protein, protein_calories_perc = protein_calories_perc, 
                    carbs = carbs, carbs_calories_perc = carbs_calories_perc, fiber = fiber, 
                    fat = total_fat, fat_calories_perc = fat_calories_perc, 
                    saturated_fat = saturated_fat, 
                    mufa = mufa, mufa_calories_perc = mufa_calories_perc, 
                    pufa = pufa, pufa_calories_perc = pufa_calories_perc,
                    calories = calories))
}


get_macro_summary_per_recipe <- function(high_level_summary) {
  
  ddply(high_level_summary, c("time", "recipe"), function(df) {
    return(get_macro_perc(df))
  })
  
}


get_macro_summary_per_meal_time <- function(high_level_summary) {
  ddply(high_level_summary, c("time"), function(df) {
    return(get_macro_perc(df))
  }) %>% rbind(get_overall_summary(high_level_summary) %>% mutate(time = "overall"))
}


get_overall_summary <- function(high_level_summary) {
  return(get_macro_perc(high_level_summary))
  
}

get_macros_summary_to_be_deleted <- function(high_level_summary) {
  
  # TODO: Use conversion factor numbers to compute ratio instead of 4:4:9
  # conversion_factor <- conversion_factors %>% filter(ndb_number %in% recipe_df$ndb_number)
  
  conversion_factor_df <- data.frame(nutrient = c("carbohydrates.fiber", "carbohydrates", "protein", "fat"), factor = c(2, 4, 4, 9))
  
  recipe_summary <- high_level_summary %>% filter(str_detect(path, "macros|calories")) %>% group_by(nutrient, path) %>% summarise(amount = sum(amount), unit = unit[1]) %>% mutate(nutrient = str_replace_all(path, "macros.", "")) %>% 
    filter(!(nutrient %in% c("carbohydrates.sugar", "carbohydrates.starch"))) %>% as.data.frame
  
  macro_analysis <- recipe_summary %>% filter(str_detect(nutrient, "total|protein|fiber")) %>% 
    mutate(nutrient = str_replace(nutrient, ".total", "")) %>% merge(conversion_factor_df) %>% 
    mutate(calories = amount * factor) %>% 
    mutate(perc = 100 * (calories / sum(calories)) %>% round(., 2)) %>% select(-c(path))
  
  fat_analysis <- recipe_summary %>% filter(str_detect(nutrient, "fat")) %>% filter(!(nutrient %in% c("fat.total", "fat.trans-fat"))) %>% mutate(perc = 100 * (amount / sum(amount)) %>% round(., 2)) %>% 
    mutate(nutrient = str_replace(nutrient, "fat.", "")) %>% select(-path) %>% mutate(analysis = "fat_analysis")
  
  return(list(macro_analysis = macro_analysis, fat_analysis = fat_analysis))
  
}

get_minerals_summary <- function(high_level_summary) {
  minerals <- high_level_summary %>% filter(str_detect(path, "minerals"))
  
  mineral_names <- lapply(str_split(minerals$path, "\\."), function(x) {
    return(x[4])
  }) %>% unlist
  
  
  minerals_rda_file_path <- paste0(getwd(), "/data/usfda-mapping/rda-values.json")
  
  macro_minerals_rda <- (jsonlite::fromJSON(minerals_rda_file_path))$micros$minerals$`macro-minerals` %>% Filter(length, .) %>% ldply(., data.frame)
  
  trace_minerals_rda <- (jsonlite::fromJSON(minerals_rda_file_path))$micros$minerals$`trace-minerals` %>% Filter(length, .) %>% ldply(., data.frame)
  
  minerals_rda <- rbind(macro_minerals_rda, trace_minerals_rda) %>% 
    mutate(rda = as.numeric(rda), ul = as.numeric(ul)) %>% 
    mutate(required_amount = if_else(!is.na(rda), rda, ai)) %>% 
    mutate(upper_limit = if_else(!is.na(ul), ul, required_amount)) %>% 
    filter(!is.na(required_amount)) %>% 
    transmute(mineral = .id,
              rda = required_amount,
              ul = upper_limit)
  
  minerals_summary <- minerals %>% mutate(mineral = mineral_names) %>% 
    group_by(mineral, unit) %>% 
    summarise(actual_consumed = sum(amount)) %>% merge(minerals_rda) %>% 
    mutate(actual_consumed = paste0(actual_consumed, " ", unit),
           rda = paste0(rda, " ", unit),
           ul = paste0(ul, " ", unit)) %>% select(-unit)
  
  return(minerals_summary)
}


get_macros_rda <- function() {
  return(data.frame(
    macro = c("protein", "carbohydrate", "fat", "saturated-fat", "mufa", "pufa", "fiber"),
    lower_limit = c("10%", "50%", "20%",  "0", "10%", "10%", "30 g"),
    upper_limit = c("20%", "60%", "30%", "10 g", "15%", "15%", "38 g")
  ))
}

get_macros_summary <- function(high_level_summary) {
  
  macros_perc <- get_macro_perc(high_level_summary)
  actual_consumed <- data.frame(
    macro = c("protein", "carbohydrate", "saturated-fat", "mufa", "pufa", "fiber"),
    actual_consumed = c(macros_perc$protein_calories_perc, macros_perc$carbs_calories_perc, 
                        paste0(macros_perc$saturated_fat, " g"), macros_perc$mufa_calories_perc,
                        macros_perc$pufa_calories_perc, paste0(macros_perc$fiber, " g"))
  )
  
  output <- merge(actual_consumed, get_macros_rda())
  
  return(output)
}

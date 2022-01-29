
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
  saturated_fat_calories_perc = round(100 * saturated_fat * 9 / total_calories, 2)
  
  return(data.frame(protein = protein, protein_calories_perc = protein_calories_perc, 
                    carbs = carbs, carbs_calories_perc = carbs_calories_perc, fiber = fiber, 
                    fat = total_fat, fat_calories_perc = fat_calories_perc, 
                    saturated_fat = saturated_fat, saturated_fat_calories_perc = saturated_fat_calories_perc,
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

get_proteins_summary <- function(high_level_summary, daily_protein_requirement) {

  essential_amino_acids_rdas <- (jsonlite::fromJSON(rdas_file_path))$micros$protein$`essential-amino-acids` %>% ldply(., data.frame) %>% mutate(rda = rda * daily_protein_requirement)
  
  proteins <- high_level_summary %>% filter(str_detect(path, "essential-amino")) %>% 
    filter(!str_detect(path, "non-essential-amino"))
  
  protein_names <- lapply(str_split(proteins$path, "\\."), function(x) {
    return(x[4])
  }) %>% unlist
  
  essential_amino_acids_rdas <- essential_amino_acids_rdas %>% 
    mutate(rda = as.numeric(rda)) %>% 
    transmute(element = .id,
              rda = rda)
  
  proteins_summary <- proteins %>% mutate(element = protein_names) %>% 
    group_by(element, unit) %>% 
    summarise(actual_consumed = sum(amount)) %>% merge(essential_amino_acids_rdas) %>% 
    mutate(actual_consumed = paste0(actual_consumed, " ", unit),
           rda = paste0(rda, " ", unit)) %>% select(-unit)
  
  return(proteins_summary)
}


get_vitamins_summary <- function(high_level_summary) {
  vitamins <- high_level_summary %>% filter(str_detect(path, "vitamins"))
  
  vitamin_names <- lapply(str_split(vitamins$path, "\\."), function(x) {
    return(x[4])
  }) %>% unlist
  
  fat_soluble_vitamins_rdas <- (jsonlite::fromJSON(rdas_file_path))$micros$vitamins$`fat-soluble` %>% Filter(length, .) %>% ldply(., data.frame)
  
  water_soluble_vitamins_rdas <- (jsonlite::fromJSON(rdas_file_path))$micros$vitamins$`water-soluble` %>% Filter(length, .) %>% ldply(., data.frame)
  
  vitamins_rda <- rbind(fat_soluble_vitamins_rdas, water_soluble_vitamins_rdas) %>% 
    mutate(rda = as.numeric(rda), ul = as.numeric(ul), ai = as.numeric(ai)) %>% 
    mutate(required_amount = if_else(!is.na(rda), rda, ai)) %>% 
    mutate(upper_limit = if_else(!is.na(ul), ul, required_amount)) %>%
    filter(!is.na(required_amount)) %>% 
    transmute(element = .id,
              rda = required_amount,
              ul = upper_limit)
  
  vitamins_summary <- vitamins %>% mutate(element = vitamin_names) %>% 
    group_by(element, unit) %>% 
    summarise(actual_consumed = sum(amount)) %>% merge(vitamins_rda) %>% 
    mutate(actual_consumed = paste0(actual_consumed, " ", unit),
           rda = paste0(rda, " ", unit),
           ul = paste0(ul, " ", unit)) %>% select(-unit)
  
  return(vitamins_summary)

}

get_fat_micros_summary <- function(high_level_summary) {
  fat_micros <- high_level_summary %>% filter(str_detect(path, "micros.fat.poly"))
  
  omega_3_rdas <- (jsonlite::fromJSON(rdas_file_path))$micros$fat$`poly-unsaturated`$`omega-3` %>% ldply(., function(l) {
    data.frame(l)
  }) %>% mutate(.id = paste0("omega-3.", .id))
  
  omega_6_rdas <- (jsonlite::fromJSON(rdas_file_path))$micros$fat$`poly-unsaturated`$`omega-6` %>% ldply(., function(l) {
    data.frame(l)
  }) %>% mutate(.id = paste0("omega-6.", .id))
  
  fat_micro_rdas <- rbind.fill(omega_3_rdas, omega_6_rdas) %>% 
    mutate(rda = as.numeric(rda), ai = as.numeric(ai)) %>% 
    mutate(required_amount = if_else(!is.na(rda), rda, ai)) %>% 
    transmute(element = .id,
              rda = required_amount)
  
  micro_fat_names <- lapply(str_split(fat_micros$path, "\\."), function(x) {
    return(paste0(x[4], ".", x[5]))
  }) %>% unlist
  
  updated_fat_micros <- fat_micros %>% mutate(element = micro_fat_names) %>% 
    group_by(element, unit) %>% 
    summarise(actual_consumed = sum(amount)) %>% merge(fat_micro_rdas) %>% 
    mutate(actual_consumed = paste0(actual_consumed, " ", unit),
           rda = paste0(rda, " ", unit)) %>% select(-unit)
  
  return(updated_fat_micros)
}

get_minerals_summary <- function(high_level_summary) {
  minerals <- high_level_summary %>% filter(str_detect(path, "minerals"))
  
  mineral_names <- lapply(str_split(minerals$path, "\\."), function(x) {
    return(x[4])
  }) %>% unlist
  
  macro_minerals_rda <- (jsonlite::fromJSON(rdas_file_path))$micros$minerals$`macro-minerals` %>% Filter(length, .) %>% ldply(., data.frame)
  
  trace_minerals_rda <- (jsonlite::fromJSON(rdas_file_path))$micros$minerals$`trace-minerals` %>% Filter(length, .) %>% ldply(., data.frame)
  
  minerals_rda <- rbind(macro_minerals_rda, trace_minerals_rda) %>% 
    mutate(rda = as.numeric(rda), ul = as.numeric(ul)) %>% 
    mutate(required_amount = if_else(!is.na(rda), rda, ai)) %>% 
    mutate(upper_limit = if_else(!is.na(ul), ul, required_amount)) %>% 
    filter(!is.na(required_amount)) %>% 
    transmute(element = .id,
              rda = required_amount,
              ul = upper_limit)
  
  minerals_summary <- minerals %>% mutate(element = mineral_names) %>% 
    group_by(element, unit) %>% 
    summarise(actual_consumed = sum(amount)) %>% merge(minerals_rda) %>% 
    mutate(actual_consumed = paste0(actual_consumed, " ", unit),
           rda = paste0(rda, " ", unit),
           ul = paste0(ul, " ", unit)) %>% select(-unit)
  
  return(minerals_summary)
}


get_macros_rda <- function(body_weight = 70) {
  return(data.frame(
    element = c("protein", "protein-grams", "carbohydrate", "carb-grams", "fat", "fat-grams", "saturated-fat-perc", "saturated-fat-grams", "mufa", "pufa", "fiber", "calories"),
    lower_limit = c("10 %", paste0(0.8 * body_weight, " g"), "50 %", NA, "20 %", NA, "0 %", "0 g", "5 %", "5 %", "30 g", NA),
    upper_limit = c("20 %", paste0(1.2 * body_weight, " g"),  "60 %", NA, "30 %", NA, "5 %", "13 g", "15 %", "15 %", "38 g", NA)
  ))
}

get_macros_summary <- function(high_level_summary, body_weight) {
  
  macros_perc <- get_macro_perc(high_level_summary)
  actual_consumed <- data.frame(
    element = c("protein", "protein-grams", "carbohydrate", "carb-grams", "fat", "fat-grams", "saturated-fat-perc", "saturated-fat-grams", "mufa", "pufa", "fiber"),
    actual_consumed = c(macros_perc$protein_calories_perc, paste0(macros_perc$protein, " g"),
                        macros_perc$carbs_calories_perc, paste0(macros_perc$carbs, " g"),
                        macros_perc$fat_calories_perc, paste0(macros_perc$fat, " g"),
                        macros_perc$saturated_fat_calories_perc,
                        paste0(macros_perc$saturated_fat, " g"), macros_perc$mufa_calories_perc,
                        macros_perc$pufa_calories_perc, paste0(macros_perc$fiber, " g")),
    stringsAsFactors = FALSE
  ) %>% mutate(actual_consumed = 
                 if_else(str_detect(actual_consumed, "g"), actual_consumed, paste0(actual_consumed, " %"))) %>% 
    rbind.fill(data.frame(element = "calories", actual_consumed = paste0(macros_perc$calories, " kcal")))
  
  output <- merge(actual_consumed, get_macros_rda(body_weight))
  
  return(output)
}


extract_num <- function(l) {
  str_split(as.character(l), " ") %>% lapply(., function(l) {
    return(l[1])
  }) %>% unlist %>% as.numeric
}


extract_num_df <- function(df) {
  foo <- lapply(df %>% select(-element), extract_num) %>% data.frame()
  colnames(foo) <- paste0(colnames(foo), "_num")
  cbind(df, foo)
}

get_macros_deficiency_stats <- function(macros_summary) {
  foo <- extract_num_df(macros_summary)
}


get_micros_deficiency_stats <- function(micros_summary) {
  extract_num_df(micros_summary) %>% 
    mutate(ul_num = if_else(is.na(ul_num), 3 * rda_num, ul_num)) %>%
    mutate(consumption_status = "adequate") %>% 
    mutate(consumption_status = if_else(actual_consumed_num < 0.9 * rda_num, "deficient", consumption_status)) %>% 
    mutate(consumption_status = if_else(actual_consumed_num > 1.1 * ul_num, "excess", consumption_status)) %>% 
    mutate(consumption_status = if_else(is.na(ul_num), "adequate", consumption_status)) %>%
    select(-matches('num')) %>% filter(!(element %in% c("fluoride", "vitamin-d", "omega-3.DHA", "omega-3.EPA")))
} 

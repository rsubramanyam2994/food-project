get_sample_menu_for_a_day <- function() {
  till_lunch = data.frame(
    time = c("breakfast", "breakfast", "breakfast", "morning-snack", "lunch", "lunch", "lunch", "lunch", "lunch", "lunch"),
    food_name = c("blue-milk", "semolina-semiya", "sambar", "apple-without-skin", "white-rice", "sambar", "beans-carrot-curry", "curd", "my-dal-mix", "papad"),
    quantity = c("0.33 cup", "1 cup", "0.75 cup", "200 g", "4 tbsp", "0.75 cup", "0.75 cup", "0.33 cup", "1 discrete", "1 discrete"),
    stringsAsFactors = FALSE
  )
  
  after_lunch = data.frame(
    time = c("evening-snack", "evening-snack", "evening-snack", "evening-snack", "dinner", "dinner", "dinner", "dinner"),
    food_name = c("blue-milk", "my-nut-berry-mix", "banana", "pomegranate", "millet-pongal", "tomato-onion-chutney", "curd", "papad"),
    quantity = c("0.33 cup", "2 discrete", "80 g", "50 g", "1.25 cup", "2 tbsp", "0.33 cup", "1 discrete"),
    stringsAsFactors = FALSE
  )
  
  return(rbind(till_lunch, after_lunch) %>% split_quantity)
}
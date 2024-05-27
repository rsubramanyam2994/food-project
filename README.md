# The Food Project

This project contains scripts to explore USFDA (US Food and Drug Administration) data and scripts to curate meal plans and recipes. I have used nutritional content data from USFDA available [here](https://fdc.nal.usda.gov/download-datasets.html) and RDA (Recommended Dietary Allowances) guidelines from a mix of ICMR (Indian Council of Medical Research) data available [here](https://www.fssai.gov.in/upload/advisories/2020/01/5e159e0a809bbLetter_RDA_08_01_2020.pdf) and [here](https://main.icmr.nic.in/sites/default/files/upload_documents/DGI_07th_May_2024_fin.pdf).

Refer https://www.subbusworld.com/articles/how-i-decide-what-to-eat for more context on this project.

# Setup

Before running the scripts, please install the necessary packages used in the scripts. You can do this by running the following command in R console:

```R
install.packages(c("stringr", "plyr", "dplyr"))
```

# usfda-eda.R

This script reads the USFDA data and does some basic EDA on the same. It also stitches custom gathered data with USFDA data. I have pre-cached USFDA data from above link within the cache folder, so you can run this script without having to download anything.

To add custom ingredients

- Add entries to `data/custom-gathered-data/ingredients.json`. I've added a few examples here. This should respect the format of data you see in `foundation_foods_df` in the above script
- Add mapping between ndb_number to a standard name within the food project's terminology in `data/usfda-mapping/<category>/ndb-mapping.json`

To add custom portions info

- Add entries to `data/custom-gathered-data/portions.json`. This is to make writing recipes easier, else can always give grams

# meal-plan-analyzer.R

This script computes the micros and macros of a meal plan and compares it with RDA values hard coded for an Indian adult male as per ICMR guidelines. (Refer `data/custom-gathered-data/rda-values.json`)

Meal plans should be added to the `meal-plans/` folder. I've added one example there.

Custom recipes can be added to the `recipes/` folder. Use correct ingredient names to make up the recipe. Use the same names as in `data/usfda-mapping/<category>/ndb-mapping.json`. Mark discrete:true for recipes that has discrete items, like a roti or taco.

The curator script does the following:

- Break down the menu into the ingredients that make them up
- Compute nutritional value per ingredient x recipe x meal time
- Compare above with the RDA values and compute the percentage of RDA met and figure out which nutrients are excess or deficient.

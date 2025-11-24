#!/usr/bin/env python3
"""
Script to add a new custom ingredient to the food project.
"""

import json
import os

BASE_DIR = "/Users/sm/subbu/food-project"
CUSTOM_NDB_MAPPING = f"{BASE_DIR}/data/usfda-mapping/custom/ndb-mapping.json"
INGREDIENTS_DIR = f"{BASE_DIR}/data/custom-gathered-data/ingredients"
NUTRIENTS_FILE = f"{BASE_DIR}/data/unique-nutrients.json"
NDB_COUNTER_FILE = f"{BASE_DIR}/data/custom-gathered-data/ndb-counter.json"

CATEGORIES = [
    "Cereal Grains and Pasta",
    "Dairy and Egg Products",
    "Fats and Oils",
    "Fruits and Fruit Juices",
    "Legumes and Legume Products",
    "Nut and Seed Products",
    "Spices and Herbs",
    "Vegetables and Vegetable Products",
    "custom"
]


def get_next_ndb_code():
    """Get the next available NDB code."""
    if os.path.exists(NDB_COUNTER_FILE):
        with open(NDB_COUNTER_FILE, 'r') as f:
            data = json.load(f)
            return data['next_ndb_code']
    return 10000005


def save_ndb_counter(next_code):
    """Save the next NDB code to the counter file."""
    with open(NDB_COUNTER_FILE, 'w') as f:
        json.dump({'next_ndb_code': next_code}, f, indent=2)


def load_nutrients():
    """Load the nutrients from unique-nutrients.json."""
    with open(NUTRIENTS_FILE, 'r') as f:
        return json.load(f)


def load_ndb_mapping():
    """Load the current NDB mapping."""
    with open(CUSTOM_NDB_MAPPING, 'r') as f:
        return json.load(f)


def save_ndb_mapping(mapping):
    """Save the NDB mapping."""
    with open(CUSTOM_NDB_MAPPING, 'w') as f:
        json.dump(mapping, f, indent=2)


def choose_category():
    """Prompt user to choose a category."""
    print("\nSelect a food category:")
    for i, cat in enumerate(CATEGORIES, 1):
        print(f"  {i}. {cat}")

    while True:
        try:
            choice = int(input("\nEnter category number: "))
            if 1 <= choice <= len(CATEGORIES):
                return CATEGORIES[choice - 1]
            print("Invalid choice. Please try again.")
        except ValueError:
            print("Please enter a number.")


def get_nutrient_values(nutrients):
    """Prompt user for nutrient values."""
    print("\nEnter nutrient values (press Enter to skip, values are per 100g):")
    print("-" * 60)

    nutrient_data = []

    for nutrient_num, info in nutrients.items():
        name = info['nutrient_name']
        unit = info['unit']

        value = input(f"  {name} ({unit}): ").strip()

        if value:
            try:
                amount = float(value)
                nutrient_data.append({
                    'nutrient_number': int(nutrient_num),
                    'nutrient_name': name,
                    'unit': unit,
                    'amount': amount
                })
            except ValueError:
                print(f"    Invalid number, skipping {name}")

    return nutrient_data


def main():
    print("=" * 60)
    print("Add New Custom Ingredient")
    print("=" * 60)

    # Get ingredient details
    ingredient_key = input("\nIngredient key (lowercase, hyphenated, e.g., 'brown-rice'): ").strip()
    if not ingredient_key:
        print("Ingredient key is required.")
        return

    food_description = input("Food description (e.g., 'Brown Rice, cooked'): ").strip()
    if not food_description:
        food_description = ingredient_key.replace('-', ' ').title()

    # Check if ingredient already exists
    ndb_mapping = load_ndb_mapping()
    if ingredient_key in ndb_mapping:
        print(f"\nError: Ingredient '{ingredient_key}' already exists with NDB code {ndb_mapping[ingredient_key]}")
        return

    # Get next NDB code
    ndb_code = get_next_ndb_code()
    print(f"\nAssigned NDB code: {ndb_code}")

    # Choose category
    category = choose_category()
    print(f"Selected category: {category}")

    # Load nutrients and get values
    nutrients = load_nutrients()
    nutrient_data = get_nutrient_values(nutrients)

    if not nutrient_data:
        print("\nNo nutrient data entered. Aborting.")
        return

    # Build the ingredient data
    ingredient_entries = []
    for nutrient in nutrient_data:
        ingredient_entries.append({
            'food_category': category,
            'ndb_number': ndb_code,
            'food_description': food_description,
            'nutrient_number': nutrient['nutrient_number'],
            'nutrient_name': nutrient['nutrient_name'],
            'unit': nutrient['unit'],
            'amount': nutrient['amount']
        })

    # Preview
    print("\n" + "=" * 60)
    print("Preview:")
    print("=" * 60)
    print(f"Ingredient: {ingredient_key}")
    print(f"Description: {food_description}")
    print(f"Category: {category}")
    print(f"NDB Code: {ndb_code}")
    print(f"Nutrients entered: {len(nutrient_data)}")
    for n in nutrient_data:
        print(f"  - {n['nutrient_name']}: {n['amount']} {n['unit']}")

    # Confirm
    confirm = input("\nSave this ingredient? (y/n): ").strip().lower()
    if confirm != 'y':
        print("Cancelled.")
        return

    # Save ingredient file
    ingredient_file = f"{INGREDIENTS_DIR}/{ingredient_key}.json"
    with open(ingredient_file, 'w') as f:
        json.dump(ingredient_entries, f, indent=2)
    print(f"\nCreated: {ingredient_file}")

    # Update NDB mapping
    ndb_mapping[ingredient_key] = str(ndb_code)
    save_ndb_mapping(ndb_mapping)
    print(f"Updated: {CUSTOM_NDB_MAPPING}")

    # Update counter
    save_ndb_counter(ndb_code + 1)
    print(f"Updated: {NDB_COUNTER_FILE}")

    print("\nIngredient added successfully!")


if __name__ == "__main__":
    main()

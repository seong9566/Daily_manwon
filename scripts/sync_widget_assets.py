import os
import shutil
import json

base_dir = "ios/DailyHomeWidget/Assets.xcassets"
character_src = "assets/images/character"
category_src = "assets/images/category_images"

# Character syncing (already done by cp, but good to have in script)
char_mapping = {
    "보통_clean.png": "CatNormal",
    "초과_clean.png": "CatOver",
    "여유_clean.png": "CatComfortable",
    "위험_clean.png": "CatDanger"
}

# Category syncing
cat_mapping = {
    "food_clean.png": "CategoryFood",
    "coffee_clean.png": "CategoryCoffee",
    "shopping_clean.png": "CategoryShopping",
    "car_clean.png": "CategoryTransport",
    "etc_clean.png": "CategoryEtc"
}

def create_imageset(name, src_file, dest_folder):
    os.makedirs(dest_folder, exist_ok=True)
    
    # Copy file
    dest_filename = f"{name.lower()}.png"
    shutil.copy(src_file, os.path.join(dest_folder, dest_filename))
    
    # Create Contents.json
    contents = {
        "images": [
            {
                "filename": dest_filename,
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(os.path.join(dest_folder, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

print("Starting asset synchronization...")

# Sync Categories
for src_name, dest_name in cat_mapping.items():
    src_path = os.path.join(category_src, src_name)
    dest_path = os.path.join(base_dir, f"{dest_name}.imageset")
    print(f"Creating {dest_name} from {src_name}...")
    create_imageset(dest_name, src_path, dest_path)

print("Synchronization complete!")

#!/bin/bash

# End script if critical issue pops up
set -eo pipefail

# Target directory where images are located
IMAGE_DIR="static/images"

echo "=== Starting WebP image conversion and cleanup ==="

# Find all JPG and PNG files recursively and convert them
find "$IMAGE_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | while read -r img; do
    # Get directory and filename without extension
    dir=$(dirname "$img")
    filename=$(basename "$img")
    name="${filename%.*}"
    
    output_webp="$dir/$name.webp"
    
    echo "Converting: $filename -> ${name}.webp"
    
    # Convert to WebP with 80% quality
    if cwebp -q 80 "$img" -o "$output_webp"; then
        echo "[DELETE ORIGINAL] Removing old format: $img"
        rm "$img"
    else
        echo "[ERROR] Failed to convert $filename, keeping original."
    fi
done

echo "=== Updating references in data and content files ==="

find data content layouts -type f \( -name "*.yml" -o -name "*.toml" -o -name "*.md" -o -name "*.html" \) -exec bash -c '
    for file; do
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # 1. Reemplazar extensiones por .webp
            sed -i "" "s/\.png/\.webp/g; s/\.jpg/\.webp/g; s/\.jpeg/\.webp/g" "$file"
            
        else
            sed -i "s/\.png/\.webp/g; s/\.jpg/\.webp/g; s/\.jpeg/\.webp/g" "$file"
            
        fi
    done
' _ {} +
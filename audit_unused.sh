#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eo pipefail

# Target directories to audit
IMAGE_DIR="static/images"
DOCS_DIR="static/docs"
SEARCH_DIRS="content layouts data config.toml"

echo "=== Starting project asset audit for unused files ==="

# Audit function for files and directories in a given target path
audit_assets() {
    local target_dir="$1"
    local asset_type="$2"
    local unused_count=0
    local total_scanned=0
    
    if [ -d "$target_dir" ]; then
        echo "--- Scanning $asset_type in $target_dir ---"
        
        # Filter SEARCH_DIRS to include only existing paths
        local valid_search_dirs=()
        for dir in $SEARCH_DIRS; do
            [ -e "$dir" ] && valid_search_dirs+=("$dir")
        done
        
        # Process Substitution keeps variables inside the current shell context
        while read -r asset; do
            total_scanned=$((total_scanned + 1))
            filename=$(basename "$asset")
            
            # Search for exact filename reference across valid project directories
            if LC_ALL=C grep -rn "${valid_search_dirs[@]}" -e "$filename" >/dev/null 2>&1; then
                echo "[IN USE] $asset"
            else
                echo "[ORPHAN - UNUSED] $asset"
                # Uncomment the line below to allow automatic deletion of unused files:
                 rm -f "$asset"
                unused_count=$((unused_count + 1))
            fi
        done < <(find "$target_dir" -type f)

        # Cleanup empty directories left behind
        echo "--- Cleaning up empty directories in $target_dir ---"
         find "$target_dir" -mindepth 1 -type d -empty -delete

        echo "--- $asset_type Audit Summary ---"
        echo "Total files scanned: $total_scanned"
        echo "Orphan files found: $unused_count"
        
        if [ "$unused_count" -eq 0 ]; then
            echo "Result: All $asset_type are currently in use across the project."
        fi
    else
        echo "--- Directory '$target_dir' not found. Skipping $asset_type audit. ---"
    fi
}

# Run audit for images
audit_assets "$IMAGE_DIR" "Images"

# Run audit for documents/other static assets 
 audit_assets "$DOCS_DIR" "Documents"

echo "=== All audits completed successfully ==="
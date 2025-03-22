#!/bin/bash

# Process dependencies recursively
# Usage: ./process_dependencies.sh [path_to_base_directory]

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BASE_DIR="${1:-$(pwd)}"
DEPS_DIR="${BASE_DIR}/deps"
INCLUDES_FILE="${BASE_DIR}/deps_generated.h"

# Create deps directory if it doesn't exist
mkdir -p "$DEPS_DIR"

# Initialize the includes file
echo "// Auto-generated dependency includes - DO NOT EDIT" > "$INCLUDES_FILE"
echo "#ifndef DEPS_GENERATED_H" >> "$INCLUDES_FILE"
echo "#define DEPS_GENERATED_H" >> "$INCLUDES_FILE"
echo "" >> "$INCLUDES_FILE"

# Function to process a dependency
process_dependency() {
    local current_dir="$1"
    local config_file="${current_dir}/config.json"
    
    # Check if config.json exists
    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}No config.json found in ${current_dir}, skipping...${NC}"
        return
    fi
    
    echo -e "${GREEN}Processing dependencies in ${current_dir}...${NC}"
    
    # Extract dependencies array from config.json
    local deps_count=$(jq '.dependencies | length' "$config_file")
    
    if [ "$deps_count" -eq 0 ]; then
        echo "No dependencies found."
        return
    fi
    
    # Process each dependency
    for ((i=0; i<deps_count; i++)); do
        local dep_name=$(jq -r ".dependencies[$i].name" "$config_file")
        local dep_path=$(jq -r ".dependencies[$i].path" "$config_file")
        local dep_import=$(jq -r ".dependencies[$i].import" "$config_file")
        
        echo "Found dependency: $dep_name at $dep_path"
        
        # Clone or update the dependency
        local dep_dir="${DEPS_DIR}/${dep_name}"
        if [ ! -d "$dep_dir" ]; then
            echo "Cloning $dep_name..."
            git clone "$dep_path" "$dep_dir" || {
                echo -e "${RED}Failed to clone ${dep_name}${NC}"
                exit 1
            }
        else
            echo "$dep_name already exists, skipping clone."
        fi
        
        # Add include to the generated header
        echo "#include \"deps/${dep_name}/${dep_import}\"" >> "$INCLUDES_FILE"
        
        # Recursively process this dependency's dependencies
        process_dependency "$dep_dir"
    done
}

# Start processing from the base directory
process_dependency "$BASE_DIR"

# Finalize the includes file
echo "" >> "$INCLUDES_FILE"
echo "#endif // DEPS_GENERATED_H" >> "$INCLUDES_FILE"

# Copy the generated deps_generated.h to each dependency directory
for dep_dir in "$DEPS_DIR"/*; do
    if [ -d "$dep_dir" ]; then
        echo "Copying deps_generated.h to $(basename "$dep_dir")"
        cp "$INCLUDES_FILE" "$dep_dir/"
    fi
done

echo -e "${GREEN}All dependencies processed successfully.${NC}" 
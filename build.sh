#!/bin/bash

# Build script for submodule1
# Automates the build process with error handling

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building submodule1...${NC}"

# Setup dependencies recursively
echo "Setting up dependencies..."

# Make the dependency processor executable
chmod +x process_dependencies.sh

# Process dependencies recursively
./process_dependencies.sh || {
    echo -e "${RED}Failed to process dependencies${NC}"
    exit 1
}

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir -p build
fi

# Navigate to build directory
cd build

# Configure with CMake
echo "Running CMake..."
cmake .. || { echo -e "${RED}CMake configuration failed${NC}"; exit 1; }

# Build
echo "Building..."
make || { echo -e "${RED}Build failed${NC}"; exit 1; }

# Read project name from config.json
PROJECT_NAME=$(jq -r '.name' ../config.json)

# Build succeeded
echo -e "${GREEN}Build successful!${NC}"
echo ""
echo "The following artifacts were created:"
echo "  - Static library: $(pwd)/lib${PROJECT_NAME}.a"
echo "  - Test executable: $(pwd)/${PROJECT_NAME}_app"
echo "  - Unit tests: $(pwd)/${PROJECT_NAME}_unit_tests"
echo ""
echo "You can run the test application with:"
echo "  ./${PROJECT_NAME}_app"
echo ""
echo "Run unit tests with:"
echo "  ./${PROJECT_NAME}_unit_tests"

# Return to original directory
cd .. 
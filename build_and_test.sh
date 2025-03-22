#!/bin/bash

# Build and test script for submodule1_1
# Automates the build and testing process with error handling

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== Building and Testing submodule1_1 =====${NC}"

# ===== BUILD PHASE =====
echo -e "\n${BLUE}[1/2] Building module...${NC}"

# Call the build script if it exists, otherwise do the build steps here
if [ -f "./build.sh" ]; then
    ./build.sh || { echo -e "${RED}Build failed${NC}"; exit 1; }
else
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

    # Return to original directory
    cd ..
    
    echo -e "${GREEN}Build successful!${NC}"
fi

# ===== TEST PHASE =====
echo -e "\n${BLUE}[2/2] Running tests...${NC}"

# Check if unit tests executable exists
if [ ! -f "./build/unit_tests" ]; then
    echo -e "${RED}Unit tests executable not found${NC}"
    exit 1
fi

# Run the tests
echo "Executing unit tests..."
./build/unit_tests || { 
    echo -e "${RED}Some tests failed${NC}"
    exit 1
}

# Run the test application
echo -e "\nExecuting test application..."
./build/submodule1_1_app

# All tests passed
echo -e "\n${GREEN}===== BUILD AND TEST SUCCESSFUL =====${NC}"
echo "submodule1_1 has been built and tested successfully." 
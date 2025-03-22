cmake_minimum_required(VERSION 3.10)

# Read project name and version from config.json
file(READ "config.json" CONFIG_CONTENTS)
string(JSON PROJECT_NAME GET ${CONFIG_CONTENTS} "name")
string(JSON VERSION GET ${CONFIG_CONTENTS} "version")

project(${PROJECT_NAME} VERSION ${VERSION} LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Create static library
add_library(${PROJECT_NAME} STATIC submodule1_1.cpp)

# Add include directories
target_include_directories(${PROJECT_NAME} PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Add executable for standalone testing
add_executable(${PROJECT_NAME}_app main.cpp)
target_link_libraries(${PROJECT_NAME}_app PRIVATE ${PROJECT_NAME})

# Testing with Google Test
enable_testing()

# Find GTest
find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})

# Add test executable
add_executable(unit_tests test/test_submodule1_1.cpp submodule1_1.cpp)
target_include_directories(unit_tests PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link against GTest
target_link_libraries(unit_tests PRIVATE ${GTEST_LIBRARIES} pthread)

# Add the test
add_test(NAME Submodule1_1Tests COMMAND unit_tests) 
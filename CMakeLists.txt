cmake_minimum_required(VERSION 3.10)

# Read project name and version from config.json
file(READ "config.json" CONFIG_CONTENTS)
string(JSON PROJECT_NAME GET ${CONFIG_CONTENTS} "name")
string(JSON VERSION GET ${CONFIG_CONTENTS} "version")

project(${PROJECT_NAME} VERSION ${VERSION} LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set source file names based on project name
set(MAIN_SOURCE_FILE "${PROJECT_NAME}.cpp")
set(TEST_SOURCE_FILE "test/test_${PROJECT_NAME}.cpp")

# Dependencies path
set(DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/deps")

# Function to add a dependency and its subdependencies
function(add_dependency_recursive dep_dir)
    if(EXISTS "${dep_dir}/CMakeLists.txt")
        message(STATUS "Adding subdirectory: ${dep_dir}")
        get_filename_component(DEP_NAME ${dep_dir} NAME)
        add_subdirectory("${dep_dir}" "${CMAKE_BINARY_DIR}/deps/${DEP_NAME}")
        
        # If config.json exists, process its dependencies
        if(EXISTS "${dep_dir}/config.json")
            file(READ "${dep_dir}/config.json" DEP_CONFIG_CONTENTS)
            
            # Check if dependencies key exists
            string(JSON HAS_DEPS ERROR_VARIABLE deps_err GET ${DEP_CONFIG_CONTENTS} "dependencies")
            
            if(NOT deps_err)
                # Get number of dependencies
                string(JSON DEP_COUNT ERROR_VARIABLE count_err LENGTH ${DEP_CONFIG_CONTENTS} "dependencies")
                
                if(NOT count_err AND ${DEP_COUNT} GREATER 0)
                    math(EXPR DEP_COUNT "${DEP_COUNT}-1")
                    
                    # Process each dependency
                    foreach(i RANGE 0 ${DEP_COUNT})
                        string(JSON SUB_DEP_NAME ERROR_VARIABLE name_err GET ${DEP_CONFIG_CONTENTS} "dependencies" ${i} "name")
                        
                        if(NOT name_err AND SUB_DEP_NAME)
                            message(STATUS "Processing subdependency: ${SUB_DEP_NAME}")
                            
                            # Recursively add the subdependency
                            if(EXISTS "${DEPS_DIR}/${SUB_DEP_NAME}")
                                add_dependency_recursive("${DEPS_DIR}/${SUB_DEP_NAME}")
                            endif()
                        endif()
                    endforeach()
                endif()
            endif()
        endif()
    else()
        message(WARNING "No CMakeLists.txt found in ${dep_dir}")
    endif()
endfunction()

# Process dependencies from config.json
string(JSON HAS_DEPS ERROR_VARIABLE deps_err GET ${CONFIG_CONTENTS} "dependencies")

if(NOT deps_err)
    # Get number of dependencies
    string(JSON DEPS_COUNT ERROR_VARIABLE count_err LENGTH ${CONFIG_CONTENTS} "dependencies")
    
    if(NOT count_err AND ${DEPS_COUNT} GREATER 0)
        math(EXPR DEPS_COUNT "${DEPS_COUNT}-1")
        
        # Process each primary dependency
        foreach(i RANGE 0 ${DEPS_COUNT})
            string(JSON DEP_NAME ERROR_VARIABLE name_err GET ${CONFIG_CONTENTS} "dependencies" ${i} "name")
            
            if(NOT name_err AND DEP_NAME)
                message(STATUS "Processing dependency: ${DEP_NAME}")
                
                # Add the dependency and its subdependencies recursively
                if(EXISTS "${DEPS_DIR}/${DEP_NAME}")
                    add_dependency_recursive("${DEPS_DIR}/${DEP_NAME}")
                endif()
            endif()
        endforeach()
    endif()
endif()

# Create static library
add_library(${PROJECT_NAME} STATIC ${MAIN_SOURCE_FILE})

# Add include directories
target_include_directories(${PROJECT_NAME} PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${DEPS_DIR}
)

# Get all dependencies for linking
function(get_all_dependencies var dep_dir)
    if(EXISTS "${dep_dir}/CMakeLists.txt")
        # Get the directory name to use as the library name
        get_filename_component(DEP_LIB_NAME ${dep_dir} NAME)
        set(${var} ${${var}} ${DEP_LIB_NAME} PARENT_SCOPE)
        
        # If config.json exists, process its dependencies
        if(EXISTS "${dep_dir}/config.json")
            file(READ "${dep_dir}/config.json" DEP_CONFIG_CONTENTS)
            
            # Check if dependencies key exists
            string(JSON HAS_DEPS ERROR_VARIABLE deps_err GET ${DEP_CONFIG_CONTENTS} "dependencies")
            
            if(NOT deps_err)
                # Get number of dependencies
                string(JSON DEP_COUNT ERROR_VARIABLE count_err LENGTH ${DEP_CONFIG_CONTENTS} "dependencies")
                
                if(NOT count_err AND ${DEP_COUNT} GREATER 0)
                    math(EXPR DEP_COUNT "${DEP_COUNT}-1")
                    
                    # Process each dependency
                    foreach(i RANGE 0 ${DEP_COUNT})
                        string(JSON SUB_DEP_NAME ERROR_VARIABLE name_err GET ${DEP_CONFIG_CONTENTS} "dependencies" ${i} "name")
                        
                        if(NOT name_err AND SUB_DEP_NAME)
                            # Recursively get the subdependency
                            if(EXISTS "${DEPS_DIR}/${SUB_DEP_NAME}")
                                get_all_dependencies(${var} "${DEPS_DIR}/${SUB_DEP_NAME}")
                                set(${var} ${${var}} PARENT_SCOPE)
                            endif()
                        endif()
                    endforeach()
                endif()
            endif()
        endif()
    endif()
endfunction()

# Get all libraries to link against
set(ALL_DEPENDENCIES "")

string(JSON HAS_DEPS ERROR_VARIABLE deps_err GET ${CONFIG_CONTENTS} "dependencies")

if(NOT deps_err)
    # Get number of dependencies
    string(JSON DEPS_COUNT ERROR_VARIABLE count_err LENGTH ${CONFIG_CONTENTS} "dependencies")
    
    if(NOT count_err AND ${DEPS_COUNT} GREATER 0)
        math(EXPR DEPS_COUNT "${DEPS_COUNT}-1")
        
        # Get each primary dependency
        foreach(i RANGE 0 ${DEPS_COUNT})
            string(JSON DEP_NAME ERROR_VARIABLE name_err GET ${CONFIG_CONTENTS} "dependencies" ${i} "name")
            
            if(NOT name_err AND DEP_NAME)
                # Add the dependency and its subdependencies recursively
                if(EXISTS "${DEPS_DIR}/${DEP_NAME}")
                    get_all_dependencies(ALL_DEPENDENCIES "${DEPS_DIR}/${DEP_NAME}")
                endif()
            endif()
        endforeach()
    endif()
endif()

# Link against all dependencies
target_link_libraries(${PROJECT_NAME} PUBLIC ${ALL_DEPENDENCIES})

# Add executable for standalone testing
add_executable(${PROJECT_NAME}_app main.cpp)
target_link_libraries(${PROJECT_NAME}_app PRIVATE ${PROJECT_NAME})

# Testing with Google Test
enable_testing()

# Only define unit tests if we're the main project
if(${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
    # Find GTest
    find_package(GTest REQUIRED)
    include_directories(${GTEST_INCLUDE_DIRS})
    
    # Add test executable with a unique name based on the project
    add_executable(${PROJECT_NAME}_unit_tests ${TEST_SOURCE_FILE} ${MAIN_SOURCE_FILE})
    target_include_directories(${PROJECT_NAME}_unit_tests PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${DEPS_DIR}
    )
    
    # Link against GTest and all dependencies
    target_link_libraries(${PROJECT_NAME}_unit_tests PRIVATE ${GTEST_LIBRARIES} pthread ${ALL_DEPENDENCIES})
    
    # Add the test
    add_test(NAME ${PROJECT_NAME}Tests COMMAND ${PROJECT_NAME}_unit_tests)
endif() 
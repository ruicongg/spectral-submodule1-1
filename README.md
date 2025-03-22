# Submodule1_1

A component library providing additional functionality for Submodule1 in the modular software system.

## Overview

Submodule1_1 is a dependency for Submodule1 that provides specific data retrieval capabilities. It exposes a simple API through the `getInfo()` function, which returns formatted data.

## Features

- Simple API for retrieving data
- Standalone testing capability
- Unit test suite with Google Test

## Installation and Testing

### Prerequisites

- CMake 3.10 or higher
- C++14 compatible compiler
- Google Test (for running tests)

### Building and Testing the Library

The easiest way to get started is to use the combined build and test script:

1. Clone the repository:

   ```
   git clone https://github.com/ruicongg/spectral-submodule1-1.git
   cd spectral-submodule1-1
   ```

2. Run the build and test script:

   ```
   ./build_and_test.sh
   ```

This script will:

- Build the library and all test executables
- Run the unit tests
- Execute the test application
- Report the results

### Building Only

If you only want to build without running tests:

```
./build.sh
```

This will create:

- A static library `libsubmodule1_1.a`
- A test executable `submodule1_1_app`
- Unit tests executable `unit_tests`

### Manual Build Process

If you prefer to build manually, you can follow these steps:

```
mkdir -p build
cd build
cmake ..
make
```

## Usage

### As a Dependency

To use Submodule1_1 in your project:

1. Add it to your project's dependencies in `config.json`:

   ```json
   "dependencies": [
       {
           "name": "submodule1_1",
           "path": "path/to/submodule1_1"
       }
   ]
   ```

2. Include the header in your code:

   ```cpp
   #include "submodule1_1.h"
   ```

3. Call the function:
   ```cpp
   std::string data = submodule1_1::getInfo();
   ```

### Standalone Testing

You can run the included test application to verify functionality:

```
./build/submodule1_1_app
```

### Running Unit Tests

To execute the unit test suite:

```
./build/unit_tests
```

## API Reference

The module provides the following functions:

### `std::string getInfo()`

Returns a string containing data from Submodule1_1.

**Returns:**

- A string with the value "Submodule1_1 data"

**Side effects:**

- Prints "Submodule1_1 function called" to standard output

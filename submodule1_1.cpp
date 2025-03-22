#include "submodule1_1.h"
#include <iostream>

namespace submodule1_1 {

std::string getInfo() {
    std::cout << "Submodule1_1 function called" << std::endl;
    return "Submodule1_1 data";
}

} // namespace submodule1_1
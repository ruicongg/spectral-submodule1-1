#include "../submodule1_1.h"
#include <gtest/gtest.h>

// Test cases
TEST(Submodule1_1Test, GetInfo) {
    std::string info = submodule1_1::getInfo();
    EXPECT_FALSE(info.empty());
    EXPECT_NE(info.find("Submodule1_1 data"), std::string::npos);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
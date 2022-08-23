# A minimal CMakeLists.txt file for the AWS SDK for C++.

# The minimum version of CMake that will work.
cmake_minimum_required(VERSION 3.1)

# The project name.
project(s3-demo)

# Locate the AWS SDK for C++ package.
#
# If the SDK was installed to a specific directory (e.g. by specifying -DCMAKE_INSTALL_PREFIX=/where/it/is
# when building the SDK), then this project should be built with -DCMAKE_PREFIX_PATH=/where/it/is
#
find_package(AWSSDK REQUIRED s3)

# Make binary globally available
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY /usr/local/bin)

# Link to the AWS SDK for C++ shared libraries.
add_definitions(-DUSE_IMPORT_EXPORT)

# The executable name and its source files.
add_executable(s3-demo src/s3-demo.cpp)

# The libraries used by your executable.
target_link_libraries(s3-demo ${AWSSDK_LINK_LIBRARIES})

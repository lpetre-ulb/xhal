cmake_minimum_required(VERSION 2.8.12)
project(xhalutils)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

add_compile_options(-std=c++11)

# Define the xhalcore library
file(GLOB SRCS src/common/utils/*)
add_library(xhalcore SHARED ${SRCS})

target_include_directories(xhalcore PRIVATE include)

find_package(Logc4plus REQUIRED)
target_link_libraries(xhalcore PRIVATE Log4cplus::Log4cplus)

find_package(XercesC REQUIRED)
target_link_libraries(xhalcore PRIVATE XercesC::XercesC)

# Install
install(TARGETS xhalcore
  LIBRARY DESTINATION lib)

install(DIRECTORY include/xhal/utils
  DESTINATION include/xhal)


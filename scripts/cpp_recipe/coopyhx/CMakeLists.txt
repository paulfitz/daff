cmake_minimum_required(VERSION 2.8)

project(coopyhx)

add_definitions(-DHX_LINUX -DHXCPP_DEBUG -DHXCPP_VISIT_ALLOCS -Dhaxe3)
add_definitions(-m32)

file(GLOB_RECURSE folder_headers include/*.h)
file(GLOB_RECURSE folder_sources src/*.cpp)

include_directories(${CMAKE_SOURCE_DIR}/include)
add_executable(coopyhx ${folder_headers} ${folder_sources})
set_target_properties(coopyhx PROPERTIES LINK_FLAGS -m32)

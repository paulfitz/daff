cmake_minimum_required(VERSION 2.8)

project(coopyhx)

add_definitions(-DHX_LINUX -DHXCPP_VISIT_ALLOCS -Dhaxe3 -DHXCPP_FORCE_OBJ_MAP)
# add_definitions(-m32)  # -DHXCPP_M64

file(GLOB_RECURSE folder_headers include/*.h)
file(GLOB_RECURSE folder_sources src/*.cpp)

set(BUILD_SHARED_LIBS ON)

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${CMAKE_SOURCE_DIR})
add_library(coopyhx_core ${folder_headers} ${folder_sources})
# set_target_properties(coopyhx PROPERTIES LINK_FLAGS -m32)
target_link_libraries(coopyhx_core pthread dl)

add_executable(coopyhx_test main.cpp)
# set_target_properties(coopyhx_test PROPERTIES LINK_FLAGS -m32)
target_link_libraries(coopyhx_test coopyhx_core)

set(CREATE_RUBY FALSE CACHE BOOL "Do you want to create the Ruby interface")

if (CREATE_RUBY)
  find_package(SWIG REQUIRED)
  include(${SWIG_USE_FILE})
  message(STATUS "${SWIG_USE_FILE}")
  set_source_files_properties(coopyhx.i PROPERTIES CPLUSPLUS ON)
endif ()

if (CREATE_RUBY)
  find_package(Ruby REQUIRED)
  set(CMAKE_SWIG_FLAGS "-Wall;-module;coopyhx")
  include_directories(${RUBY_INCLUDE_PATH})
  swig_add_module(coopyhx ruby coopyhx.i)
  swig_link_libraries(coopyhx ${RUBY_LIBRARY})
  set_target_properties(coopyhx PROPERTIES PREFIX "")
  target_link_libraries(coopyhx coopyhx_core)
endif (CREATE_RUBY)


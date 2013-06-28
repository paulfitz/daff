
# Make sure we can successfully build haxe-generated cpp from source.
# Note: CPP source should first be compiled with "make cpp_pack" in
# root directory.
# The key point is that everything needed to compile on a system
# without haxe installed is dropped in a "coopyhx" directory in
# the build directory.
#
# Gibberish?  Try ./build_cpp_package.sh

cmake_minimum_required(VERSION 2.8)

project(coopyhx)

# add_definitions(-DHXCPP_DEBUG=1 -DHXCPP_STACK_TRACE=1)
set(REPLACE_MAIN TRUE)

set(CGEN ${CMAKE_SOURCE_DIR}/../../bin)

#include_directories(${CGEN}/include)

# definitions are haxe version dependent - see:
#   /usr/lib/haxe/lib/hxcpp/x,x,x/build-tool/common-defines.xml

##########################################333
## Haxe 2.10.2
#set(HX_BASE /usr/lib/haxe/lib/hxcpp/2,10,2)
#add_definitions(-DHXCPP_VISIT_ALLOCS -Dhaxe_210)

##########################################333
## Haxe 3.0.0
set(HX_BASE /usr/lib/haxe/lib/hxcpp/3,0,0)
add_definitions(-DHX_LINUX=1 -DHXCPP_VISIT_ALLOCS=1 -Dhaxe3=1 -Dhaxe_ver="3.")
# -DHXCPP_DEBUG=1 -DHXCPP_VISIT_ALLOCS=1)
if (NOT REPLACE_MAIN)
  set_property(SOURCE ${CGEN}/src/__main__.cpp
    APPEND PROPERTY COMPILE_DEFINITIONS 
    HX_DECLARE_MAIN=1)
endif ()

# include_directories(${HX_BASE}/include/)
#add_definitions(-DHXCPP_DEBUG)
add_definitions(-include unistd.h) # getpid not found otherwise
add_definitions(-m32) # pointer stored as 32-bit integer in haxe code

file(GLOB folder_source ${CGEN}/src/*.cpp)
file(GLOB folder_source_coopy ${CGEN}/src/coopy/*.cpp)
file(GLOB folder_source_haxe ${CGEN}/src/haxe/*.cpp)
file(GLOB folder_source_haxe_ds ${CGEN}/src/haxe/ds/*.cpp)
file(GLOB folder_source_haxe_io ${CGEN}/src/haxe/io/*.cpp)
file(GLOB folder_source_sys_io ${CGEN}/src/sys/io/*.cpp)
file(GLOB folder_source_cpp ${CGEN}/src/cpp/*.cpp) # this will have to be
# removed, it loads a neko library for hxcpp3; or maybe -Dstatic_link can
# be enough, need to investigate...
file(GLOB_RECURSE folder_header ${CGEN}/include/*.h)

file(GLOB hx_source ${HX_BASE}/src/*.cpp)
list(REMOVE_ITEM hx_source ${HX_BASE}/src/ExampleMain.cpp)
file(GLOB hx_source2 ${HX_BASE}/src/hx/*.cpp)
list(REMOVE_ITEM hx_source2 ${HX_BASE}/src/hx/NekoAPI.cpp)
list(REMOVE_ITEM hx_source2 ${HX_BASE}/src/hx/RunLibs.cpp)
if (REPLACE_MAIN)
  list(REMOVE_ITEM folder_source ${CGEN}/src/__main__.cpp)
  # list(REMOVE_ITEM folder_source ${CGEN}/src/__boot__.cpp)
  list(REMOVE_ITEM folder_source ${CGEN}/src/Sys.cpp)
  list(APPEND folder_source ${CMAKE_SOURCE_DIR}/main.cpp)
endif ()

link_libraries(pthread dl)

set(all_sources ${folder_source} ${folder_source_coopy} ${folder_source_haxe} ${folder_source_haxe_ds} ${folder_source_haxe_io} ${folder_source_sys_io} ${folder_source_cpp} ${folder_source_cpp} ${folder_header} ${hx_source} ${hx_source2} ${CGEN}/src/haxe/Log.cpp)


#set(BUILD_SHARED_LIBS ON)
#set (CMAKE_C_FLAGS "-m32")
#file(GLOB std_source ${CMAKE_SOURCE_DIR}/std/*.c)
#add_library(std ${std_source})


foreach(f ${all_sources})
  set(done FALSE)
  string(REGEX MATCH "^${CGEN}/(.*)" match ${f})
  if (match)
    string(REGEX REPLACE "^${CGEN}/" "" match ${match})
    message(STATUS "Looking at ${f} -> ${match}")
    set (done TRUE)
  endif()
  if (NOT match)
    string(REGEX MATCH "^${HX_BASE}/(.*)" match ${f})
    if (match)
      string(REGEX REPLACE "^${HX_BASE}/" "" match ${match})
      message(STATUS "Looking at ${f} -> ${match}")
      set (done TRUE)
    endif()
  endif()
  if (NOT done)
    message(STATUS "PENDING ${f}")
  else ()
    message(STATUS "MATCH ${match}")
    set(oname ${CMAKE_BINARY_DIR}/coopyhx/${match})
    get_filename_component(dname ${oname} PATH)
    file(MAKE_DIRECTORY ${dname})
    configure_file(${f} ${oname} COPYONLY)
  endif()
      
endforeach()

file(GLOB_RECURSE hx_headers RELATIVE ${HX_BASE} ${HX_BASE}/include/*.h)
file(GLOB_RECURSE hx_headers2 RELATIVE ${HX_BASE} ${HX_BASE}/src/hx/*.h)
foreach (f ${hx_headers} ${hx_headers2}) 
    set(oname ${CMAKE_BINARY_DIR}/coopyhx/${f})
    get_filename_component(dname ${oname} PATH)
    file(MAKE_DIRECTORY ${dname})
    configure_file(${HX_BASE}/${f} ${oname} COPYONLY)
endforeach()

configure_file(coopyhx/CMakeLists.txt ${CMAKE_BINARY_DIR}/coopyhx/ COPYONLY)
configure_file(main.cpp ${CMAKE_BINARY_DIR}/coopyhx/ COPYONLY)

include_directories(${CMAKE_BINARY_DIR}/coopyhx/include)
add_executable(test_coopy ${all_sources})
set_target_properties(test_coopy PROPERTIES LINK_FLAGS -m32)

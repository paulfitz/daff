
# Make sure we can successfully build haxe-generated cpp from source.

cmake_minimum_required(VERSION 2.8)

project(coopyhx)

set(CGEN ${CMAKE_SOURCE_DIR}/../../bin)

include_directories(${CGEN}/include)

# definitions are haxe version dependent - see:
#   /usr/lib/haxe/lib/hxcpp/2,10,2/build-tool/common-defines.xml
set(HX_BASE /usr/lib/haxe/lib/hxcpp/2,10,2)
include_directories(${HX_BASE}/include/)
add_definitions(-DHXCPP_VISIT_ALLOCS -Dhaxe_210)
#add_definitions(-DHXCPP_DEBUG)
add_definitions(-include unistd.h) # getpid not found otherwise
add_definitions(-m32) # pointer stored as 32-bit integer in haxe code

file(GLOB folder_source ${CGEN}/src/*.cpp)
file(GLOB folder_header ${CGEN}/include/*.h)

file(GLOB hx_source ${HX_BASE}/src/*.cpp)
list(REMOVE_ITEM hx_source ${HX_BASE}/src/ExampleMain.cpp)
file(GLOB hx_source2 ${HX_BASE}/src/hx/*.cpp)
list(REMOVE_ITEM hx_source2 ${HX_BASE}/src/hx/NekoAPI.cpp)
list(REMOVE_ITEM hx_source2 ${HX_BASE}/src/hx/RunLibs.cpp)

link_libraries(pthread dl)

add_executable(test_coopy ${folder_source} ${folder_header} ${hx_source} ${hx_source2} ${CGEN}/src/haxe/Log.cpp)
set_target_properties(test_coopy PROPERTIES LINK_FLAGS -m32)


# Make sure we can successfully build haxe-generated cpp from source.

cmake_minimum_required(VERSION 2.8)

project(coopyhx)


set(CGEN ${CMAKE_SOURCE_DIR}/../../bin)

include_directories(${CGEN}/include)

# definitions are haxe version dependent - see:
#   /usr/lib/haxe/lib/hxcpp/x,x,x/build-tool/common-defines.xml

##########################################333
## Haxe 2.10.2
#set(HX_BASE /usr/lib/haxe/lib/hxcpp/2,10,2)
#add_definitions(-DHXCPP_VISIT_ALLOCS -Dhaxe_210)

##########################################333
## Haxe 3.0.0
set(HX_BASE /usr/lib/haxe/lib/hxcpp/3,0,0)
add_definitions(-DHX_LINUX -DHXCPP_DEBUG -DHXCPP_VISIT_ALLOCS -Dhaxe3)
set_property(SOURCE ${CGEN}/src/__main__.cpp
  APPEND PROPERTY COMPILE_DEFINITIONS 
  HX_DECLARE_MAIN=1)

include_directories(${HX_BASE}/include/)
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
file(GLOB folder_header ${CGEN}/include/*.h)

file(GLOB hx_source ${HX_BASE}/src/*.cpp)
list(REMOVE_ITEM hx_source ${HX_BASE}/src/ExampleMain.cpp)
file(GLOB hx_source2 ${HX_BASE}/src/hx/*.cpp)
list(REMOVE_ITEM hx_source2 ${HX_BASE}/src/hx/NekoAPI.cpp)
list(REMOVE_ITEM hx_source2 ${HX_BASE}/src/hx/RunLibs.cpp)

link_libraries(pthread dl)

add_executable(test_coopy ${folder_source} ${folder_source_coopy} ${folder_source_haxe} ${folder_source_haxe_ds} ${folder_source_haxe_io} ${folder_source_sys_io} ${folder_source_cpp} ${folder_source_cpp} ${folder_header} ${hx_source} ${hx_source2} ${CGEN}/src/haxe/Log.cpp)
set_target_properties(test_coopy PROPERTIES LINK_FLAGS -m32)


#set(BUILD_SHARED_LIBS ON)
#set (CMAKE_C_FLAGS "-m32")
#file(GLOB std_source ${CMAKE_SOURCE_DIR}/std/*.c)
#add_library(std ${std_source})



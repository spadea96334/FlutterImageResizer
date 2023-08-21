cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(native_library VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MD")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(../library/opencv/windows/include)
link_directories(../library/opencv/windows/)
add_library(native_library SHARED OpenCVBridge.cpp)

set_target_properties(native_library PROPERTIES
    PUBLIC_HEADER OpenCVBridge.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "native_library"
)

target_link_libraries(native_library ade)
target_link_libraries(native_library IlmImf)
target_link_libraries(native_library ippicvmt)
target_link_libraries(native_library ippiw)
target_link_libraries(native_library libjpeg-turbo)
target_link_libraries(native_library libopenjp2)
target_link_libraries(native_library libpng)
target_link_libraries(native_library libtiff)
target_link_libraries(native_library libwebp)
target_link_libraries(native_library opencv_world480)
target_link_libraries(native_library quirc)
target_link_libraries(native_library zlib)




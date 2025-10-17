# __________________________________________________________________
#
# CMakeList for Mini-PIC
# 
# __________________________________________________________________

cmake_minimum_required (VERSION 3.16)

message(" __________________________________________________________________ \n")
message(" CMakeList for Mini-PIC")
message(" __________________________________________________________________ \n")

# Disable in-source builds to prevent source tree corruption.
if( "${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}" )
 message( FATAL_ERROR "In-source builds are not allowed. You should create a separate directory for build files and delete CMakeCache.txt." )
endif()

# __________________________________________________________________
# Options

# Debug, Release, RelWithDebInfo and MinSizeRel
if (NOT CMAKE_BUILD_TYPE)
 set(
    CMAKE_BUILD_TYPE
    "RelWithDebInfo"
    CACHE
    STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel."
    FORCE
  )
endif()
message(" Build type: ${CMAKE_BUILD_TYPE}")

# Debug and test modes
option(DEBUG "Debug messages" OFF)
option(WARNING "Warning mode" OFF)
option(TEST "Simulation test for CI" OFF)
option(MINIPIC "Compile minipic" ON)
option(UNIFIED_MEMORY "Use unified memory" OFF)
set(IMPLEMENTATION "exercise" CACHE STRING "Which implementation to use")

message(" Minipic compilation: ${MINIPIC}")

set(COMPILE_OPTIONS "")
set(LINK_OPTIONS "")

# _________________________________________________________________
# Debug mode

if (DEBUG)
 message(" Debug mode: ON")
 set(COMPILE_OPTIONS ${COMPILE_OPTIONS} -D__MINIPIC_DEBUG__)
endif()

# _________________________________________________________________
# Warning mode

if (WARNING)
 message(" Warning mode: ON")
 set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
endif()

# _________________________________________________________________
# Unified memory

if (UNIFIED_MEMORY)
 message(" Unified memory: ON")
 set(COMPILE_OPTIONS ${COMPILE_OPTIONS} -D__MINIPIC_KOKKOS_UNIFIED__)
else ()
 message(" Unified memory: OFF")
 set(COMPILE_OPTIONS ${COMPILE_OPTIONS} -D__MINIPIC_KOKKOS_NON_UNIFIED__)
endif ()

# _________________________________________________________________
# Implementation

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/${IMPLEMENTATION}")
  message(FATAL_ERROR "Cannot find implementation '${IMPLEMENTATION}' in src/")
endif()
message(" Implementation: ${IMPLEMENTATION}")

message(" __________________________________________________________________ \n")

# __________________________________________________________________
# Project

project(
  minipic
  LANGUAGES CXX
)

# __________________________________________________________________
# Dependencies

find_package(Kokkos QUIET)
if(Kokkos_FOUND)
  message(STATUS "Kokkos provided as installed: ${Kokkos_DIR} (version \"${Kokkos_VERSION}\")")
  message(STATUS "  With backend: ${Kokkos_DEVICES}")
  message(STATUS "  With options: ${Kokkos_OPTIONS}")
  message(STATUS "  For architectures: ${Kokkos_ARCH}")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/kokkos/CMakeLists.txt")
    message(STATUS "Kokkos submodule found. Using the submodule.")
    add_subdirectory(external/kokkos)
else()
    message(WARNING "Kokkos not found. Try running: git submodule update --init --recursive")
endif()

# __________________________________________________________________

# Specific behavior for test mode
if (TEST)
  set(MAIN_PATH "./main.cpp")
else()
  set(MAIN_PATH "./src/main.cpp")
endif()

# __________________________________________________________________
# Create executable with options

file(GLOB SOURCES_COMMON "${CMAKE_CURRENT_SOURCE_DIR}/src/common/*.cpp")

set(COMPILE_OPTIONS ${COMPILE_OPTIONS} -D__MINIPIC_KOKKOS__ -D__MINIPIC_KOKKOS_COMMON__ -D__MINIPIC_KOKKOS_NON_UNIFIED__)

if(MINIPIC)

  add_executable(
    minipic
    ${SOURCES_COMMON}
    ${MAIN_PATH}
  )
  target_include_directories(
    minipic
    PUBLIC
      "src/setups"
      "src/common"
      "src/${IMPLEMENTATION}"
  )
  target_compile_options(
    minipic
    PRIVATE
      ${COMPILE_OPTIONS}
  )
  target_link_options(
    minipic
    PRIVATE
      ${LINK_OPTIONS}
  )
  target_link_libraries(
    minipic
    PRIVATE
      Kokkos::kokkos
  )

endif()

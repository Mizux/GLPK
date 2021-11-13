# This file is just an orchestration
cmake_minimum_required(VERSION 3.16)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

option(CMAKE_EXPORT_COMPILE_COMMANDS "Export compile command" TRUE)

project(GLPK VERSION 5.0 LANGUAGES C)
set(PROJECT_NAMESPACE GLPK)
message(STATUS "${PROJECT_NAME} version: ${PROJECT_VERSION}")
#message(STATUS "major: ${PROJECT_VERSION_MAJOR}")
#message(STATUS "minor: ${PROJECT_VERSION_MINOR}")
#message(STATUS "patch: ${PROJECT_VERSION_PATCH}")

get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(isMultiConfig)
  if(NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING
    "Choose the type of builds, options are: Debug Release RelWithDebInfo MinSizeRel. (default: Release;Debug)"
    FORCE)
  endif()
  message(STATUS "Configuration types: ${CMAKE_CONFIGURATION_TYPES}")
else()
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel. (default: Release)"
    FORCE)
  endif()
  message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
endif()

message(STATUS "SYSTEM: ${CMAKE_SYSTEM_NAME}")
message(STATUS "C_COMPILER: ${CMAKE_C_COMPILER_ID}")

# Layout build dir like install dir
include(GNUInstallDirs)
if(UNIX)
  option(BUILD_SHARED_LIBS "Build shared libraries (.so or .dyld)." ON)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
  # for multi-config build system (e.g. Xcode, Ninja Multi-Config)
  foreach(OutputConfig IN LISTS CMAKE_CONFIGURATION_TYPES)
    string(TOUPPER ${OutputConfig} OUTPUTCONFIG)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_LIBDIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_LIBDIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_BINDIR})
  endforeach()
else()
  # Default to static build for non-unix
  option(BUILD_SHARED_LIBS "Build shared libraries (.dll)." OFF)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
  # for multi-config builds (e.g. msvc)
  foreach(OutputConfig IN LISTS CMAKE_CONFIGURATION_TYPES)
    string(TOUPPER ${OutputConfig} OUTPUTCONFIG)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_BINDIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_BINDIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${CMAKE_INSTALL_BINDIR})
  endforeach()
endif()

# Disable CTest targets
set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
include(CTest)

include(c)

option(BUILD_EXAMPLES "Build examples" ON)
message(STATUS "Build examples: ${BUILD_EXAMPLES}")
add_subdirectory(examples)

option(ODBC "enable MathProg ODBC support" OFF)
message(STATUS "enable MathProg ODBC support: ${ODBC}")
if(ODBC)
  find_package(ODBC)
  if(ODBC_FOUND)
    if(ODBC_CONFIG)
      execute_process(COMMAND "${ODBC_CONFIG} --cflags"
              RESULT_VARIABLE ODBC_RESULT
              OUTPUT_VARIABLE ODBC_OUTPUT
              ERROR_VARIABLE ODBC_ERROR)
      if(ODBC_OUTPUT AND (NOT ODBC_ERROR))
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ODBC_OUTPUT}")
      elseif(ODBC_ERROR)
        message(FATAL_ERROR "'${ODBC_CONFIG} --cflags' returned ${ODBC_RESULT}: ${ODBC_ERROR}")
      else()
        message(FATAL_ERROR "'${ODBC_CONFIG} --cflags' produced no output")
      endif()
    else()
      message(FATAL_ERROR "Could not run 'odbc-config --cflags' or 'iodbc-config --cflags'")
    endif()
    string(REGEX MATCH "/[^/\\]+$/gm" ODBC_LIB_NAME "${ODBC_LIBRARIES}") # regexr.com/698ls strips the preceding path from the actual lib name
    if (GMP_LIB_NAME)
      target_compile_definitions(GLPK PUBLIC ODBC_DLNAME=${ODBC_LIB_NAME})
      target_link_libraries(GLPK PRIVATE ODBC::ODBC)
    else()
      message(FATAL_ERROR "Could not determine ODBC/iODBC library name")
    endif()
  else()
    message(FATAL_ERROR "ODBC/iODBC library not found")
  endif()
endif()

include(CMakeDependentOption)
cmake_dependent_option(MYSQL "enable MathProg MySQL support" OFF "BUILD_SHARED_LIBS" OFF)
message(STATUS "enable MathProg MySQL support: ${MYSQL}")
if(MYSQL)
  find_package(MySQL)
  if(MYSQL_FOUND)
    target_link_libraries(GLPK GMP_LIBRARIES)
    target_include_directories(GLPK MYSQL_INCLUDE_DIRS)
  else()
    message(FATAL_ERROR "MySQL not found")
  endif()
endif()

option(IS_REENTRANT "enable reentrancy support" ON)
message(STATUS "enable reentrancy support: ${IS_REENTRANT}")
if(IS_REENTRANT)
  if (
  (CMAKE_C_COMPILER_ID MATCHES "Clang") OR # matches AppleClang and Clang
  (CMAKE_C_COMPILER_ID STREQUAL "GNU") OR
  (CMAKE_C_COMPILER_ID STREQUAL "Intel")
  )
    set(TLS "__thread")
  elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    set(TLS "__declspec(thread)")
  else()
    message(WARNING "compiler-specific spec for thread local storage not found; if your build breaks, set 'IS_REENTRANT' option to 'OFF'")
    set(TLS "_Thread_local") # default to C11 standard, may break some builds if thread local storage isn't supported
  endif()
  target_compile_definitions(GLPK PUBLIC TLS=${TLS})
endif()
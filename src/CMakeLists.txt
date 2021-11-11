add_library(GLPK)
target_sources(GLPK PRIVATE glpk.h)
add_subdirectory(amd)
add_subdirectory(api)
add_subdirectory(bflib)
add_subdirectory(colamd)
add_subdirectory(draft)
add_subdirectory(env)
add_subdirectory(intopt)
add_subdirectory(minisat)
add_subdirectory(misc)
add_subdirectory(mpl)
add_subdirectory(npp)
add_subdirectory(proxy)
add_subdirectory(simplex)
add_subdirectory(zlib)

target_include_directories(GLPK
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/amd>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/api>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/bflib>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/colamd>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/draft>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/env>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/intopt>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/minisat>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/misc>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/mpl>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/npp>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/proxy>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/simplex>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/zlib>
    $<INSTALL_INTERFACE:include>)
target_compile_features(GLPK PUBLIC c_std_11)
set_target_properties(GLPK PROPERTIES
  VERSION ${PROJECT_VERSION}
  PUBLIC_HEADER glpk.h)
target_link_libraries(GLPK
  PRIVATE
  $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)
add_library(${PROJECT_NAMESPACE}::GLPK ALIAS GLPK)

# check system libs functions and headers
# m::exp
include(CheckSymbolExists)
check_symbol_exists(exp "math.h" HAVE_EXP)
if(NOT HAVE_EXP)
    unset(HAVE_EXP CACHE)
    list(APPEND CMAKE_REQUIRED_LIBRARIES "m")
    check_symbol_exists(exp "math.h" HAVE_EXP)
    if(HAVE_EXP)
        target_link_libraries(GLPK PRIVATE m)
    else()
        message(FATAL_ERROR "exp function not found")
    endif()
endif()

# sys/time.h
include(CheckIncludeFile)
check_include_file(sys/time.h HAS_TIME_H)
if(HAS_TIME_H)
    add_compile_definitions(HAVE_SYS_TIME_H=1)
else()
    add_compile_definitions(HAVE_SYS_TIME_H=N/A)
endif()

# gettimeofday function
include(CheckFunctionExists)
check_function_exists(gettimeofday, HAVE_GETTIMEOFDAY_FUNC)
if(HAVE_GETTIMEOFDAY_FUNC)
    add_compile_definitions(HAVE_GETTIMEOFDAY=1)
else()
    add_compile_definitions(HAVE_GETTIMEOFDAY=N/A)
endif()

#add_subdirectory(tests)

# Install
install(TARGETS GLPK
  EXPORT ${PROJECT_NAME}Targets
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )

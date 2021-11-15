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

# define if windows environment
if(MSVC)
    target_compile_definitions(GLPK PUBLIC __WOE__=1)
else()
    # sys/time.h
    include(CheckIncludeFile)
    check_include_file(sys/time.h HAS_TIME_H)
    if(HAS_TIME_H)
        target_compile_definitions(GLPK PUBLIC HAVE_SYS_TIME_H=1)
        include(CheckSymbolExists)
        check_symbol_exists(gettimeofday sys/time.h HAVE_GETTIMEOFDAY_FUNC)
        if(HAVE_GETTIMEOFDAY_FUNC)
            target_compile_definitions(GLPK PUBLIC HAVE_GETTIMEOFDAY=1)
        endif()
    endif()
endif()

# libgmp/gmp.h
find_package(GMP)
if(GMP_FOUND)
    target_link_libraries(GLPK PRIVATE GMP::gmp)
    target_compile_definitions(GLPK PUBLIC HAVE_GMP=1)
else()
    message(AUTHOR_WARNING "gmp.h/libgmp not found")
endif()

#add_subdirectory(tests)

# Install
install(TARGETS GLPK
  EXPORT ${PROJECT_NAME}Targets
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )

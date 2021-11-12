# I've probably done this whole thing completely wrong, but it works

if(APPLE)
    set(CMAKE_INSTALL_RPATH
            "@loader_path/../${CMAKE_INSTALL_LIBDIR};@loader_path")
elseif(UNIX)
    set(CMAKE_INSTALL_RPATH "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}:$ORIGIN")
endif()

set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

#get dir relative to source root
string(REPLACE ${CMAKE_SOURCE_DIR} "" RELATIVE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
#remove any leading slash
string(REGEX REPLACE "^[/|\\]+" "" RELATIVE_DIR ${RELATIVE_DIR})
# multi-cfg builds
foreach(OutputConfig IN LISTS CMAKE_CONFIGURATION_TYPES)
    string(TOUPPER ${OutputConfig} OUTPUTCONFIG)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${RELATIVE_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${RELATIVE_DIR})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${RELATIVE_DIR})
endforeach()
# single-cfg builds
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${RELATIVE_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${RELATIVE_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${RELATIVE_DIR})

file(GLOB TEST_FILES "*.c" LIST_DIRECTORIES false)
list(FILTER TEST_FILES EXCLUDE REGEX ".*/main.c") # executable
list(FILTER TEST_FILES EXCLUDE REGEX ".*/tsplib.c") # dependent
foreach(TEST_FILE IN LISTS TEST_FILES)
    if(NOT (IS_DIRECTORY ${TEST_FILE})) # `LIST_DIRECTORIES false` not reliable
        get_filename_component(TEST_TARGET_NAME ${TEST_FILE} NAME_WE)
        add_library(${TEST_TARGET_NAME} ${TEST_FILE})
        target_include_directories(
                ${TEST_TARGET_NAME}
                PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
                PUBLIC ${CMAKE_SOURCE_DIR}/src
                )
        target_compile_features(${TEST_TARGET_NAME} PRIVATE c_std_11)
        target_link_libraries(${TEST_TARGET_NAME} PRIVATE
                $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)
        add_library(${PROJECT_NAMESPACE}::${TEST_TARGET_NAME} ALIAS ${TEST_TARGET_NAME})
        install(TARGETS ${TEST_TARGET_NAME})
        set_target_properties(${TEST_TARGET_NAME} PROPERTIES PREFIX "")
    endif()
endforeach()

add_library(tsplib tsplib.c)
target_include_directories(
        tsplib
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
        PUBLIC ${CMAKE_SOURCE_DIR}/src
)
target_compile_features(tsplib PRIVATE c_std_11)
target_link_libraries(tsplib PRIVATE
        ${PROJECT_NAMESPACE}::GLPK
        ${PROJECT_NAMESPACE}::misc
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)
add_library(${PROJECT_NAMESPACE}::tsplib ALIAS tsplib)
install(TARGETS tsplib)

set_target_properties(tsplib PROPERTIES PREFIX "")

add_executable(tspsol main.c)
target_include_directories(
        tspsol
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
        PUBLIC ${CMAKE_SOURCE_DIR}/src
)
target_compile_features(tspsol PRIVATE c_std_11)
target_link_libraries(tspsol PRIVATE
        ${PROJECT_NAMESPACE}::GLPK
        ${PROJECT_NAMESPACE}::tsplib
        ${PROJECT_NAMESPACE}::mincut
        ${PROJECT_NAMESPACE}::maxflow
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)

include(GNUInstallDirs)
install(TARGETS tspsol)

# copy example data to build output folder
# using `configure_file` creates a data dependence
# i.e. changes in the example data will reflect in the output folder
file(GLOB EXAMPLE_DATA_FILES "*" LIST_DIRECTORIES false)
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*\\.[c|h]") # remove *.c and *.h files
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*\\.am") # remove automake files
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*\\.bat") # remove batch files
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*/CMakeLists\\.txt") # remove CMakeLists.txt
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*/Makefile") # remove Makefiles
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*/Makefile.in") # remove Makefile templates
list(FILTER EXAMPLE_DATA_FILES EXCLUDE REGEX ".*/build\\.sh") # remove build scripts
foreach(EXAMPLE_DATA_FILE IN LISTS EXAMPLE_DATA_FILES)
    get_filename_component(EXAMPLE_DATA_NAME ${EXAMPLE_DATA_FILE} NAME)
    if(NOT (IS_DIRECTORY ${EXAMPLE_DATA_FILE})) # `LIST_DIRECTORIES false` not reliable
        configure_file(
                ${EXAMPLE_DATA_FILE}
                ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${RELATIVE_DIR}/${EXAMPLE_DATA_NAME}
                COPYONLY
        )
    endif()
endforeach()

if(BUILD_TESTING)
    add_test(NAME tspsol_solve COMMAND tspsol "${CMAKE_BINARY_DIR}/${RELATIVE_DIR}/sample.tsp")
endif()
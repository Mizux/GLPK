include(examples)

add_library(tsplib tsplib.c misc.c mincut.c maxflow.c)
target_include_directories(tsplib PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
target_compile_features(tsplib PRIVATE c_std_11)
target_link_libraries(tsplib PRIVATE
        ${PROJECT_NAMESPACE}::GLPK
#        misc
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)
add_library(${PROJECT_NAMESPACE}::tsplib ALIAS tsplib)
install(TARGETS tsplib
        EXPORT ${PROJECT_NAME}Targets)

set_target_properties(tsplib PROPERTIES PREFIX "")

add_executable(tspsol main.c mincut.c maxflow.c)
target_include_directories(tspsol PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
target_compile_features(tspsol PRIVATE c_std_11)
target_link_libraries(tspsol PRIVATE
        ${PROJECT_NAMESPACE}::GLPK
        ${PROJECT_NAMESPACE}::tsplib
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)

include(GNUInstallDirs)
install(TARGETS tspsol
        EXPORT ${PROJECT_NAME}Targets)

configure_example_data(${CMAKE_CURRENT_SOURCE_DIR})

if(BUILD_TESTING)
    #get current dir relative to source root
    string(REPLACE ${CMAKE_SOURCE_DIR} "" RELATIVE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    #remove any leading slash
    string(REGEX REPLACE "^[/|\\]+" "" RELATIVE_DIR ${RELATIVE_DIR})
    add_test(NAME tspsol_solve COMMAND tspsol "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${RELATIVE_DIR}/sample.tsp")
endif()
if(APPLE)
  set(CMAKE_INSTALL_RPATH
    "@loader_path/../${CMAKE_INSTALL_LIBDIR};@loader_path")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}:$ORIGIN")
endif()

add_executable(glpsol glpsol.c)
target_compile_features(glpsol PRIVATE c_std_11)
target_link_libraries(glpsol PRIVATE
  ${PROJECT_NAMESPACE}::GLPK
  $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>)
add_executable(${PROJECT_NAMESPACE}::glpsol ALIAS glpsol)

install(TARGETS glpsol
  EXPORT ${PROJECT_NAME}Targets)

add_subdirectory(tsp)

# GPSOL tests
add_test(
        NAME
          glpsol_version
        COMMAND
          glpsol  --version
)
add_test(
        NAME
          glpsol_solve
        COMMAND
          glpsol --mps ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/examples/murtagh.mps --max
)

if(NOT BUILD_EXAMPLES)
  return()
endif()

include(examples)
add_example_folder(${CMAKE_CURRENT_SOURCE_DIR})

# get example subdirectories and add them
SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR})
list(REMOVE_ITEM SUBDIRS "tsp") # already added
foreach(SUBDIR IN LISTS SUBDIRS)
  add_subdirectory(${SUBDIR})
endforeach()
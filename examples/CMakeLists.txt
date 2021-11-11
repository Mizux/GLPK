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

if(NOT BUILD_EXAMPLES)
  return()
endif()

file(GLOB C_SRCS "*.c")
list(FILTER C_SRCS EXCLUDE REGEX ".*/glpsol.c") # need input file
list(FILTER C_SRCS EXCLUDE REGEX ".*/netgen.c") # no license
foreach(FILE_NAME IN LISTS C_SRCS)
  add_c_example(${FILE_NAME})
endforeach()

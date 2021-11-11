if(NOT BUILD_EXAMPLES)
  return()
endif()

file(GLOB C_SRCS "*.c")
list(FILTER C_SRCS EXCLUDE REGEX ".*/glpsol.c") # need input file
list(FILTER C_SRCS EXCLUDE REGEX ".*/netgen.c") # no license
foreach(FILE_NAME IN LISTS C_SRCS)
  add_c_example(${FILE_NAME})
endforeach()
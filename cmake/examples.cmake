function(add_example_folder EXAMPLE_SRC_DIRECTORY)
    #get example dir relative to source root
    string(REPLACE ${CMAKE_SOURCE_DIR} "" EXAMPLE_RELATIVE_DIR ${EXAMPLE_SRC_DIRECTORY})
    #remove any leading slash
    string(REGEX REPLACE "^[/|\\]+" "" EXAMPLE_RELATIVE_DIR ${EXAMPLE_RELATIVE_DIR})

    # change runtime output dir for examples
        # multi-cfg builds
    foreach(OutputConfig IN LISTS CMAKE_CONFIGURATION_TYPES)
        string(TOUPPER ${OutputConfig} OUTPUTCONFIG)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_BINARY_DIR}/${OutputConfig}/${EXAMPLE_RELATIVE_DIR})
    endforeach()
        # single-cfg builds
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${EXAMPLE_RELATIVE_DIR})

    # compile example executables
    file(GLOB C_SRCS "*.c" LIST_DIRECTORIES false)
    list(FILTER C_SRCS EXCLUDE REGEX ".*/glpsol.c") # project non-example executable target
    list(FILTER C_SRCS EXCLUDE REGEX ".*/netgen.c") # no license
    foreach(FILE_NAME IN LISTS C_SRCS)
        if(NOT (IS_DIRECTORY ${FILE_NAME})) # `LIST_DIRECTORIES false` not reliable
            add_c_test(${FILE_NAME})
        endif()
    endforeach()
    configure_example_data(${EXAMPLE_SRC_DIRECTORY})
endfunction()

function(configure_example_data EXAMPLE_SRC_DIRECTORY)
    #get example dir relative to source root
    string(REPLACE ${CMAKE_SOURCE_DIR} "" EXAMPLE_RELATIVE_DIR ${EXAMPLE_SRC_DIRECTORY})
    #remove any leading slash
    string(REGEX REPLACE "^[/|\\]+" "" EXAMPLE_RELATIVE_DIR ${EXAMPLE_RELATIVE_DIR})
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
                    ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${EXAMPLE_RELATIVE_DIR}/${EXAMPLE_DATA_NAME}
                    COPYONLY
            )
        endif()
    endforeach()
endfunction()

# https://stackoverflow.com/questions/7787823/cmake-how-to-get-the-name-of-all-subdirectories-of-a-directory
MACRO(SUBDIRLIST result curdir)
    FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir}/${child})
            LIST(APPEND dirlist ${child})
        ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
ENDMACRO()
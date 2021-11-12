if(APPLE)
    set(CMAKE_INSTALL_RPATH
            "@loader_path/../${CMAKE_INSTALL_LIBDIR};@loader_path")
elseif(UNIX)
    set(CMAKE_INSTALL_RPATH "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}:$ORIGIN")
endif()

add_executable(multiseed multiseed.c)
target_compile_features(multiseed PRIVATE c_std_11)
if (UNIX)
    find_package(Threads REQUIRED)
endif()
target_link_libraries(multiseed PRIVATE
        ${PROJECT_NAMESPACE}::GLPK
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:m>
        $<$<NOT:$<C_COMPILER_ID:MSVC>>:Threads::Threads>
)

install(TARGETS multiseed)

add_test(
        NAME
            c_examples_multiseed
        COMMAND
            multiseed clustering.mod 20
)
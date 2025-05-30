cmake_minimum_required(VERSION 3.16)
project(Sample VERSION 1.0.0 LANGUAGES CXX C)

include(CTest)
find_package(GLPK REQUIRED)

add_executable(sample main.cpp)
target_compile_features(sample PUBLIC cxx_std_17)
set_target_properties(sample PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  VERSION ${PROJECT_VERSION})
target_link_libraries(sample PRIVATE GLPK::GLPK)

if(BUILD_TESTING)
  add_test(NAME cpp_sample COMMAND sample)
endif()

include(GNUInstallDirs)
install(TARGETS sample
  EXPORT SampleTargets
  DESTINATION ${CMAKE_INSTALL_BINDIR})

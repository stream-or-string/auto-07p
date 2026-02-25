cmake_minimum_required(VERSION 3.13)

# Plaut04 3D plotting package

project(Plaut04 CXX)

if(BUILD_PLAUT04)
  enable_language(CXX)

  # Add the src subdirectory which contains the main build
  add_subdirectory(src)

endif()

# Superclean target
add_custom_target(plaut04-superclean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/plaut04
)

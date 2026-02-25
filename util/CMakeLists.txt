cmake_minimum_required(VERSION 3.13)

# Utility programs compilation

enable_language(Fortran)

# Compiler flags
set(FFLAGS_TO_USE "${CMAKE_Fortran_FLAGS} ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE}}")

# Create utility object library
add_library(util_obj OBJECT
  utility.f90
)

# Compatibility object from f2003.f90 in src
add_library(compat_obj OBJECT
  ../src/f2003.f90
)

# Utility programs
add_executable(autlab
  autlab.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(double
  double.f90
)

add_executable(triple
  triple.f90
)

add_executable(keepbp
  keepbp.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(keeplp
  keeplp.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(keepuz
  keepuz.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(keepsp
  keepsp.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(deletelp
  deletelp.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(listlabels
  listlabels.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(reduce
  reduce.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

add_executable(relabel
  relabel.f90
  $<TARGET_OBJECTS:util_obj>
  $<TARGET_OBJECTS:compat_obj>
)

# Install executables
install(TARGETS
  autlab double triple keepbp keeplp keepuz keepsp deletelp listlabels reduce relabel
  DESTINATION ${AUTODIR}/bin)

# Clean rule equivalent to original Makefile
add_custom_target(util-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory CMakeFiles
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.o
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.mod)

# Cleanup rule for superclean
add_custom_target(util-superclean
  COMMAND cd ${CMAKE_CURRENT_BINARY_DIR} && ${CMAKE_MAKE_PROGRAM} util-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/util)

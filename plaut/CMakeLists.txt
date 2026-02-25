cmake_minimum_required(VERSION 3.13)

# Plaut plotting package

enable_language(Fortran)

# Check if we have the necessary Fortran sources
file(GLOB PLAUT_SOURCES "*.f" "*.f90")

if(PLAUT_SOURCES)
  # Create compat module from f2003.f90 in src
  add_library(plaut_compat_obj OBJECT
    ../src/f2003.f90
  )

  # Create plaut executable
  add_executable(plaut
    plautmain.f
    plautlib.f
    plautdev.f
    plautint.f
    $<TARGET_OBJECTS:plaut_compat_obj>
  )

  # Link against the AUTO library
  target_link_libraries(plaut PRIVATE auto_f)

  # Set Fortran compilation flags
  set_target_properties(plaut PROPERTIES
    COMPILE_FLAGS "${CMAKE_Fortran_FLAGS} ${CMAKE_Fortran_FLAGS_${CMAKE_BUILD_TYPE}}"
  )

  # Install plaut executable
  install(TARGETS plaut
    DESTINATION lib/auto-07p/bin)

  #[[   No need to install
  # Install documentation
  install(FILES
    README
    DESTINATION lib/auto-07p/doc/plaut
    OPTIONAL)

  install(FILES
    plaut.ps
    DESTINATION lib/auto-07p/doc/plaut
    OPTIONAL)

  install(FILES
    plaut.tex
    DESTINATION lib/auto-07p/doc/plaut
    OPTIONAL)
  ]]

else()
  message(STATUS "Plaut sources not found, skipping plaut build")
endif()

# Clean target
add_custom_target(plaut-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory CMakeFiles
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.o
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.mod
)

# Superclean target
add_custom_target(plaut-superclean
  COMMAND ${CMAKE_CURRENT_BINARY_DIR} && ${CMAKE_MAKE_PROGRAM} plaut-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/plaut
)

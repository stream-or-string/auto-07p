cmake_minimum_required(VERSION 3.13)

# GUI Application (Motif-based)

if(BUILD_GUI)
  enable_language(C)

  # Check for X11 and Motif
  find_package(X11 REQUIRED)
  find_library(XM_LIBRARY Xm REQUIRED)

  # Auto97 GUI application
  add_executable(auto97
    auto97.c
  )

  target_include_directories(auto97 PRIVATE
    ${CMAKE_SOURCE_DIR}/include
    ${X11_INCLUDE_DIR}
  )

  target_link_libraries(auto97 PRIVATE
    ${X11_LIBRARIES}
    ${XM_LIBRARY}
    m
  )

  # Set C flags
  set_target_properties(auto97 PROPERTIES
    COMPILE_FLAGS "${CMAKE_C_FLAGS} ${X11_CFLAGS}"
  )

  # Install GUI application
  install(TARGETS auto97
    DESTINATION bin)

  # Install resource files
  install(FILES
    Xdefaults.1
    Xdefaults.2
    DESTINATION lib/auto-07p/gui
    OPTIONAL)

  # Install README
  install(FILES README
    DESTINATION lib/auto-07p/gui
    OPTIONAL)

endif()

# Clean target
add_custom_target(gui-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory CMakeFiles
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.o
)

# Superclean target
add_custom_target(gui-superclean
  COMMAND ${CMAKE_CURRENT_BINARY_DIR} && ${CMAKE_MAKE_PROGRAM} gui-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/gui
)

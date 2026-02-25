cmake_minimum_required(VERSION 3.13)

# Commands installation
# This directory handles command script templates and command file setup

# @@ cmds
set(TEMPLATE_COMMANDS
  "H"
  "LB" 
  "R"
  "RD"
)

# Create the cmds with the @ prefix copied if they don't exist
foreach(cmd ${TEMPLATE_COMMANDS})
  set(TARGET_FILE "${CMAKE_CURRENT_BINARY_DIR}/\@\@${cmd}")
  set(SOURCE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/\@\@${cmd}")
  
  if(NOT EXISTS ${TARGET_FILE})
    configure_file(${SOURCE_FILE} ${TARGET_FILE} COPYONLY)
  endif()
endforeach()

# Process environment script templates
set(abs_top_srcdir "${CMAKE_INSTALL_PREFIX}/")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/auto.env.in"
  "${CMAKE_CURRENT_BINARY_DIR}/auto.env"
  @ONLY
)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/auto.env.sh.in"
  "${CMAKE_CURRENT_BINARY_DIR}/auto.env.sh"
  @ONLY
)

# Install command scripts and templates
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
  DESTINATION lib/auto-07p/cmds/
  FILES_MATCHING PATTERN "@*"
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)

# Install command configuration files
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/auto.env"
  "${CMAKE_CURRENT_BINARY_DIR}/auto.env.sh"
  DESTINATION lib/auto-07p/cmds/)

#TODO: install cmds.make & Makefile
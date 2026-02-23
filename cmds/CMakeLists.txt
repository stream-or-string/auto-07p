cmake_minimum_required(VERSION 3.6)

# Commands installation
# This directory handles command script templates and command file setup

# Create command template files by copying if needed
# Handles case-insensitive filesystems

set(TEMPLATE_COMMANDS
  "H"
  "LB" 
  "R"
  "RD"
)

# Create the cmds with the @ prefix copied if they don't exist
foreach(cmd ${TEMPLATE_COMMANDS})
  set(TARGET_FILE "${CMAKE_CURRENT_BINARY_DIR}/${cmd}")
  set(SOURCE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/@${cmd}")
  
  if(NOT EXISTS ${TARGET_FILE})
    configure_file(${SOURCE_FILE} ${TARGET_FILE} COPYONLY)
  endif()
endforeach()

# Process environment script templates
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
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/"
  DESTINATION lib/auto-07p/cmds/
  FILES_MATCHING PATTERN "@*"
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)

# Install command configuration files
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/auto.env"
  "${CMAKE_CURRENT_BINARY_DIR}/auto.env.sh"
  DESTINATION lib/auto-07p/cmds/)

# Install script templates (data files)
file(GLOB CMD_SCRIPTS "${CMAKE_CURRENT_SOURCE_DIR}/[a-zA-Z]*")
install(FILES ${CMD_SCRIPTS}
  DESTINATION lib/auto-07p/cmds/
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)

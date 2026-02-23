cmake_minimum_required(VERSION 3.6)

project(AUTO C CXX Fortran)

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build: None Debug Release"
      FORCE)
endif()

# Version and installation paths
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}" CACHE STRING
    "Choose the installation directory; by default it installs in the Auto directory."
    FORCE)

# C++ Language Features
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build options - match configure.ac defaults
option(WITH_OPENMP "Build with OpenMP support" ON)
option(WITH_MPI "Build with MPI support" OFF)
option(BUILD_DEBUG "Enable extra floating point/bounds debugging" OFF)
option(BUILD_PLAUT "Compile the Plaut plotting package" ON)
option(BUILD_PLAUT04 "Compile the Plaut04 plotting package" ON)
option(BUILD_PLAUT04_QT "Try to use QT instead of Motif/LessTif for Plaut04" ON)
option(BUILD_GUI "Compile the Motif based GUI package" OFF)
option(BUILD_DOCUMENTATION "Build the project documentation" OFF)
option(BUILD_DEMOS "Build the demos" ON)
option(BUILD_PYTHON "Build Python wheel" OFF)
option(BUILD_CMDS "Build AUTO @commands" OFF)


# OpenMP support
if(WITH_OPENMP)
  find_package(OpenMP)
  if(OpenMP_FOUND)
    message(STATUS "Building AUTO with OpenMP support")
  endif()
endif()

# MPI support
if(WITH_MPI)
  find_package(MPI REQUIRED COMPONENTS Fortran)
  message(STATUS "Building AUTO with MPI support")
endif()

# X11 and Motif detection for GUI
if(BUILD_GUI)
  find_package(X11)
  if(NOT X11_FOUND)
    message(WARNING "X11 not found. GUI will be disabled.")
    set(BUILD_GUI OFF)
  else()
    find_library(XM_LIBRARY Xm)
    if(NOT XM_LIBRARY)
      message(WARNING "Motif library (libXm) not found. GUI will be disabled.")
      set(BUILD_GUI OFF)
    else()
      message(STATUS "Building AUTO with GUI support")
    endif()
  endif()
endif()

# Coin3D/Inventor detection for Plaut04
set(HAVE_COIN3D FALSE)
set(HAVE_SOXT FALSE)

if(BUILD_PLAUT04)
  if(BUILD_PLAUT04_QT)
    find_package(Qt5 COMPONENTS Core Gui OpenGL QUIET)
    if(Qt5_FOUND)
      message(STATUS "Found Qt5")
    endif()
  endif()

  # Check for Coin3D
  find_library(COIN_LIBRARY Coin QUIET)
  if(COIN_LIBRARY)
    set(HAVE_COIN3D TRUE)
    message(STATUS "Found Coin3D")
  endif()

  if(HAVE_COIN3D)
    # Check for SoQt or SoXt
    find_library(SOQT_LIBRARY SoQt QUIET)
    find_library(SOXT_LIBRARY SoXt QUIET)
    
    if(SOQT_LIBRARY OR SOXT_LIBRARY)
      set(HAVE_SOXT TRUE)
      message(STATUS "Building AUTO with Plaut04 support")
    else()
      message(WARNING "SoQt/SoXt not found. Plaut04 will be disabled.")
      set(BUILD_PLAUT04 OFF)
    endif()
  else()
    message(WARNING "Coin3D not found. Plaut04 will be disabled.")
    set(BUILD_PLAUT04 OFF)
  endif()
endif()

# Main library and executable source
add_subdirectory(src)

# Utilities
add_subdirectory(util)

# Command utilities and scripts
if(BUILD_CMDS)
  add_subdirectory(cmds)
endif() 

# Demos/Examples
if(BUILD_DEMOS)
  add_subdirectory(demos)
endif()

# Plaut plotting package
if(BUILD_PLAUT)
  add_subdirectory(plaut)
endif()

# Plaut04 plotting package
if(BUILD_PLAUT04)
  add_subdirectory(plaut04)
endif()

# GUI (Motif-based)
if(BUILD_GUI)
  add_subdirectory(gui)
endif()

# Documentation
if(BUILD_DOCUMENTATION)
  add_subdirectory(doc)
endif()

# Installation configuration
set(AUTODIR "${CMAKE_INSTALL_PREFIX}/lib/auto-07p")

# Install binaries
if(EXISTS "${CMAKE_BINARY_DIR}/bin")
  install(DIRECTORY ${CMAKE_BINARY_DIR}/bin/
    DESTINATION bin
    FILES_MATCHING PATTERN "auto" PATTERN "autox"
    PERMISSIONS OWNER_EXECUTE OWNER_READ GROUP_READ WORLD_READ)
endif()

# Install python module
if(EXISTS "${CMAKE_SOURCE_DIR}/python")
  install(DIRECTORY python/auto/
    DESTINATION ${AUTODIR}/python/auto/
    FILES_MATCHING PATTERN "*.py")

  if(EXISTS "${CMAKE_SOURCE_DIR}/python/auto/graphics")
    install(DIRECTORY python/auto/graphics/
      DESTINATION ${AUTODIR}/python/auto/graphics/
      FILES_MATCHING PATTERN "*.py")
  endif()
endif()

# Install headers  
install(FILES include/auto_f2c.h
  DESTINATION ${AUTODIR}/include/)

# Install utility binaries
install(PROGRAMS
  bin/autlab
  bin/deletelp
  bin/double
  bin/keepbp
  bin/keeplp
  bin/keepsp
  bin/keepuz
  bin/listlabels
  bin/reduce
  bin/relabel
  bin/triple
  DESTINATION ${AUTODIR}/bin/
  OPTIONAL)

# Install config file
if(EXISTS "${CMAKE_SOURCE_DIR}/.autorc")
  install(FILES .autorc
    DESTINATION ${AUTODIR}
    RENAME autorc)
endif()

# Install libraries
if(EXISTS "${CMAKE_BINARY_DIR}/lib")
  install(DIRECTORY ${CMAKE_BINARY_DIR}/lib/
    DESTINATION ${AUTODIR}/lib/
    FILES_MATCHING PATTERN "*.a" PATTERN "*.so*")
endif()

# Install documentation
if(EXISTS "${CMAKE_SOURCE_DIR}/doc/auto.pdf")
  install(FILES doc/auto.pdf
    DESTINATION ${AUTODIR}/doc/)
endif()

# Install Plaut04 files
if(BUILD_PLAUT04)
  if(EXISTS "${CMAKE_SOURCE_DIR}/plaut04/doc")
    install(DIRECTORY plaut04/doc/
      DESTINATION ${AUTODIR}/plaut04/doc/)
  endif()
  if(EXISTS "${CMAKE_SOURCE_DIR}/plaut04/plaut04.rc")
    install(FILES plaut04/*.rc
      DESTINATION ${AUTODIR}/plaut04/)
  endif()
  if(EXISTS "${CMAKE_SOURCE_DIR}/plaut04/widgets")
    install(DIRECTORY plaut04/widgets/
      DESTINATION ${AUTODIR}/plaut04/widgets/)
  endif()
endif()

# Install demos
if(EXISTS "${CMAKE_SOURCE_DIR}/demos")
  install(DIRECTORY demos/
    DESTINATION ${AUTODIR}/demos/
    PATTERN ".git" EXCLUDE)
endif()

# Custom test target 
if(EXISTS "${CMAKE_SOURCE_DIR}/test")
  add_custom_target(check
    COMMAND bash -c "cd ${CMAKE_SOURCE_DIR}/test && unset DISPLAY && OMP_NUM_THREADS=2 && python ../python/auto all.auto"
  )
endif()

# Cleanup targets
add_custom_target(distclean
  COMMAND ${CMAKE_MAKE_PROGRAM} clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}
  COMMAND ${CMAKE_COMMAND} -E remove_directory CMakeFiles
  COMMAND ${CMAKE_COMMAND} -E remove CMakeCache.txt
)

# Summary message
message(STATUS "")
message(STATUS "AUTO07p Configuration Summary:")
message(STATUS "==============================")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Fortran compiler: ${CMAKE_Fortran_COMPILER}")
message(STATUS "  C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "")
message(STATUS "Optional features:")
message(STATUS "  OpenMP: ${WITH_OPENMP}")
message(STATUS "  MPI: ${WITH_MPI}")
message(STATUS "  Debug: ${BUILD_DEBUG}")
message(STATUS "  GUI: ${BUILD_GUI}")
message(STATUS "  Plaut: ${BUILD_PLAUT}")
message(STATUS "  Plaut04: ${BUILD_PLAUT04}")
message(STATUS "  Plaut04-Qt: ${BUILD_PLAUT04_QT}")
message(STATUS "  Demos: ${BUILD_DEMOS}")
message(STATUS "  Documentation: ${BUILD_DOCUMENTATION}")
message(STATUS "")
message(STATUS "Installation prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "")
message(STATUS "To build, run:")
message(STATUS "  mkdir build && cd build")
message(STATUS "  cmake ..")
message(STATUS "  cmake --build .")
message(STATUS "")
message(STATUS "To install, run:")
message(STATUS "  cmake --install .")
message(STATUS "")
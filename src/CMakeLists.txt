cmake_minimum_required(VERSION 3.13)

#[[
3.13  or newer. This automatically sets CMP0079 to NEW behavior. 
i.e: same as: cmake_policy(SET CMP0079 NEW)
this allows you are trying to use target_link_libraries() on a 
target defined in a different CMakeLists.txt file (i.e., a different directory scope)
e.g. in demos/rev/CMakeLists.txt, we can link to auto_f, which is defined in the main CMakeLists.txt file.

#]]

# Make sure Fortran is enabled
enable_language(Fortran)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build: None Debug Release"
      FORCE)
endif()

# Compiler-specific optimization flags for Fortran
get_filename_component(Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)

if(Fortran_COMPILER_NAME MATCHES "gfortran.*")
  # gfortran
  set(CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3")
  set(CMAKE_Fortran_FLAGS_DEBUG "-fno-f2c -O0 -g")
elseif(Fortran_COMPILER_NAME MATCHES "ifort.*")
  # ifort
  set(CMAKE_Fortran_FLAGS_RELEASE "-f77rtl -O3")
  set(CMAKE_Fortran_FLAGS_DEBUG "-f77rtl -O0 -g")
elseif(Fortran_COMPILER_NAME MATCHES "g77")
  # g77
  set(CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3 -m32")
  set(CMAKE_Fortran_FLAGS_DEBUG "-fno-f2c -O0 -g -m32")
else()
  message(STATUS "Fortran compiler: ${Fortran_COMPILER_NAME}")
  message(STATUS "No optimized Fortran compiler flags are known, using default -O2")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g")
endif()

# MPI Support
set(MPI_SOURCE_FILE nompi.f90)
if(WITH_MPI)
  set(MPI_SOURCE_FILE mpi.f90)
endif()

# Source files - organized by dependency order
set(BLAS_SOURCES
  blas.f
)

set(LAPACK_SOURCES
  lapack.f
)

set(CORE_SOURCES
  auto_constants.f90
  f2003.f90
#  fcon.f
)

set(FAUTOCON_SOURCES
  fcon.f
)
set(MPI_SOURCES
  ${MPI_SOURCE_FILE}
)

set(MESH_SOURCES
  mesh.f90
)

set(SUPPORT_SOURCES
  support.f90
)

set(IO_SOURCES
  io.f90
)

set(SOLVEBV_SOURCES
  solvebv.f90
)

set(INTERFACES_SOURCES
  interfaces.f90
)

set(AE_SOURCES
  ae.f90
)

set(BVP_SOURCES
  bvp.f90
)

set(TOOLBOX_AE_SOURCES
  toolboxae.f90
)

set(TOOLBOX_BV_SOURCES
  toolboxbv.f90
)

set(FLOQUET_SOURCES
  floquet.f90
)

set(EQUILIBRIUM_SOURCES
  equilibrium.f90
)

set(MAPS_SOURCES
  maps.f90
)

set(PERIODIC_SOURCES
  periodic.f90
)

set(OPTIMIZATION_SOURCES
  optimization.f90
)

set(PARABOLIC_SOURCES
  parabolic.f90
)

set(TIMEINT_SOURCES
  timeint.f90
)

set(HOMCONT_SOURCES
  homcont.f90
)

set(MAIN_SOURCES
  main.f90
)

set(ENTRY_SOURCES
  auto_entry.f90
)

set(USER_C_SOURCES
  user_c.f90
)

# Create the main auto_f library with all Fortran sources
add_library(auto_f
  ${BLAS_SOURCES}
  ${LAPACK_SOURCES}
  ${CORE_SOURCES}
  ${MPI_SOURCES}
  ${MESH_SOURCES}
  ${SUPPORT_SOURCES}
  ${IO_SOURCES}
  ${SOLVEBV_SOURCES}
  ${INTERFACES_SOURCES}
  ${AE_SOURCES}
  ${BVP_SOURCES}
  ${TOOLBOX_AE_SOURCES}
  ${TOOLBOX_BV_SOURCES}
  ${FLOQUET_SOURCES}
  ${EQUILIBRIUM_SOURCES}
  ${MAPS_SOURCES}
  ${PERIODIC_SOURCES}
  ${OPTIMIZATION_SOURCES}
  ${PARABOLIC_SOURCES}
  ${TIMEINT_SOURCES}
  ${HOMCONT_SOURCES}
  ${MAIN_SOURCES}
  ${ENTRY_SOURCES}
)


# Set include directories
target_include_directories(auto_f
  PUBLIC
    ${CMAKE_SOURCE_DIR}/include
)

# Add MPI support if requested
if(WITH_MPI)
  target_link_libraries(auto_f PUBLIC MPI::MPI_Fortran)
  target_compile_options(auto_f PUBLIC ${MPI_Fortran_COMPILE_FLAGS})
endif()

set_target_properties(auto_f PROPERTIES
  POSITION_INDEPENDENT_CODE ON
)

# Small C shim so we can build a shared library that embeds auto_f
add_library(auto_shared_dummy_c STATIC IMPORTED)

add_library(auto_shared SHARED ${CMAKE_CURRENT_SOURCE_DIR}/auto_shared_dummy.c)
add_dependencies(auto_shared auto_f)
# Link the static Fortran archive file directly so the required Fortran
# symbols are pulled into the shared library.
target_link_libraries(auto_shared PRIVATE
  ${CMAKE_BINARY_DIR}/src/libauto_f.a
)
set_target_properties(auto_shared PROPERTIES POSITION_INDEPENDENT_CODE ON)

install(TARGETS auto_shared LIBRARY DESTINATION lib)

# Create the libauto_c library from user_c.f90
add_library(auto_c STATIC)

set_target_properties(auto_c PROPERTIES
  LINKER_LANGUAGE Fortran
)

target_sources(auto_c PRIVATE ${USER_C_SOURCES})

target_include_directories(auto_c
  PUBLIC
    ${CMAKE_SOURCE_DIR}/include
)

target_link_libraries(auto_c
  PUBLIC
    auto_f
)


add_library(fautcon STATIC ${FAUTOCON_SOURCES})
target_link_libraries(fautcon auto_f auto_c)

# Installation
install(TARGETS auto_f auto_c
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
)

install(FILES
  ${MAIN_SOURCES}
  ${USER_C_SOURCES}
  DESTINATION src
)

# Add custom target to match original Makefile behavior
add_custom_target(clean-lib
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/lib
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.mod
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.o
)

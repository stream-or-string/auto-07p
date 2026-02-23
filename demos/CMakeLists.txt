cmake_minimum_required(VERSION 3.13)
enable_language(Fortran)

set (DEMOS  "ab   abc  abcb apbp  brc  brf bru  bvp  c2c  chu   cir  cusp  dd2  enz 
   exp  ext  ezp  ffn  fhn fnc  frc   fsh   hen   int  ivp  kar  lcbp  lin   log  
   lor  lrz  man  mtn  nag  nep non obv  ops  opt   p2c   pcl   pd1  pd2  pen  ph1 
   phs  pla   plp   pp2  pp3  ppp  pvl snh   spb   sspg  stw  tfc  tim  tor  um2 
   um3   vhb   wav fhh kpr rev she")

message(STATUS "============== ${CMAKE_CURRENT_SOURCE_DIR}==================")
message(STATUS "============== ${DEMOS}==================")

separate_arguments(DEMO_DIRS UNIX_COMMAND "${DEMOS}")

foreach(dir ${DEMO_DIRS})
    message(STATUS "Added subdirectory: ${dir}")
    file(GLOB SOURCE_FILES "${dir}/*.f90" "${dir}/*.f" "${dir}/*.c")
    if ("${SOURCE_FILES}" STREQUAL "")
        message(WARNING "No source files found in directory: ${dir}")
    else()
        add_executable (${dir} ${SOURCE_FILES})
        target_link_libraries(${dir} auto_f) 
    endif()
endforeach()

# the following are specials case because it needs fautcon, which is not linked to auto_f.
# or other reasons (e.g. fnb needs C/Fortran interoperability)
add_subdirectory(sib)
add_subdirectory(fnb)
add_subdirectory(san)
add_subdirectory(r3b)

# TODO
#add_subdirectory(kdv) # linking error: multiple definitions of

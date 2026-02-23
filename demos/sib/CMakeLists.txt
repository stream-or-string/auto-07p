cmake_minimum_required(VERSION 3.13)
enable_language(Fortran)   

message(STATUS " configuring demos in ${CMAKE_CURRENT_SOURCE_DIR}")

add_executable (sib sib.c)
target_link_libraries(sib fautcon)

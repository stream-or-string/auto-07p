cmake_minimum_required(VERSION 3.13)
enable_language(C Fortran)   

message(STATUS " configuring demos in ${CMAKE_CURRENT_SOURCE_DIR}")

add_executable (kdv)
target_sources(kdv PRIVATE kdv.c)
target_link_libraries(kdv fautcon)

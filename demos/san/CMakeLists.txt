cmake_minimum_required(VERSION 3.13)
enable_language(C Fortran)   

message(STATUS " configuring demos in ${CMAKE_CURRENT_SOURCE_DIR}")

add_executable (san)
target_sources(san PRIVATE san.f90)
target_link_libraries(san auto_f)

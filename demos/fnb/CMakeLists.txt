cmake_minimum_required(VERSION 3.13)
enable_language(Fortran)   
enable_language(C)

message(STATUS " configuring demos in ${CMAKE_CURRENT_SOURCE_DIR}")

# Build executable with proper C/Fortran interoperability using ISO_C_BINDING
# Use fhn_noheader.c instead of fhn.c to avoid static declarations in auto_f2c.h
add_executable(fnb fhn_noheader.c fhn_wrapper.f90)
target_include_directories(fnb PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(fnb auto_f)
install(TARGETS fnb DESTINATION ${AUTODIR}/demos/bin/)
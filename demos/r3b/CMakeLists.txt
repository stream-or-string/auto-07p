cmake_minimum_required(VERSION 3.13)
enable_language(Fortran)   

message(STATUS " configuring demos in ${CMAKE_CURRENT_SOURCE_DIR}")

add_executable (r3b)
target_sources(r3b PRIVATE r3b.f90)
target_link_libraries(r3b auto_f)

add_executable (r3bman)
target_sources(r3bman PRIVATE man.f90)
target_link_libraries(r3bman auto_f)

install(TARGETS r3b DESTINATION  ${AUTODIR}/demos/bin/)
install(TARGETS r3bman DESTINATION ${AUTODIR}/demos/bin/)
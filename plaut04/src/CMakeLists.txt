cmake_minimum_required(VERSION 3.6)

# Plaut04 Source - C++ GUI application

if(BUILD_PLAUT04)
  enable_language(CXX)

  # Get include directories
  set(INCLUDES_DIR "${CMAKE_SOURCE_DIR}/plaut04/includes")

  # Source files
  set(PLAUT04_SOURCES
    bifurcation.c++
    solution.c++
    stringtrim.c++
    tube.c++
    polygon3d.c++
    readFM.c++
    createBoundingBox.c++
    createCoords.c++
    axis.c++
    createLegend.c++
    gmain.c++
    rounding.c++
    printToPS.c++
    createSphere.c++
    createDisk.c++
  )

  # R3B specific sources
  set(R3B_SOURCES
    r3b/createLibPoint.c++
    r3b/createPrimary.c++
    r3b/gmainr3b.c++
    r3b/toInertialFrame.c++
  )

  # Check which GUI backend to use
  set(GUI_SOURCES ${PLAUT04_SOURCES})
  set(GUI_LIBS "")

  # Try Qt5 first if available
  if(Qt5_FOUND)
    message(STATUS "Building Plaut04 with Qt5 support")
    
    # Add MOC processing for Qt
    set(MOC_SOURCES gmainqt.c++)
    qt5_wrap_cpp(MOC_GENERATED gmainqt.h)
    
    list(APPEND GUI_SOURCES gmainqt.c++ ${MOC_GENERATED})
    set(GUI_LIBS Qt5::Core Qt5::Gui Qt5::OpenGL)
    
    # Check for Coin library (required dependency of SoQt)
    find_library(COIN_LIB Coin REQUIRED)
    list(APPEND GUI_LIBS ${COIN_LIB})
    
    # Check for SoQt
    find_library(SOQT_LIBRARY SoQt REQUIRED)
    if(SOQT_LIBRARY)
      list(APPEND GUI_LIBS ${SOQT_LIBRARY})
    endif()
    
  else()
    # Use SoXt as fallback
    message(STATUS "Building Plaut04 with SoXt support")
    list(APPEND GUI_SOURCES gmainxt.c++)
    
    # Link against Coin and SoXt
    find_library(COIN_LIB Coin REQUIRED)
    find_library(SOXT_LIB SoXt REQUIRED)
    list(APPEND GUI_LIBS ${COIN_LIB} ${SOXT_LIB})
    
    # Add X11 libraries if available
    find_package(X11)
    if(X11_FOUND)
      list(APPEND GUI_LIBS ${X11_LIBRARIES})
    endif()
  endif()

  # Create plaut04 executable
  add_executable(plaut04
    ${GUI_SOURCES}
    ${R3B_SOURCES}
  )

  if(Qt5_FOUND AND SOQT_LIBRARY)
      target_compile_definitions(plaut04 PRIVATE USE_SOQT)
    endif()

  # Set include directories
  target_include_directories(plaut04 PRIVATE
    "${INCLUDES_DIR}"
    "${CMAKE_SOURCE_DIR}/include"
  )

  # Link libraries
  target_link_libraries(plaut04 PRIVATE
    ${GUI_LIBS}
    m
  )

  # Set C++ flags
  set(CXX_FLAGS_TO_USE "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}}")
  set_target_properties(plaut04 PROPERTIES
    COMPILE_FLAGS "${CXX_FLAGS_TO_USE}"
  )

  # Create r3bplaut04 executable (variant for 3-body problem)
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/r3b/gmainr3b.c++")
    add_executable(r3bplaut04
      r3b/gmainr3b.c++
      ${GUI_SOURCES}
      ${R3B_SOURCES}
    )

    target_include_directories(r3bplaut04 PRIVATE
      "${INCLUDES_DIR}"
      "${CMAKE_SOURCE_DIR}/include"
    )

    target_link_libraries(r3bplaut04 PRIVATE
      ${GUI_LIBS}
      m
    )

  if(Qt5_FOUND AND SOQT_LIBRARY)
      target_compile_definitions(r3bplaut04 PRIVATE USE_SOQT)
    endif()

    set_target_properties(r3bplaut04 PROPERTIES
      COMPILE_FLAGS "${CXX_FLAGS_TO_USE}"
    )

    # Install r3bplaut04
    install(TARGETS r3bplaut04
      DESTINATION lib/auto-07p/bin)
  endif()

  # Install main plaut04 executable
  install(TARGETS plaut04
    DESTINATION lib/auto-07p/bin)

  # Install resource files
  install(FILES
    ../plaut04.rc
    ../r3bplaut04.rc
    DESTINATION lib/auto-07p/plaut04
    OPTIONAL)

  install(DIRECTORY ../widgets/
    DESTINATION lib/auto-07p/plaut04/widgets/
    OPTIONAL)

  install(DIRECTORY ../doc/
    DESTINATION lib/auto-07p/plaut04/doc/
    OPTIONAL)

endif()

# Clean target
add_custom_target(plaut04-src-clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory CMakeFiles
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.o
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/*.moc.c++
)

# Superclean target
add_custom_target(plaut04-src-superclean
  COMMAND ${CMAKE_CURRENT_BINARY_DIR} && ${CMAKE_MAKE_PROGRAM} plaut04-src-clean
)

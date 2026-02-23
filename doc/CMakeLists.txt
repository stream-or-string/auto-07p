cmake_minimum_required(VERSION 3.6)

# Documentation

if(BUILD_DOCUMENTATION)
  # Check for LaTeX/pdflatex for PDF generation
  find_package(LATEX)
  
  if(PDFLATEX_COMPILER)
    message(STATUS "pdflatex found - documentation can be built")
    
    # Add custom targets for building documentation
    add_custom_target(doc-user-guide
      COMMAND ${PDFLATEX_COMPILER} -interaction=nonstopmode user_guide.tex
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT user_guide.pdf
    )
    
    add_custom_target(doc-tutorial
      COMMAND ${PDFLATEX_COMPILER} -interaction=nonstopmode tutorial.tex
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT tutorial.pdf
    )
    
    add_custom_target(doc-plaut04-guide
      COMMAND ${PDFLATEX_COMPILER} -interaction=nonstopmode plaut04_user_guide.tex
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT plaut04_user_guide.pdf
    )
    
    # Add main documentation target
    add_custom_target(doc ALL
      DEPENDS doc-user-guide doc-tutorial doc-plaut04-guide
    )
    
    # Install documentation
    install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/user_guide.pdf
      ${CMAKE_CURRENT_BINARY_DIR}/tutorial.pdf
      ${CMAKE_CURRENT_BINARY_DIR}/plaut04_user_guide.pdf
      DESTINATION lib/auto-07p/doc
      OPTIONAL)
      
  else()
    message(STATUS "pdflatex not found - documentation will not be built")
    message(STATUS "Install latex (e.g., texlive) to build documentation")
  endif()
  
  # Install other doc files
  install(FILES
    README
    DESTINATION lib/auto-07p/doc
    OPTIONAL)
    
  install(DIRECTORY include/
    DESTINATION lib/auto-07p/doc/include
    OPTIONAL)

endif()

# Clean target
add_custom_target(doc-clean
  COMMAND ${CMAKE_COMMAND} -E remove
    ${CMAKE_CURRENT_BINARY_DIR}/*.pdf
    ${CMAKE_CURRENT_BINARY_DIR}/*.aux
    ${CMAKE_CURRENT_BINARY_DIR}/*.log
    ${CMAKE_CURRENT_BINARY_DIR}/*.out
    ${CMAKE_CURRENT_BINARY_DIR}/*.toc
)

# Superclean target
add_custom_target(doc-superclean
  COMMAND ${CMAKE_CURRENT_BINARY_DIR} && ${CMAKE_MAKE_PROGRAM} doc-clean
)

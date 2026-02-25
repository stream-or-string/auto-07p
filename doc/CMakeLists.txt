cmake_minimum_required(VERSION 3.13)

# prerquesite: copy doc files to build directory: build/doc
function (convert_to_pdf conv_command file_type)

    file(GLOB FILES_TO_CONVERT "${CMAKE_CURRENT_BINARY_DIR}/include/*.${file_type}")
    foreach(EFILE ${FILES_TO_CONVERT})
        string(REGEX REPLACE "\\.${file_type}$" ".pdf" PDF_FILE_REL ${EFILE})
        add_custom_command(
            OUTPUT ${PDF_FILE_REL}
            COMMAND ${conv_command}
            ARGS "--outfile=${PDF_FILE_REL}" ${EFILE}
            DEPENDS ${EFILE}
            COMMENT "Converting ${EFILE} to ${PDF_FILE_REL}"
            VERBATIM
        )

        list(APPEND CONVERTED_PDFS ${PDF_FILE_REL})
    endforeach()

    add_custom_target(convert_${file_type}_to_PDF ALL DEPENDS ${CONVERTED_PDFS} auto_f)
    set(${file_type}_PDF_FILES ${CONVERTED_PDFS} CACHE INTERNAL "Converted ${file_type} to PDF files")
endfunction()

# prerquesite: copy doc files to build directory: build/doc
function (convert_fig_to_pdf)

  find_program(FIG2DEV_EXE NAME fig2dev HINTS /usr/bin /usr/local/bin /opt/local/bin)
  if(FIG2DEV_EXE)
    file(GLOB FIG_FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/*.fig)
    foreach(FIG_FILE ${FIG_FILES})
      get_filename_component(FIG_NAME ${FIG_FILE} NAME_WE)
      set(FIG_PDF_FILE "${CMAKE_CURRENT_BINARY_DIR}/include/${FIG_NAME}.pdf")

      add_custom_command(
          OUTPUT ${FIG_PDF_FILE}
          COMMAND ${FIG2DEV_EXE} -L pdf ${FIG_FILE} ${FIG_PDF_FILE}
          DEPENDS ${FIG_FILE}
          COMMENT "Converting ${FIG_NAME}.fig to ${FIG_NAME}.pdf"
          VERBATIM
      )
      list(APPEND PDF_FILES ${FIG_PDF_FILE})
    endforeach()

    add_custom_target(convert_figs ALL DEPENDS ${PDF_FILES} auto_f)
  else()
      message(FATAL_ERROR "*** fig2dev not found! Please install TeX Live/MiKTeX + fig2dev. ***")
  endif()    
endfunction()

if(BUILD_DOCUMENTATION)
  
  file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/" DESTINATION "${CMAKE_BINARY_DIR}/doc"
     FILE_PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)

  find_program(EPSTOPDF_EXE epstopdf REQUIRED)
  if(EPSTOPDF_EXE)
    convert_to_pdf(${EPSTOPDF_EXE} "eps")
    convert_to_pdf(${EPSTOPDF_EXE} "ps")
  else()
      message(FATAL_ERROR "*** epstopdf not found! Please install full TeX Live/MiKTeX including texlive-font-utils. ***")
  endif()
  
  convert_fig_to_pdf()

  find_package(LATEX)
  if(PDFLATEX_COMPILER)
    add_custom_target(doc-user-guide
        DEPENDS convert_eps_to_PDF convert_ps_to_PDF convert_figs auto_f
      COMMAND ${PDFLATEX_COMPILER} -interaction=nonstopmode ${CMAKE_CURRENT_SOURCE_DIR}/user_guide.tex
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/user_guide.pdf
    )

    add_custom_target(doc-autopdf
      DEPENDS convert_eps_to_PDF convert_ps_to_PDF convert_figs auto_f
      COMMAND ${PDFLATEX_COMPILER} -interaction=nonstopmode ${CMAKE_CURRENT_SOURCE_DIR}/auto.tex
      COMMAND	${PDFLATEX_COMPILER} -interaction=nonstopmode auto.tex
      COMMAND	bibtex auto
      COMMAND	${PDFLATEX_COMPILER} -interaction=nonstopmode auto.tex
      COMMAND	${PDFLATEX_COMPILER} -interaction=nonstopmode auto.tex
      COMMAND	${PDFLATEX_COMPILER} -interaction=nonstopmode auto.tex
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/auto.pdf
    )

    add_custom_target(doc ALL
      DEPENDS doc-autopdf doc-user-guide auto_f
    )
    
    install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/user_guide.pdf
      ${CMAKE_CURRENT_BINARY_DIR}/auto.pdf
      DESTINATION lib/auto-07p/doc
      OPTIONAL)
      
  else()
    message(FATAL_ERROR "*** pdflatex not found - documentation will not be built ***")
    message(FATAL_ERROR "*** Install latex (e.g., texlive) to build documentation ***")
  endif()
  
  #[[ We don't want to install these
  install(FILES
    README
    DESTINATION lib/auto-07p/doc
    OPTIONAL)
    
  install(DIRECTORY include/
    DESTINATION lib/auto-07p/doc/include
    OPTIONAL)
  ]]

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

# Try to find XercesC

find_library(XercesC_LIBRARY
  NAMES xerces-c
)
find_path(XercesC_INCLUDE_DIR
  NAMES xercesc/util/PlatformUtils.hpp
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(XercesC DEFAULT_MSG
  XercesC_LIBRARY XercesC_INCLUDE_DIR
)

mark_as_advanced(XercesC_INCLUDE_DIR XercesC_LIBRARY)

if(XERCESC_FOUND)
  set(XercesC_LIBRARIES ${XercesC_LIBRARY})
  set(XercesC_INCLUDE_DIRS ${XercesC_INCLUDE_DIR})

  if(NOT TARGET XercesC::XercesC)
    add_library(XercesC::XercesC UNKNOWN IMPORTED)
    set_target_properties(XercesC::XercesC PROPERTIES
      IMPORTED_LOCATION "${XercesC_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${XercesC_INCLUDE_DIR}"
    )
  endif()
endif()


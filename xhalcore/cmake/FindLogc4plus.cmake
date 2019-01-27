# Try to find log4cplus

find_library(Log4cplus_LIBRARY
  NAMES log4cplus
)
find_path(Log4cplus_INCLUDE_DIR
  NAMES log4cplus/logger.h
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Log4cplus DEFAULT_MSG
  Log4cplus_LIBRARY Log4cplus_INCLUDE_DIR
)

mark_as_advanced(Log4cplus_INCLUDE_DIR Log4cplus_LIBRARY)

if(LOG4CPLUS_FOUND)
  set(Log4cplus_LIBRARIES ${Log4cplus_LIBRARY})
  set(Log4cplus_INCLUDE_DIRS ${Log4cplus_INCLUDE_DIR})

  if(NOT TARGET Log4cplus::Log4cplus)
    add_library(Log4cplus::Log4cplus UNKNOWN IMPORTED)
    set_target_properties(Log4cplus::Log4cplus PROPERTIES
      IMPORTED_LOCATION "${Log4cplus_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Log4cplus_INCLUDE_DIR}"
    )
  endif()
endif()


set(CMAKE_CXX_STANDARD 11)

find_package(wiscrpcsvc REQUIRED)
find_package(xDAQ REQUIRED
  COMPONENTS log4cplus xerces-c)
find_package(PythonLibs REQUIRED)
find_package(Boost REQUIRED
  COMPONENTS python)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")

install(DIRECTORY include/xhal
  DESTINATION include/
  FILES_MATCHING PATTERN *.h
)

# xHAL helpers
add_library(xhal_helpers SHARED
  src/common/utils/XHALXMLParser.cpp
)

target_link_libraries(xhal_helpers
  PUBLIC xDAQ::log4cplus
  PRIVATE xDAQ::xerces-c
)

install(TARGETS xhal_helpers
  EXPORT xHALConfig
  INCLUDES DESTINATION include/
  LIBRARY DESTINATION lib/
)

# xHAL core 
add_library(xhal_core SHARED
  src/common/XHALInterface.cpp
  src/common/XHALDevice.cpp
)

target_link_libraries(xhal_core
  PUBLIC xDAQ::log4cplus
  PRIVATE wiscrpcsvc::wiscrpcsvc xhal_helpers
)

install(TARGETS xhal_core
  EXPORT xHALConfig
  INCLUDES DESTINATION include/
  LIBRARY DESTINATION lib/
)

# RPCman
add_library(rpcman SHARED
  src/common/rpc_manager/calibration_routines.cpp
  src/common/rpc_manager/daq_monitor.cpp
  src/common/rpc_manager/optohybrid.cpp
  src/common/rpc_manager/utils.cpp
  src/common/rpc_manager/vfat3.cpp
)

target_link_libraries(rpcman
  PUBLIC xhal_core
)

install(TARGETS rpcman
  EXPORT xHALConfig
  INCLUDES DESTINATION include/
  LIBRARY DESTINATION lib/
)

# xHALpy
add_library(xhalpy SHARED
  src/common/python_wrappers/XHALInterface_python.cpp
)

target_include_directories(xhalpy
  PUBLIC ${PYTHON_INCLUDE_DIRS})
target_link_libraries(xhalpy
  PUBLIC Boost::python ${PYTHON_LIBRARIES})

target_link_libraries(xhalpy
  PRIVATE xhal_core rpcman
)

install(TARGETS xhalpy
  EXPORT xHALConfig
  INCLUDES DESTINATION include/
  LIBRARY DESTINATION lib/
)

install(EXPORT xHALConfig NAMESPACE xHAL:: DESTINATION share/xHAL)

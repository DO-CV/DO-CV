# Use ccache if available!
find_program(CCACHE_PROGRAM ccache)

if (CCACHE_PROGRAM)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_PROGRAM})
endif ()

# Configure the build correctly if we generate an Xcode project.
get_property(RULE_LAUNCH_COMPILE GLOBAL PROPERTY RULE_LAUNCH_COMPILE)

if (RULE_LAUNCH_COMPILE AND CMAKE_GENERATOR STREQUAL "Xcode")
  # Set up wrapper scripts
  configure_file(cmake/xcode/launch-c.in launch-c)
  configure_file(cmake/xcode/launch-cxx.in launch-cxx)
  execute_process(COMMAND chmod a+rx
    "${CMAKE_BINARY_DIR}/launch-c"
    "${CMAKE_BINARY_DIR}/launch-cxx")

  # Set Xcode project attributes to route compilation and linking
  # through our scripts
  set(CMAKE_XCODE_ATTRIBUTE_CC         "${CMAKE_BINARY_DIR}/launch-c")
  set(CMAKE_XCODE_ATTRIBUTE_CXX        "${CMAKE_BINARY_DIR}/launch-cxx")
  set(CMAKE_XCODE_ATTRIBUTE_LD         "${CMAKE_BINARY_DIR}/launch-c")
  set(CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS "${CMAKE_BINARY_DIR}/launch-cxx")
endif ()

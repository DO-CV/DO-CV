# Where to output the binaries.
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


# Install the sources.
if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  # Eigen 3
  sara_message("Installing Eigen")
  install(DIRECTORY ${DO_Sara_ThirdParty_DIR}/eigen/Eigen
          DESTINATION ${SARA_INSTALL_DIR}/include
          COMPONENT ThirdParty)
  set(CPACK_COMPONENT_ThirdParty_REQUIRED 1)

  # License files.
  install(FILES ${DO_Sara_DIR}/COPYING.README
                ${DO_Sara_DIR}/COPYING.MPL2
          DESTINATION ${SARA_INSTALL_DIR}/include/DO/Sara
          COMPONENT Sources)

  # CMake scripts.
  configure_file(cmake/DO_SaraConfig.cmake.in
                 ${CMAKE_BINARY_DIR}/cmake/DO_SaraConfig.cmake @ONLY)
  file(COPY cmake DESTINATION ${CMAKE_BINARY_DIR})

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cmake
          DESTINATION ${SARA_INSTALL_DIR}/share/DO_Sara
          COMPONENT Sources)

  # Source files.
  install(FILES ${CMAKE_BINARY_DIR}/src/DO/Sara/Defines.hpp
          DESTINATION ${SARA_INSTALL_DIR}/include/DO/Sara
          COMPONENT Sources)
  install(DIRECTORY ${DO_Sara_DIR}/src/DO
          DESTINATION ${SARA_INSTALL_DIR}/include
          COMPONENT Sources)

  set(CPACK_COMPONENT_Sources_REQUIRED 1)
endif ()

# DO-Sara component libraries
foreach (component ${DO_Sara_COMPONENTS})
  sara_message("Installing DO_Sara_${component}")
  include(${DO_Sara_${component}_USE_FILE})
endforeach (component)


# List all available components for installation.
set(CPACK_COMPONENTS_ALL ThirdParty Sources Libraries)


if (WIN32)
  set(CPACK_PACKAGE_NAME "DO-Sara")
else()
  set(CPACK_PACKAGE_NAME "libDO-Sara")
endif ()
if (SARA_BUILD_SHARED_LIBS)
  set(CPACK_PACKAGE_NAME "${CPACK_PACKAGE_NAME}-shared")
else ()
  set(CPACK_PACKAGE_NAME "${CPACK_PACKAGE_NAME}-static")
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CPACK_PACKAGE_NAME "${CPACK_PACKAGE_NAME}-dbg")
endif ()

set(CPACK_PACKAGE_VENDOR "DO-CV")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY
    "DO-Sara: An easy-to-use C++ set of libraries for computer vision")
set(CPACK_RESOURCE_FILE_LICENSE "${DO_Sara_DIR}/COPYING.README")
set(CPACK_PACKAGE_CONTACT "David OK <david.ok8@gmail.com>")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

set(CPACK_PACKAGE_VERSION_MAJOR ${DO_Sara_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${DO_Sara_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${DO_Sara_BUILD_NUMBER})
set(CPACK_PACKAGE_VERSION ${DO_Sara_VERSION})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "DO-Sara")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "DO-Sara-${CMAKE_BUILD_TYPE}")
endif ()



# ============================================================================ #
# Special configuration for Debian packages.
#
set(CPACK_DEBIAN_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION})
#set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "cmake, libjpeg-dev, libpng-dev, libtiff5-dev, qtbase5-dev")


# ============================================================================ #
# Special configuration for RPM packages.
#
set(CPACK_RPM_PACKAGE_RELEASE ${DO_Sara_VERSION})
set(CPACK_RPM_PACKAGE_LICENSE "MPL v2")
set(CPACK_RPM_PACKAGE_GROUP "Applications/Multimedia")

execute_process(COMMAND python -c
  "from distutils.sysconfig import get_python_lib; print(get_python_lib())"
  OUTPUT_VARIABLE PYTHON_SITE_PACKAGES_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE)

list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST
  /usr
  /usr/include
  /usr/lib
  /usr/share
  /usr/local
  /usr/local/include
  /usr/local/lib
  /usr/local/share
  ${SARA_INSTALL_DIR}
  ${SARA_INSTALL_DIR}/include
  ${SARA_INSTALL_DIR}/lib
  ${SARA_INSTALL_DIR}/share
  $ENV{WORKON_HOME}
  $ENV{VIRTUAL_ENV}
  $ENV{VIRTUAL_ENV}/lib
  $ENV{VIRTUAL_ENV}/lib/python2
  $ENV{VIRTUAL_ENV}/lib/python2.7
  ${PYTHON_SITE_PACKAGES_DIR}
  ${PYTHON_SITE_PACKAGES_DIR}/do)


# ============================================================================ #
# Special configuration for Windows installer using NSIS.
#
# Installers for 32- vs. 64-bit CMake:
#  - Root install directory (displayed to end user at installer-run time)
#  - "NSIS package/display name" (text used in the installer GUI)
#  - Registry key used to store info about the installation
if(CMAKE_CL_64)
  set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
  set(CPACK_NSIS_PACKAGE_NAME
      "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION} Win64")
  set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY
      "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION} Win64")
else()
  set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES")
  set(CPACK_NSIS_PACKAGE_NAME
      "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION} Win32")
  set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY
      "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION} Win32")
endif()
set(CPACK_NSIS_COMPRESSOR "/SOLID lzma")

set(CPACK_NSIS_DISPLAY_NAME ${CPACK_NSIS_PACKAGE_NAME})

# ============================================================================ #
# Select package generator.
if (WIN32)
  set(CPACK_GENERATOR NSIS)
elseif (UNIX)
  if (EXISTS /etc/debian_version)
    set(CPACK_GENERATOR "DEB")
  else ()
    set(CPACK_GENERATOR "RPM")
  endif ()
endif ()

# Adapted from https://gist.github.com/RenatoUtsch/1623340
#
# - Try to find GMP.
# Once done this will define:
# GMP_FOUND			- If false, do not try to use GMP.
# GMP_INCLUDE_DIRS	- Where to find GMP.h, etc.
# GMP_LIBRARIES		- The libraries to link against.
# GMP_VERSION_STRING	- Version in a string of GMP.
#
# Created by RenatoUtsch based on eAthena implementation.
#
# Please note that this module only supports Windows and Linux officially, but
# should work on all UNIX-like operational systems too.
#
#=============================================================================
# original gist (https://gist.github.com/RenatoUtsch/1623340) Copyright 2012 RenatoUtsch
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

find_library( GMP_LIBRARY
        NAMES
            "libgmp"
            "libgmp-10"
            "libgmp.so"
            "libgmp.so.10"
            "libgmp-10.so"
            "libgmp.dll"
            "libgmp-10.dll"
            "libgmp.dylib"
            "libgmp-10.dylib"
        PATHS
            "/lib"
            "/lib64"
            "/usr/lib"
            "/usr/lib64"
            "/usr/local/lib"
            "/usr/local/lib64"
            "C:\\Windows\\System32"
        )
if (GMP_LIBRARY)
    set(GMP_INCLUDE_DIR ../include)
endif()

# handle the QUIETLY and REQUIRED arguments and set GMP_FOUND to TRUE if
# all listed variables are TRUE
include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( GMP DEFAULT_MSG
        REQUIRED_VARS	GMP_LIBRARY GMP_INCLUDE_DIR )

set( GMP_INCLUDE_DIRS ${GMP_INCLUDE_DIR} )
set( GMP_LIBRARIES ${GMP_LIBRARY} )

mark_as_advanced( GMP_INCLUDE_DIR GMP_LIBRARY )

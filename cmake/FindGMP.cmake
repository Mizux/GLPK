#### LICENSE ####
# This file is copied from the Dune project (http://dune-project.org/), specifically the dune-project/dune-common git
# repo (https://github.com/dune-project/dune-common), and is thus licensed under a modified GPLv2 license. A copy of
# that license can be found in this directory as `dune-common-gplv2.md`.
#
# The original file can be found at https://github.com/dune-project/dune-common/blob/v2.8.0/cmake/modules/FindGMP.cmake
#
# Copyright holders:
# ==================
#
# 2015--2017    Marco Agnese
# 2015          Martin Alkämper
# 2003--2019    Peter Bastian
# 2004--2020    Markus Blatt
# 2013          Andreas Buhr
# 2020--2021    Samuel Burbulla
# 2011--2020    Ansgar Burchardt
# 2004--2005    Adrian Burri
# 2014          Benjamin Bykowski (may appear in the logs as "Convex Function")
# 2014          Marco Cecchetti
# 2018          Matthew Collins
# 2006--2021    Andreas Dedner
# 2019--2021    Nils-Arne Dreier
# 2003          Marc Droske
# 2003--2021    Christian Engwer
# 2004--2020    Jorrit Fahlke
# 2016          Thomas Fetzer
# 2008--2017    Bernd Flemisch
# 2013--2014    Christoph Gersbacher
# 2017--2020    Janick Gerstenberger
# 2015          Stefan Girke
# 2005--2021    Carsten Gräser
# 2015--2017    Felix Gruber
# 2010--2021    Christoph Grüninger
# 2006          Bernhard Haasdonk
# 2015--2018    Claus-Justus Heine
# 2015--2020    René Heß
# 2017--2019    Stephan Hilb
# 2017--2021    Lasse Hinrichsen
# 2012--2013    Olaf Ippisch
# 2020          Patrick Jaap
# 2020          Liam Keegan
# 2013--2021    Dominic Kempf
# 2009          Leonard Kern
# 2017--2018    Daniel Kienle
# 2013          Torbjörn Klatt
# 2003--2021    Robert Klöfkorn
# 2017--2021    Timo Koch
# 2005--2007    Sreejith Pulloor Kuttanikkad
# 2012--2016    Arne Morten Kvarving
# 2010--2014    Andreas Lauser
# 2016--2019    Tobias Leibner
# 2015          Lars Lubkoll
# 2012--2017    Tobias Malkmus
# 2007--2011    Sven Marnach
# 2010--2017    Rene Milk
# 2019--2020    Felix Müller
# 2011--2019    Steffen Müthing
# 2018          Lisa Julia Nebel
# 2003--2006    Thimo Neubauer
# 2011          Rebecca Neumann
# 2008--2018    Martin Nolte
# 2014          Andreas Nüßing
# 2004--2005    Mario Ohlberger
# 2019--2020    Santiago Ospina De Los Rios
# 2014          Steffen Persvold
# 2008--2017    Elias Pipping
# 2021          Joscha Podlesny
# 2011          Dan Popovic
# 2017--2021    Simon Praetorius
# 2009          Atgeirr Rasmussen
# 2017--2020    Lukas Renelt
# 2006--2014    Uli Sack
# 2003--2020    Oliver Sander
# 2006          Klaus Schneider
# 2004          Roland Schulz
# 2015          Nicolas Schwenck
# 2016          Linus Seelinger
# 2009--2014    Bård Skaflestad
# 2019          Henrik Stolzmann
# 2012          Matthias Wohlmuth
# 2011--2016    Jonathan Youett

#[=======================================================================[.rst:
FindGMP
-------

Find the GNU MULTI-Precision Bignum (GMP) library
and the corresponding C++ bindings GMPxx.

This module searches for both libraries and only considers the package
found if both can be located. It then defines separate targets for the C
and the C++ library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``GMP::gmp``
  Library target of the C library.
``GMP::gmpxx``
  Library target of the C++ library, which also links to the C library.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``GMP_FOUND``
  True if the GMP library, the GMPxx headers and
  the GMPxx library were found.

Cache Variables
^^^^^^^^^^^^^^^

You may set the following variables to modify the behaviour of
this module:

``GMP_INCLUDE_DIR``
  The directory containing ``gmp.h``.
``GMP_LIB``
  The path to the gmp library.
``GMPXX_INCLUDE_DIR``
  The directory containing ``gmpxx.h``.
``GMPXX_LIB``
  The path to the gmpxx library.

#]=======================================================================]

# Add a feature summary for this package
include(FeatureSummary)
set_package_properties(GMP PROPERTIES
        DESCRIPTION "GNU multi-precision library"
        URL "https://gmplib.org"
        )

# Try finding the package with pkg-config
find_package(PkgConfig QUIET)
pkg_check_modules(PKG QUIET gmp gmpxx)

# Try to locate the libraries and their headers, using pkg-config hints
find_path(GMP_INCLUDE_DIR gmp.h HINTS ${PKG_gmp_INCLUDEDIR})
find_library(GMP_LIB gmp HINTS ${PKG_gmp_LIBDIR})

find_path(GMPXX_INCLUDE_DIR gmpxx.h HINTS ${PKG_gmpxx_INCLUDEDIR})
find_library(GMPXX_LIB gmpxx HINTS ${PKG_gmpxx_LIBDIR})

# Remove these variables from cache inspector
mark_as_advanced(GMP_INCLUDE_DIR GMP_LIB GMPXX_INCLUDE_DIR GMPXX_LIB)

# Report if package was found
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP
        DEFAULT_MSG
        GMPXX_LIB GMPXX_INCLUDE_DIR GMP_INCLUDE_DIR GMP_LIB
        )

# Set targets
if(GMP_FOUND)
    # C library
    if(NOT TARGET GMP::gmp)
        add_library(GMP::gmp UNKNOWN IMPORTED)
        set_target_properties(GMP::gmp PROPERTIES
                IMPORTED_LOCATION ${GMP_LIB}
                INTERFACE_INCLUDE_DIRECTORIES ${GMP_INCLUDE_DIR}
                )
    endif()

    # C++ library, which requires a link to the C library
    if(NOT TARGET GMP::gmpxx)
        add_library(GMP::gmpxx UNKNOWN IMPORTED)
        set_target_properties(GMP::gmpxx PROPERTIES
                IMPORTED_LOCATION ${GMPXX_LIB}
                INTERFACE_INCLUDE_DIRECTORIES ${GMPXX_INCLUDE_DIR}
                INTERFACE_LINK_LIBRARIES GMP::gmp
                )
    endif()

endif()
cmake_minimum_required(VERSION 3.10)

# Enable Fortran language support
enable_language(Fortran OPTIONAL)

if(NOT CMAKE_Fortran_COMPILER)
    message(FATAL_ERROR "No Fortran compiler found. Install gfortran or ifort and set FC environment variable or CMAKE_Fortran_COMPILER.")
endif()

project(netCDF_extract Fortran)

# Set Fortran standard
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)
set(CMAKE_Fortran_FLAGS_INIT "-free")

# Compiler-specific flags
if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O2")
    message(STATUS "Using Intel Fortran compiler")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O2 -ffree-form")
    message(STATUS "Using GNU Fortran compiler")
else()
    message(STATUS "Using unknown Fortran compiler: ${CMAKE_Fortran_COMPILER_ID}")
endif()

message(STATUS "Fortran compiler: ${CMAKE_Fortran_COMPILER}")
message(STATUS "Fortran flags: ${CMAKE_Fortran_FLAGS}")

# Find NetCDF Fortran library - try multiple methods
# Method 1: CMake config package
find_package(NetCDF CONFIG QUIET)

# Method 2: pkg-config
if(NOT NetCDF_FOUND)
    find_package(PkgConfig QUIET)
    if(PkgConfig_FOUND)
        pkg_search_module(NetCDF QUIET netcdf-fortran netcdf)
    endif()
endif()

# Method 3: nc-config utility
if(NOT NetCDF_FOUND)
    find_program(NC_CONFIG NAMES nc-config)
    if(NC_CONFIG)
        execute_process(COMMAND ${NC_CONFIG} --fflags 
                       OUTPUT_VARIABLE NC_FFLAGS 
                       OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${NC_CONFIG} --flibs 
                       OUTPUT_VARIABLE NC_LIBS 
                       OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${NC_CONFIG} --prefix 
                       OUTPUT_VARIABLE NC_PREFIX 
                       OUTPUT_STRIP_TRAILING_WHITESPACE)
        
        set(NETCDF_INCLUDE_DIRS "${NC_PREFIX}/include")
        set(NETCDF_LIBRARIES ${NC_LIBS})
        message(STATUS "Found NetCDF via nc-config: ${NC_PREFIX}")
        set(NetCDF_FOUND TRUE)
    endif()
endif()

# Method 4: Standard system locations
if(NOT NetCDF_FOUND)
    find_path(NETCDF_INCLUDE_DIR netcdf.mod 
              PATHS /usr/include /usr/local/include /opt/netcdf/include
              DOC "NetCDF Fortran module directory")
    
    if(NETCDF_INCLUDE_DIR)
        set(NETCDF_INCLUDE_DIRS ${NETCDF_INCLUDE_DIR})
        find_library(NETCDF_LIBRARY NAMES netcdff netcdf_fortran
                    PATHS /usr/lib /usr/local/lib /usr/lib/x86_64-linux-gnu /opt/netcdf/lib)
        if(NETCDF_LIBRARY)
            set(NETCDF_LIBRARIES ${NETCDF_LIBRARY})
            message(STATUS "Found NetCDF in standard locations")
            set(NetCDF_FOUND TRUE)
        endif()
    endif()
endif()

if(NOT NetCDF_FOUND)
    message(FATAL_ERROR "
NetCDF not found!

To fix this, install NetCDF development libraries:

Ubuntu/Debian:
  sudo apt-get install libnetcdf-dev libnetcdff-dev

macOS (Homebrew):
  brew install netcdf netcdf-fortran

Then set one of these options:
  1. Ensure nc-config is in PATH
  2. Set NetCDF_DIR environment variable
  3. Set CMAKE_PREFIX_PATH to NetCDF installation path

Example:
  cmake -DNetCDF_DIR=/usr/local/netcdf ..
")
endif()

message(STATUS "NetCDF include: ${NETCDF_INCLUDE_DIRS}")
message(STATUS "NetCDF libraries: ${NETCDF_LIBRARIES}")

# Include directories
include_directories(${NETCDF_INCLUDE_DIRS})

# Add source directory
add_subdirectory(src)

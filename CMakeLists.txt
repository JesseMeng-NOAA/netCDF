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

# Find NetCDF Fortran library
find_package(NetCDF REQUIRED COMPONENTS Fortran)
message(STATUS "NetCDF found: ${NETCDF_INCLUDE_DIRS}")

# Include directories
include_directories(${NETCDF_INCLUDE_DIRS})

# Add source directory
add_subdirectory(src)

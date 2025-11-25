#!/bin/bash

# Load NetCDF module
module load netcdf

# Check if nc-config is available
if command -v nc-config &> /dev/null; then
    echo "Using nc-config to set compiler and linker flags..."
    FFLAGS=$(nc-config --fflags)
    FLIBS=$(nc-config --flibs)
else
    echo "nc-config not found. Using default NETCDF environment variables..."
    # Set these if your module sets NETCDF_INCDIR and NETCDF_LIBDIR
    FFLAGS="-I$NETCDF_INCDIR"
    FLIBS="-L$NETCDF_LIBDIR -lnetcdff -lnetcdf"
fi

# Compile the Fortran code
ifort -free netcdf.tmp2m.f90 $FFLAGS $FLIBS -o netcdf.tmp2m.exe

# Optional: run the executable
# ./netcdf.tmp2m.exe


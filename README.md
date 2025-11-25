# netCDF

Utility for netcdf input/output coding.
Read a GFS netcdf output file and extract lon/lat/tmp2m variables to a new file.

## Overview

This project provides a Fortran utility to:
- Read NetCDF files containing GFS model output
- Extract coordinate variables (`lon`, `lat`, `grid_xt`, `grid_yt`)
- Extract a target variable (`tmp2m` — 2-meter temperature)
- Preserve all variable and global attributes
- Write extracted data to a new NetCDF file

## Project Structure

```
.
├── CMakeLists.txt              # CMake build configuration (root)
├── Makefile                    # GNU Make build configuration
├── CMAKE_BUILD.md              # CMake build instructions
├── README.md                   # This file
├── src/
│   ├── CMakeLists.txt         # CMake source rules
│   ├── extract_var.f90        # Main program
│   ├── copy_var_attributes.f90    # Subroutine for variable attributes
│   └── copy_global_attributes.f90 # Subroutine for global attributes
├── v1.0/                       # Original monolithic version
├── v2.0/                       # Modular version with Makefile
└── build/                      # Build artifacts (created during build)
```

## Prerequisites

### System Requirements
- Fortran compiler: `gfortran` (GNU) or `ifort` (Intel)
- NetCDF Fortran library (`libnetcdff`)
- CMake 3.10+ (for CMake build) OR GNU Make (for Makefile build)

### Install Dependencies

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install gfortran libnetcdf-dev libnetcdff-dev cmake
```

#### macOS (Homebrew)
```bash
brew install gcc netcdf cmake
```

#### RedHat/CentOS
```bash
sudo yum install gcc-gfortran netcdf-fortran-devel cmake
```

## Building

### Option 1: CMake (Recommended)

CMake provides better cross-platform support and integrates with IDEs.

```bash
# Create and enter build directory
mkdir -p build
cd build

# Configure (automatic compiler detection)
cmake ..

# Build
cmake --build .

# Run
./netcdf.tmp2m.exe input.nc output.nc

# Clean build artifacts
cd ..
rm -rf build
```

**Specify compiler explicitly:**
```bash
FC=gfortran cmake ..
FC=ifort cmake ..
```

**Build with verbose output:**
```bash
cmake --build . -- VERBOSE=1
```

For more CMake options and troubleshooting, see [CMAKE_BUILD.md](CMAKE_BUILD.md).

### Option 2: GNU Make

Simple, lightweight alternative to CMake.

```bash
# Build
make

# View compiler configuration
make info

# Run
./netcdf.tmp2m.exe input.nc output.nc

# Clean object files and modules
make clean

# Clean everything including executable
make distclean

# Show help
make help
```

**Specify compiler:**
```bash
make FC=gfortran
make FC=ifort
```

## Usage

```bash
./netcdf.tmp2m.exe <input.nc> <output.nc>
```

### Arguments
- `input.nc` — Path to input GFS NetCDF file
- `output.nc` — Path to output NetCDF file (will be created/overwritten)

### Example
```bash
./netcdf.tmp2m.exe gfs_output.nc extracted_data.nc
```

## Troubleshooting

### Compiler not found
```bash
# Install gfortran
sudo apt-get install gfortran

# Or check PATH
which gfortran
which ifort

# Set compiler explicitly for CMake
FC=/usr/bin/gfortran cmake ..
# Or for Make
make FC=/usr/bin/gfortran
```

### NetCDF library not found
```bash
# Install NetCDF development libraries
sudo apt-get install libnetcdf-dev libnetcdff-dev

# Or specify location for CMake
cmake -DNetCDF_DIR=/usr/lib/netcdf ..
```

### Build errors
- Ensure Fortran compiler is in PATH: `which gfortran`
- Verify NetCDF headers: `nc-config --fflags`
- Check linker flags: `nc-config --flibs`

## File Descriptions

- **`extract_var.f90`** — Main program that orchestrates file I/O and variable extraction
- **`copy_var_attributes.f90`** — Subroutine to copy variable-level attributes (units, long_name, etc.)
- **`copy_global_attributes.f90`** — Subroutine to copy file-level global attributes (title, source, etc.)

## Version History

- **v2.0** — Refactored into modular source files with CMake and Makefile support
- **v1.0** — Original monolithic implementation in Python and Fortran

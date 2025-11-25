# CMake Build Instructions

## Prerequisites
- CMake 3.10 or later
- Fortran compiler: `gfortran` (GNU) or `ifort` (Intel)
- NetCDF Fortran library

### Install Dependencies (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install cmake gfortran libnetcdf-dev libnetcdff-dev
```

### Install Dependencies (macOS with Homebrew)
```bash
brew install cmake gcc netcdf
```

## Build Steps

### 1. Create and enter build directory
```bash
mkdir -p build
cd build
```

### 2. Configure with CMake
```bash
# Automatic detection
cmake ..

# Or specify compiler explicitly
FC=gfortran cmake ..
FC=ifort cmake ..
```

### 3. Build
```bash
cmake --build .
# Or
make
```

### 4. Run the executable
```bash
./netcdf.tmp2m.exe input.nc output.nc
```

### 5. Clean build artifacts
```bash
cd build
rm -rf *
```

## CMake Configuration Options

### Set build type
```bash
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake -DCMAKE_BUILD_TYPE=Debug ..
```

### Install to system
```bash
cmake --install .
# Or (older CMake)
make install
```

### View CMake configuration
```bash
cmake --system-information
```

## Troubleshooting

### Compiler not found
Set the `FC` environment variable:
```bash
export FC=/usr/bin/gfortran
cmake ..
```

### NetCDF not found
Set `NetCDF_DIR`:
```bash
cmake -DNetCDF_DIR=/path/to/netcdf ..
```

Or set `CMAKE_PREFIX_PATH`:
```bash
cmake -DCMAKE_PREFIX_PATH=/usr/local ..
```

### Check what CMake found
```bash
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON
make VERBOSE=1
```

## Directory Structure
```
.
├── CMakeLists.txt          (Root CMake configuration)
├── src/
│   ├── CMakeLists.txt      (Source build rules)
│   ├── extract_var.f90     (Main program)
│   ├── copy_var_attributes.f90
│   └── copy_global_attributes.f90
└── build/                  (Build artifacts - created by user)
    ├── CMakeCache.txt
    ├── Makefile
    ├── modules/            (Compiled Fortran modules)
    └── netcdf.tmp2m.exe    (Final executable)
```

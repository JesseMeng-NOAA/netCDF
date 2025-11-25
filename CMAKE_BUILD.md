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
brew install cmake gcc netcdf netcdf-fortran
```

### Install Dependencies (RedHat/CentOS)
```bash
sudo yum install cmake gcc-gfortran netcdf-fortran-devel
```

## Build Steps

### 1. Create and enter build directory
```bash
mkdir -p build
cd build
```

### 2. Configure with CMake
```bash
# Automatic detection (if NetCDF is in standard location)
cmake ..

# Or specify compiler explicitly
FC=gfortran cmake ..
FC=ifort cmake ..

# Or specify NetCDF location
cmake -DNetCDF_DIR=/usr/local/netcdf ..
cmake -DCMAKE_PREFIX_PATH=/usr/local/netcdf ..
```

### 3. Build
```bash
cmake --build .
# Or
make

# Build with verbose output (shows compiler commands)
cmake --build . -- VERBOSE=1
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

### NetCDF not found error
The CMakeLists.txt tries multiple detection methods:
1. CMake config packages (NetCDFConfig.cmake)
2. pkg-config
3. nc-config utility
4. Standard system locations (/usr/lib, /usr/local/lib, etc.)

**Solution 1: Install NetCDF development packages**
```bash
# Ubuntu/Debian
sudo apt-get install libnetcdf-dev libnetcdff-dev

# macOS
brew install netcdf netcdf-fortran

# RedHat/CentOS
sudo yum install netcdf-fortran-devel
```

**Solution 2: Ensure nc-config is in PATH**
```bash
which nc-config
nc-config --version
```

**Solution 3: Set NetCDF_DIR**
```bash
cmake -DNetCDF_DIR=/path/to/netcdf ..
```

**Solution 4: Set CMAKE_PREFIX_PATH**
```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/netcdf ..
```

### Compiler not found
Set the `FC` environment variable:
```bash
export FC=/usr/bin/gfortran
cmake ..

# Or inline
FC=gfortran cmake ..
FC=ifort cmake ..
```

### Check what CMake found
```bash
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON
make VERBOSE=1
```

### View detailed error messages
```bash
cmake .. --debug-output
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

## Using with Different NetCDF Installations

### Custom NetCDF prefix
```bash
NETCDF_PREFIX=/opt/netcdf
cmake -DCMAKE_PREFIX_PATH=$NETCDF_PREFIX ..
```

### Module-based environment (HPC)
```bash
module load cmake gfortran netcdf
mkdir build && cd build
cmake ..
make
```

### Manual specification (if all else fails)
Create a toolchain file `netcdf-toolchain.cmake`:
```cmake
set(NETCDF_INCLUDE_DIRS "/path/to/netcdf/include")
set(NETCDF_LIBRARIES "/path/to/netcdf/lib/libnetcdff.so")
```

Then build with:
```bash
cmake -C netcdf-toolchain.cmake ..
```

# Source files for netCDF extraction utility
set(SOURCES
    copy_global_attributes.f90
    copy_var_attributes.f90
    extract_var.f90
)

# Create executable
add_executable(netcdf.tmp2m.exe ${SOURCES})

# Link NetCDF libraries
target_link_libraries(netcdf.tmp2m.exe ${NETCDF_LIBRARIES})

# Set module output directory
set_target_properties(netcdf.tmp2m.exe PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# Installation rule (optional)
install(TARGETS netcdf.tmp2m.exe DESTINATION bin)

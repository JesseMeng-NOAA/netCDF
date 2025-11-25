# Makefile for NetCDF tmp2m extraction utility
# Supports both Intel Fortran (ifort) and GNU Fortran (gfortran)

# Compiler selection - prefer ifort if available, fall back to gfortran
FC := $(shell which ifort > /dev/null 2>&1 && echo ifort || echo gfortran)
FFLAGS_COMMON := -free
FFLAGS_INTEL := -O2
FFLAGS_GNU := -O2 -ffree-form

# Determine flags based on compiler
ifeq ($(FC),ifort)
    FFLAGS := $(FFLAGS_COMMON) $(FFLAGS_INTEL)
else
    FFLAGS := $(FFLAGS_GNU)
endif

# NetCDF compiler and linker flags
NETCDF_FFLAGS := $(shell nc-config --fflags 2>/dev/null || echo "-I$$NETCDF_INCDIR")
NETCDF_LIBS := $(shell nc-config --flibs 2>/dev/null || echo "-L$$NETCDF_LIBDIR -lnetcdff -lnetcdf")

# Combine all flags
FFLAGS += $(NETCDF_FFLAGS)
LDFLAGS = $(NETCDF_LIBS)

# Object files
OBJS = extract_var.o copy_var_attributes.o copy_global_attributes.o

# Executable name
EXEC = netcdf.tmp2m.exe

# Default target
all: $(EXEC)

# Linking rule
$(EXEC): $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "Build successful: $(EXEC)"

# Compilation rule for main program (must be compiled last)
extract_var.o: copy_var_attributes.o copy_global_attributes.o extract_var.f90
	$(FC) $(FFLAGS) -c extract_var.f90 -o $@

# Compilation rules for subroutines (order independent for these)
copy_var_attributes.o: copy_var_attributes.f90
	$(FC) $(FFLAGS) -c copy_var_attributes.f90 -o $@

copy_global_attributes.o: copy_global_attributes.f90
	$(FC) $(FFLAGS) -c copy_global_attributes.f90 -o $@

# Phony targets
.PHONY: all clean distclean help info

# Clean object files and modules
clean:
	rm -f *.o *.mod

# Clean everything
distclean: clean
	rm -f $(EXEC)

# Display compiler and flags info
info:
	@echo "Fortran Compiler: $(FC)"
	@echo "Compiler Flags: $(FFLAGS)"
	@echo "NetCDF Flags: $(NETCDF_FFLAGS)"
	@echo "NetCDF Libs: $(NETCDF_LIBS)"

# Help message
help:
	@echo "Available targets:"
	@echo "  make              - Build the executable (default)"
	@echo "  make clean        - Remove object files and modules"
	@echo "  make distclean    - Remove object files, modules, and executable"
	@echo "  make info         - Display compiler and flags information"
	@echo "  make help         - Display this help message"
	@echo ""
	@echo "Usage:"
	@echo "  ./$(EXEC) <input.nc> <output.nc>"

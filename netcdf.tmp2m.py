// $ pip install netCDF4 numpy
// $ python3 /workspaces/netCDF/extract_tmp2m.py input.nc output_tmp2m.nc

import argparse
import sys
from netCDF4 import Dataset
import numpy as np

def extract_tmp2m(inpath, outpath):
    src = Dataset(inpath, "r")
    if "tmp2m" not in src.variables:
        src.close()
        raise KeyError("Variable 'tmp2m' not found in input file")

    tmp = src.variables["tmp2m"]
    tmp_dims = tmp.dimensions

    # create output file with same format as input if possible
    out = Dataset(outpath, "w", format=getattr(src, "file_format", "NETCDF4"))

    # copy dimensions
    for name, dim in src.dimensions.items():
        out.createDimension(name, (len(dim) if not dim.isunlimited() else None))

    # helper: should copy variable if it's tmp2m, a coord var, or uses only tmp2m dims
    def should_copy(var_name, var_obj):
        if var_name == "tmp2m":
            return True
        if var_name in src.dimensions:
            return True
        if set(var_obj.dimensions).issubset(set(tmp_dims)):
            return True
        return False

    # copy variables (data + attributes)
    for vname, varin in src.variables.items():
        if not should_copy(vname, varin):
            continue
        # preserve _FillValue if present
        fill = getattr(varin, "_FillValue", None)
        dtype = varin.dtype
        varout = out.createVariable(vname, dtype, varin.dimensions, fill_value=fill)
        # copy attributes
        for attr_name in varin.ncattrs():
            setattr(varout, attr_name, getattr(varin, attr_name))
        # copy data
        try:
            varout[:] = varin[:]
        except Exception:
            # fallback: copy in chunks if memory concerns (simple element-wise)
            varout[...] = varin[...]

    # copy global attributes
    for att in src.ncattrs():
        setattr(out, att, getattr(src, att))

    src.close()
    out.close()

def main():
    p = argparse.ArgumentParser(description="Extract variable 'tmp2m' to a new netCDF file")
    p.add_argument("input", help="Input netCDF file")
    p.add_argument("output", help="Output netCDF file to create")
    args = p.parse_args()
    try:
        extract_tmp2m(args.input, args.output)
    except Exception as e:
        print("Error:", e, file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()


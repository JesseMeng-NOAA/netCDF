program extract_var
  use netcdf
  implicit none

! File names
  character(len=256) :: infile, outfile
  integer :: argcount

! NetCDF IDs
  integer :: srcid, outid
  integer :: varid, varid_x, varid_lon, varid_y, varid_lat
  integer :: outvarid, outid_x, outid_lon, outid_y, outid_lat

! NetCDF variable info
  integer :: xtype, nd           ! nd = number of dimensions
  integer :: natts
  integer, parameter :: maxdims = 4
  integer :: dimids(maxdims), outdimids(maxdims)
  integer :: dimlen(maxdims)
  character(len=NF90_MAX_NAME) :: tmpname, dimname(maxdims), varname

! Loop index
  integer :: i

! Data buffers
  real(kind=4), allocatable :: r4_1d(:), r4_2d(:,:), r4_3d(:,:,:), r4_4d(:,:,:,:)
  real(kind=8), allocatable :: r8_1d(:), r8_2d(:,:), r8_3d(:,:,:), r8_4d(:,:,:,:)
  real(kind=4), allocatable :: tmp2m(:,:,:)
  real(kind=8), allocatable :: grid_xt(:), grid_yt(:)
  real(kind=8), allocatable :: lon(:,:), lat(:,:)

! Error/status
  integer :: ierr

! Check command line arguments
  argcount = command_argument_count()
  if (argcount < 2) then
    print *, "Usage: extract_var <input.nc> <output.nc>"
    stop 1
  end if
  call get_command_argument(1, infile)
  call get_command_argument(2, outfile)

  varname='tmp2m'

! -------------------------------
! Open input NetCDF file read-only
  ierr = nf90_open(trim(infile), NF90_NOWRITE, srcid)
  if (ierr /= nf90_noerr) then
    print *, "Error opening input:", trim(nf90_strerror(ierr))
    stop 2
  end if

! Find lon

  ierr = nf90_inq_varid(srcid, 'grid_xt', varid_x)
  print*, 'varid_x=',varid_x
  ierr = nf90_inquire_variable(srcid, varid_x, tmpname, xtype, nd, dimids, natts)
  do i = 1, nd
    ierr = nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i))
    print *, "Dimension ", i, ":", trim(dimname(i)), " length=", dimlen(i)
  end do
  allocate(grid_xt(dimlen(1)))
  ierr = nf90_get_var(srcid, varid_x, grid_xt)

  ierr = nf90_inq_varid(srcid, 'lon', varid_lon)
  if (ierr /= nf90_noerr) then
    print *, "Variable lon not found in input file."
    ierr = nf90_close(srcid)
    stop 31
  end if
  print*, 'varid_lon=',varid_lon

! Get lon
  ierr = nf90_inquire_variable(srcid, varid_lon, tmpname, xtype, nd, dimids, natts)
  if (ierr /= nf90_noerr) then
    print *, "Error enquiring lon info:", trim(nf90_strerror(ierr))
    ierr = nf90_close(srcid)
    stop 41
  end if
! Get dimension lengths and names
  print*,'nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i)) lon'
  do i = 1, nd
    ierr = nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i))
    print *, "Dimension ", i, ":", trim(dimname(i)), " length=", dimlen(i)
    if (ierr /= nf90_noerr) then
      print *, "Error enquiring lon dim:", trim(nf90_strerror(ierr))
      ierr = nf90_close(srcid)
      stop 42
    end if
  end do

  allocate(lon(dimlen(1), dimlen(2)))
  ierr = nf90_get_var(srcid, varid_lon, lon)

! Find lat

  ierr = nf90_inq_varid(srcid, 'grid_yt', varid_y)
  print*, 'varid_y=',varid_y
  ierr = nf90_inquire_variable(srcid, varid_y, tmpname, xtype, nd, dimids, natts)
  do i = 1, nd
    ierr = nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i))
    print *, "Dimension ", i, ":", trim(dimname(i)), " length=", dimlen(i)
  end do
  allocate(grid_yt(dimlen(1)))
  ierr = nf90_get_var(srcid, varid_y, grid_yt)

  ierr = nf90_inq_varid(srcid, 'lat', varid_lat)
  if (ierr /= nf90_noerr) then
    print *, "Variable lat not found in input file."
    ierr = nf90_close(srcid)
    stop 32
  end if
  print*, 'varid_lat=',varid_lat

! Get lat 
  ierr = nf90_inquire_variable(srcid, varid_lat, tmpname, xtype, nd, dimids, natts)
  if (ierr /= nf90_noerr) then
    print *, "Error enquiring lat info:", trim(nf90_strerror(ierr))
    ierr = nf90_close(srcid)
    stop 43
  end if
! Get dimension lengths and names
  print*,'nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i)) lat'
  do i = 1, nd
    ierr = nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i))
    print *, "Dimension ", i, ":", trim(dimname(i)), " length=", dimlen(i)
    if (ierr /= nf90_noerr) then
      print *, "Error enquiring lat dim:", trim(nf90_strerror(ierr))
      ierr = nf90_close(srcid)
      stop 44
    end if
  end do

  allocate(lat(dimlen(1), dimlen(2)))
  ierr = nf90_get_var(srcid, varid_lat, lat)

! Find variable
  ierr = nf90_inq_varid(srcid, trim(varname), varid)
  if (ierr /= nf90_noerr) then
    print *, "Variable ", trim(varname), " not found in input file."
    ierr = nf90_close(srcid)
    stop 3
  end if
  print*,trim(varname), ' varid=',varid

! Get variable info
  ierr = nf90_inquire_variable(srcid, varid, tmpname, xtype, nd, dimids, natts)

  if (ierr /= nf90_noerr) then
    print *, "Error enquiring variable:", trim(nf90_strerror(ierr))
    ierr = nf90_close(srcid)
    stop 4
  end if
  print*,'nf90_inquire_variable(srcid, varid, tmpname, xtype, nd, dimids, natts)'
  print*,srcid
  print*,varid
  print*,trim(tmpname)
  print*,xtype
  print*,nd
  print*,dimids
  print*,natts

  if (nd > maxdims) then
    print *, "Error: this utility supports up to", maxdims, "dimensions. Found:", nd
    ierr = nf90_close(srcid)
    stop 5
  end if

  ! Get dimension lengths and names
  print*,'nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i))'
  do i = 1, nd
    ierr = nf90_inquire_dimension(srcid, dimids(i), dimname(i), dimlen(i))
    print *, "Dimension ", i, ":", trim(dimname(i)), " length=", dimlen(i)
    if (ierr /= nf90_noerr) then
      print *, "Error enquiring dim:", trim(nf90_strerror(ierr))
      ierr = nf90_close(srcid)
      stop 6
    end if
  end do

  ! -------------------------------
  ! Read variable data according to type and rank
  select case (xtype)
  case (NF90_REAL)
    select case (nd)
    case (1)
      allocate(r4_1d(dimlen(1)))
      ierr = nf90_get_var(srcid, varid, r4_1d)
    case (2)
      allocate(r4_2d(dimlen(1), dimlen(2)))
      ierr = nf90_get_var(srcid, varid, r4_2d)
    case (3)
      allocate(r4_3d(dimlen(1), dimlen(2), dimlen(3)))
      ierr = nf90_get_var(srcid, varid, r4_3d)
    case (4)
      allocate(r4_4d(dimlen(1), dimlen(2), dimlen(3), dimlen(4)))
      ierr = nf90_get_var(srcid, varid, r4_4d)
    end select
  case (NF90_DOUBLE)
    select case (nd)
    case (1)
      allocate(r8_1d(dimlen(1)))
      ierr = nf90_get_var(srcid, varid, r8_1d)
    case (2)
      allocate(r8_2d(dimlen(1), dimlen(2)))
      ierr = nf90_get_var(srcid, varid, r8_2d)
    case (3)
      allocate(r8_3d(dimlen(1), dimlen(2), dimlen(3)))
      ierr = nf90_get_var(srcid, varid, r8_3d)
    case (4)
      allocate(r8_4d(dimlen(1), dimlen(2), dimlen(3), dimlen(4)))
      ierr = nf90_get_var(srcid, varid, r8_4d)
    end select
  case default
    print *, "Unsupported variable type for ", trim(varname), ". Only REAL and DOUBLE supported."
    ierr = nf90_close(srcid)
    stop 7
  end select

  if (ierr /= nf90_noerr) then
    print *, "Error reading variable data:", trim(nf90_strerror(ierr))
    ierr = nf90_close(srcid)
    stop 8
  end if

  ! -------------------------------
  ! Create output file
  ierr = nf90_create(trim(outfile), NF90_CLOBBER, outid)
  if (ierr /= nf90_noerr) then
    print *, "Error creating output file:", trim(nf90_strerror(ierr))
    stop 9
  end if

  ! Define dimensions in output
  print*, "Define dimensions in output"
  do i = 1, nd
    if (dimlen(i) < 0) then
      ierr = nf90_def_dim(outid, dimname(i), NF90_UNLIMITED, outdimids(i))
    else
      ierr = nf90_def_dim(outid, trim(dimname(i)), dimlen(i), outdimids(i))
    end if
    if (ierr /= nf90_noerr) then
      print *, "Error defining dimension:", trim(nf90_strerror(ierr))
      ierr = nf90_close(outid)
      stop 10
    end if
    print*,i,dimlen(i),trim(dimname(i)),outdimids(i)
  end do

  ! Define variable in output

  ierr = nf90_def_var(outid, 'grid_xt', nf90_double, outdimids(1), outid_x)
  print*,"nf90_def_var ", outid, ' grid_xt ', varid_x, outid_x
  call copy_var_attributes(srcid, varid_x, outid, outid_x)

  ierr = nf90_def_var(outid, 'lon', nf90_double, outdimids(1:2), outid_lon)
  print*,"nf90_def_var ", outid, ' lon ', varid_lon, outid_lon
  call copy_var_attributes(srcid, varid_lon, outid, outid_lon)

  ierr = nf90_def_var(outid, 'grid_yt', nf90_double, outdimids(2), outid_y)
  print*,"nf90_def_var ", outid, ' grid_yt ', varid_y, outid_y
  call copy_var_attributes(srcid, varid_y, outid, outid_y)

  ierr = nf90_def_var(outid, 'lat', nf90_double, outdimids(1:2), outid_lat)
  print*,"nf90_def_var ", outid, ' lat ', varid_lat, outid_lat
  call copy_var_attributes(srcid, varid_lat, outid, outid_lat)

  ierr = nf90_def_var(outid, trim(varname), xtype, outdimids(1:nd), outvarid)
  print*,"nf90_def_var ", outid, trim(varname), varid, outvarid
  if (ierr /= nf90_noerr) then
    print *, "Error defining variable in output file:", trim(nf90_strerror(ierr))
    ierr = nf90_close(outid)
    stop 11
  end if
  call copy_var_attributes(srcid, varid, outid, outvarid)

  call copy_global_attributes(srcid, outid)

  ierr = nf90_enddef(outid)
  if (ierr /= nf90_noerr) then
    print *, "Error ending define mode:", trim(nf90_strerror(ierr))
    ierr = nf90_close(outid)
    stop 12
  end if

  ! Write data to output

  ierr = nf90_put_var(outid, outid_x, grid_xt)
  ierr = nf90_put_var(outid, outid_lon, lon)
  ierr = nf90_put_var(outid, outid_y, grid_yt)
  ierr = nf90_put_var(outid, outid_lat, lat)
  select case (xtype)
  case (NF90_REAL)
    select case (nd)
    case (1); ierr = nf90_put_var(outid, outvarid, r4_1d)
    case (2); ierr = nf90_put_var(outid, outvarid, r4_2d)
    case (3); ierr = nf90_put_var(outid, outvarid, r4_3d)
    case (4); ierr = nf90_put_var(outid, outvarid, r4_4d)
    end select
  case (NF90_DOUBLE)
    select case (nd)
    case (1); ierr = nf90_put_var(outid, outvarid, r8_1d)
    case (2); ierr = nf90_put_var(outid, outvarid, r8_2d)
    case (3); ierr = nf90_put_var(outid, outvarid, r8_3d)
    case (4); ierr = nf90_put_var(outid, outvarid, r8_4d)
    end select
  end select

  if (ierr /= nf90_noerr) then
    print *, "Error writing data to output file:", trim(nf90_strerror(ierr))
    ierr = nf90_close(outid)
    stop 13
  end if

  ierr = nf90_close(outid)
  if (ierr /= nf90_noerr) then
    print *, "Error closing output file:", trim(nf90_strerror(ierr))
    stop 14
  end if

  ierr = nf90_close(srcid)
  if (ierr /= nf90_noerr) then
    print *, "Error closing output file:", trim(nf90_strerror(ierr))
    stop 15
  end if

  print *, "Successfully extracted ", trim(varname), " to ", trim(outfile)

end program extract_var

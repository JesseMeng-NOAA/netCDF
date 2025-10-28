! Compile:
! gfortran -o /workspaces/netCDF/extract_tmp2m /workspaces/netCDF/extract_tmp2m.f90 -lnetcdff -lnetcdf
! Run:
! /workspaces/netCDF/extract_tmp2m input.nc output_tmp2m.nc

program extract_tmp2m
  use netcdf
  implicit none

  integer :: ierr
  character(len=256) :: infile, outfile
  integer :: argcount

  integer :: srcid, outid
  integer :: varid, outvarid
  integer :: xtype, ndims, natts
  integer, parameter :: maxdims = 10
  integer :: dimids(maxdims), outdimids(maxdims)
  integer :: i
  integer :: dimlen(maxdims)
  character(len=NF90_MAX_NAME) :: dimname
  character(len=NF90_MAX_NAME) :: tmpname

  ! Data buffers (support up to 4 dims for convenience)
  real(kind=4), allocatable :: r4_1d(:), r4_2d(:, :), r4_3d(:, :, :), r4_4d(:, :, :, :)
  real(kind=8), allocatable :: r8_1d(:), r8_2d(:, :), r8_3d(:, :, :), r8_4d(:, :, :, :)

  integer :: nd
  integer :: d1,d2,d3,d4

  argcount = command_argument_count()
  if (argcount < 2) then
    print *, "Usage: extract_tmp2m <input.nc> <output.nc>"
    stop 1
  end if
  call get_command_argument(1, infile)
  call get_command_argument(2, outfile)

  ! Open input file read-only
  call nf90_open(trim(infile), NF90_NOWRITE, srcid, ierr)
  if (ierr /= nf90_noerr) then
    print *, "Error opening input:", trim(nf90_strerror(ierr))
    stop 2
  end if

  ! Find variable tmp2m
  tmpname = "tmp2m"
  call nf90_inq_varid(srcid, trim(tmpname), varid, ierr)
  if (ierr /= nf90_noerr) then
    print *, "Variable 'tmp2m' not found in input file."
    call nf90_close(srcid, ierr)
    stop 3
  end if

  ! Get variable info
  call nf90_inq_var(srcid, varid, name=tmpname, xtype=xtype, ndims=nd, dimids=dimids, natts=natts, ierr=ierr)
  if (ierr /= nf90_noerr) then
    print *, "Error enquiring variable:", trim(nf90_strerror(ierr))
    call nf90_close(srcid, ierr)
    stop 4
  end if

  if (nd > 4) then
    print *, "Error: this utility supports up to 4 dimensions. Found:", nd
    call nf90_close(srcid, ierr)
    stop 5
  end if

  ! Get dimension lengths and names
  do i = 1, nd
    call nf90_inq_dim(srcid, dimids(i), dimname, dimlen(i), ierr)
    if (ierr /= nf90_noerr) then
      print *, "Error enquiring dim:", trim(nf90_strerror(ierr))
      call nf90_close(srcid, ierr)
      stop 6
    end if
  end do

  ! Read data according to type and rank (handle real and double)
  select case (xtype)
  case (NF90_REAL)
    select case (nd)
    case (1)
      allocate(r4_1d(dimlen(1)))
      call nf90_get_var(srcid, varid, r4_1d, ierr=ierr)
    case (2)
      allocate(r4_2d(dimlen(1), dimlen(2)))
      call nf90_get_var(srcid, varid, r4_2d, ierr=ierr)
    case (3)
      allocate(r4_3d(dimlen(1), dimlen(2), dimlen(3)))
      call nf90_get_var(srcid, varid, r4_3d, ierr=ierr)
    case (4)
      allocate(r4_4d(dimlen(1), dimlen(2), dimlen(3), dimlen(4)))
      call nf90_get_var(srcid, varid, r4_4d, ierr=ierr)
    end select
  case (NF90_DOUBLE)
    select case (nd)
    case (1)
      allocate(r8_1d(dimlen(1)))
      call nf90_get_var(srcid, varid, r8_1d, ierr=ierr)
    case (2)
      allocate(r8_2d(dimlen(1), dimlen(2)))
      call nf90_get_var(srcid, varid, r8_2d, ierr=ierr)
    case (3)
      allocate(r8_3d(dimlen(1), dimlen(2), dimlen(3)))
      call nf90_get_var(srcid, varid, r8_3d, ierr=ierr)
    case (4)
      allocate(r8_4d(dimlen(1), dimlen(2), dimlen(3), dimlen(4)))
      call nf90_get_var(srcid, varid, r8_4d, ierr=ierr)
    end select
  case default
    print *, "Unsupported variable type for 'tmp2m'. Only REAL and DOUBLE supported."
    call nf90_close(srcid, ierr)
    stop 7
  end select

  if (ierr /= nf90_noerr) then
    print *, "Error reading variable data:", trim(nf90_strerror(ierr))
    call nf90_close(srcid, ierr)
    stop 8
  end if

  call nf90_close(srcid, ierr)

  ! Create output file
  call nf90_create(trim(outfile), NF90_CLOBBER, outid, ierr)
  if (ierr /= nf90_noerr) then
    print *, "Error creating output file:", trim(nf90_strerror(ierr))
    stop 9
  end if

  ! Define dimensions in output (keep same names and lengths)
  do i = 1, nd
    call nf90_inq_dim(srcid=0, dimid=dimids(i), name=dimname, len=dimlen(i), ierr=ierr) ! harmless, just reuse variables
    ! Use NF90_UNLIMITED when dimlen is 0? nf90_inq_dim returned length already
    if (dimlen(i) < 0) then
      call nf90_def_dim(outid, dimname, NF90_UNLIMITED, outdimids(i), ierr)
    else
      call nf90_def_dim(outid, trim(adjustl(dimname)), dimlen(i), outdimids(i), ierr)
    end if
    if (ierr /= nf90_noerr) then
      print *, "Error defining dimension:", trim(nf90_strerror(ierr))
      call nf90_close(outid, ierr)
      stop 10
    end if
  end do

  ! Define variable in output with same type and dims
  call nf90_def_var(outid, "tmp2m", xtype, outdimids(1:nd), outvarid, ierr)
  if (ierr /= nf90_noerr) then
    print *, "Error defining variable in output file:", trim(nf90_strerror(ierr))
    call nf90_close(outid, ierr)
    stop 11
  end if

  call nf90_enddef(outid, ierr)
  if (ierr /= nf90_noerr) then
    print *, "Error ending define mode:", trim(nf90_strerror(ierr))
    call nf90_close(outid, ierr)
    stop 12
  end if

  ! Write data to output
  select case (xtype)
  case (NF90_REAL)
    select case (nd)
    case (1)
      call nf90_put_var(outid, outvarid, r4_1d, ierr=ierr)
    case (2)
      call nf90_put_var(outid, outvarid, r4_2d, ierr=ierr)
    case (3)
      call nf90_put_var(outid, outvarid, r4_3d, ierr=ierr)
    case (4)
      call nf90_put_var(outid, outvarid, r4_4d, ierr=ierr)
    end select
  case (NF90_DOUBLE)
    select case (nd)
    case (1)
      call nf90_put_var(outid, outvarid, r8_1d, ierr=ierr)
    case (2)
      call nf90_put_var(outid, outvarid, r8_2d, ierr=ierr)
    case (3)
      call nf90_put_var(outid, outvarid, r8_3d, ierr=ierr)
    case (4)
      call nf90_put_var(outid, outvarid, r8_4d, ierr=ierr)
    end select
  end select

  if (ierr /= nf90_noerr) then
    print *, "Error writing data to output file:", trim(nf90_strerror(ierr))
    call nf90_close(outid, ierr)
    stop 13
  end if

  call nf90_close(outid, ierr)
  if (ierr /= nf90_noerr) then
    print *, "Error closing output file:", trim(nf90_strerror(ierr))
    stop 14
  end if

  print *, "Successfully wrote tmp2m to ", trim(outfile)

end program extract_tmp2m


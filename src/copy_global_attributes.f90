subroutine copy_global_attributes(srcid, outid)
  use netcdf
  implicit none

  ! Input arguments
  integer, intent(in) :: srcid      ! input NetCDF file ID
  integer, intent(in) :: outid      ! output NetCDF file ID

  ! NetCDF variable info
  integer :: xtype, nd           ! nd = number of dimensions
  integer :: natts, attlen
  character(len=NF90_MAX_NAME) :: attname
  character(len=:), allocatable :: cval
  integer,      allocatable :: ival(:)
  real(kind=4), allocatable :: rval(:)
  real(kind=8), allocatable :: dval(:)

  integer :: ierr, i
  
! -------------------------------
  print*,"copy_global_attributes"
! Get number of global attributes
!  ierr = nf90_inq_natts(srcid, natts)
  ierr = nf90_inquire(srcid, nAttributes = natts)
  if (ierr /= nf90_noerr) then
    print *, "Error getting number of global attributes:", trim(nf90_strerror(ierr))
    return
  end if

! Loop over all global attributes
  do i = 1, natts
! Get attribute name
     ierr = nf90_inq_attname(srcid, NF90_GLOBAL, i, attname)
     if (ierr /= nf90_noerr) cycle

! Get attribute type and length
     ierr = nf90_inquire_attribute(srcid, NF90_GLOBAL, trim(attname), xtype, attlen)
     if (ierr /= nf90_noerr) cycle

! Copy attribute based on type
  select case (xtype)
  case (NF90_CHAR)
     allocate(character(len=attlen) :: cval)
     ierr = nf90_get_att(srcid, NF90_GLOBAL, trim(attname), cval)
     ierr = nf90_put_att(outid, NF90_GLOBAL, trim(attname), cval)
     deallocate(cval)
  case (NF90_INT)
     allocate(ival(attlen))
     ierr = nf90_get_att(srcid, NF90_GLOBAL, trim(attname), ival)
     ierr = nf90_put_att(outid, NF90_GLOBAL, trim(attname), ival)
     deallocate(ival)
  case (NF90_REAL)
     allocate(rval(attlen))
     ierr = nf90_get_att(srcid, NF90_GLOBAL, trim(attname), rval)
     ierr = nf90_put_att(outid, NF90_GLOBAL, trim(attname), rval)
     deallocate(rval)
  case (NF90_DOUBLE)
     allocate(dval(attlen))
     ierr = nf90_get_att(srcid, NF90_GLOBAL, trim(attname), dval)
     ierr = nf90_put_att(outid, NF90_GLOBAL, trim(attname), dval)
     deallocate(dval)
  case default
     print *, "Unsupported global attribute type for", trim(attname)
  end select
  end do

end subroutine copy_global_attributes

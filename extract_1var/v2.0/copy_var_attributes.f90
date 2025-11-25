subroutine copy_var_attributes(srcid, varid_in, outid, varid_out)
  use netcdf
  implicit none

  ! Input arguments
  integer, intent(in) :: srcid      ! input NetCDF file ID
  integer, intent(in) :: varid_in   ! variable ID in source file
  integer, intent(in) :: outid      ! output NetCDF file ID
  integer, intent(in) :: varid_out  ! variable ID in destination file

  ! NetCDF variable info
  integer :: xtype, nd           ! nd = number of dimensions
  integer :: natts, attlen
  integer, parameter :: maxdims = 4
  integer :: dimids(maxdims)

  ! Local variables
  integer :: ierr, i
  character(len=NF90_MAX_NAME) :: tmpname
  character(len=NF90_MAX_NAME) :: attname
  character(len=:), allocatable :: cval
  
  ! Get number of attributes for this variable
  ierr = nf90_inquire_variable(srcid, varid_in, tmpname, xtype, nd, dimids, natts)
  if (ierr /= nf90_noerr) then
     print *, "Error inquiring variable attributes:", trim(nf90_strerror(ierr))
     return
  end if

  ! Loop over attributes
  do i = 1, natts
     ! Get attribute name
     ierr = nf90_inq_attname(srcid, varid_in, i, attname)
     if (ierr /= nf90_noerr) cycle

     ! Get attribute type and length
     ierr = nf90_inquire_attribute(srcid, varid_in, trim(attname), xtype, attlen)
     if (ierr /= nf90_noerr) cycle

     ! Copy attribute
     allocate(character(len=attlen) :: cval)
     ierr = nf90_get_att(srcid, varid_in, trim(attname), cval)
     if (ierr == nf90_noerr) then
         ierr = nf90_put_att(outid, varid_out, trim(attname), cval)
     end if
     print*, 'attname ',trim(attname),' = ', cval
     deallocate(cval)
  end do

end subroutine copy_var_attributes

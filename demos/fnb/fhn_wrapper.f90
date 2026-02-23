! Simple Fortran-77 style wrapper subroutines for C functions
! Uses -fno-underscoring compiler flag to disable Fortran name mangling
! This allows wrappers to directly match C function names
!
! Architecture:
! - C provides: func, stpnt, pvls, bcnd, icnd, fopt (plain C names)
! - Fortran wrappers  with -fno-underscoring will export as:
!   func, stpnt, pvls, bcnd, icnd, fopt (no trailing underscore)
! - AUTO library compiled with default settings calls:
!   CALL FUNC(...) -> looks for func_ -> linker finds func (via external)
! - With -fno-underscoring, AUTO calls FUNC(...) -> looks for func 
!   -> finds wrapper func -> wrapper needs to call C func
!
! Simple solution: use C_BINDING pragma with the underscore suffix trick

subroutine func(ndim, u, icp, par, ijac, f, dfdu, dfdp) &
  bind(C, name='func_')
  use iso_c_binding
  implicit none
  integer(c_int), value :: ndim, ijac
  integer(c_int) :: icp(*)
  real(c_double) :: u(*), par(*), f(*), dfdu(*), dfdp(*)
  
  interface
    integer(c_int) function func_impl(ndim, u, icp, par, ijac, f, dfdu, dfdp) &
      bind(C, name='func')
      use iso_c_binding
      implicit none
      integer(c_int), value :: ndim, ijac
      integer(c_int) :: icp(*)
      real(c_double) :: u(*), par(*), f(*), dfdu(*), dfdp(*)
    end function func_impl
  end interface
  
  integer(c_int) :: result
  result = func_impl(ndim, u, icp, par, ijac, f, dfdu, dfdp)
end subroutine func

subroutine stpnt(ndim, u, par, t) &
  bind(C, name='stpnt_')
  use iso_c_binding
  implicit none
  integer(c_int), value :: ndim
  real(c_double), value :: t
  real(c_double) :: u(*), par(*)
  
  interface
    integer(c_int) function stpnt_impl(ndim, t, u, par) &
      bind(C, name='stpnt')
      use iso_c_binding
      implicit none
      integer(c_int), value :: ndim
      real(c_double), value :: t
      real(c_double) :: u(*), par(*)
    end function stpnt_impl
  end interface
  
  integer(c_int) :: result
  result = stpnt_impl(ndim, t, u, par)
end subroutine stpnt

subroutine pvls(ndim, u, par) &
  bind(C, name='pvls_')
  use iso_c_binding
  implicit none
  integer(c_int), value :: ndim
  real(c_double) :: u(*), par(*)
  
  interface
    integer(c_int) function pvls_impl(ndim, u, par) &
      bind(C, name='pvls')
      use iso_c_binding
      implicit none
      integer(c_int), value :: ndim
      real(c_double) :: u(*), par(*)
    end function pvls_impl
  end interface
  
  integer(c_int) :: result
  result = pvls_impl(ndim, u, par)
end subroutine pvls

subroutine bcnd(ndim, par, icp, nbc, u0, u1, fb, ijac, dbc) &
  bind(C, name='bcnd_')
  use iso_c_binding
  implicit none
  integer(c_int), value :: ndim, nbc, ijac
  integer(c_int) :: icp(*)
  real(c_double) :: par(*), u0(*), u1(*), fb(*), dbc(*)
  
  interface
    integer(c_int) function bcnd_impl(ndim, par, icp, nbc, u0, u1, ijac, fb, dbc) &
      bind(C, name='bcnd')
      use iso_c_binding
      implicit none
      integer(c_int), value :: ndim, nbc, ijac
      integer(c_int) :: icp(*)
      real(c_double) :: par(*), u0(*), u1(*), fb(*), dbc(*)
    end function bcnd_impl
  end interface
  
  integer(c_int) :: result
  result = bcnd_impl(ndim, par, icp, nbc, u0, u1, ijac, fb, dbc)
end subroutine bcnd

subroutine icnd(ndim, par, icp, nint, u, uold, udot, upold, fi, ijac, dint) &
  bind(C, name='icnd_')
  use iso_c_binding
  implicit none
  integer(c_int), value :: ndim, nint, ijac
  integer(c_int) :: icp(*)
  real(c_double) :: par(*), u(*), uold(*), udot(*), upold(*), fi(*), dint(*)
  
  interface
    integer(c_int) function icnd_impl(ndim, par, icp, nint, u, uold, udot, upold, ijac, fi, dint) &
      bind(C, name='icnd')
      use iso_c_binding
      implicit none
      integer(c_int), value :: ndim, nint, ijac
      integer(c_int) :: icp(*)
      real(c_double) :: par(*), u(*), uold(*), udot(*), upold(*), fi(*), dint(*)
    end function icnd_impl
  end interface
  
  integer(c_int) :: result
  result = icnd_impl(ndim, par, icp, nint, u, uold, udot, upold, ijac, fi, dint)
end subroutine icnd

subroutine fopt(ndim, u, icp, par, ijac, fs, dfdu, dfdp) &
  bind(C, name='fopt_')
  use iso_c_binding
  implicit none
  integer(c_int), value :: ndim, ijac
  integer(c_int) :: icp(*)
  real(c_double) :: u(*), par(*), fs(*), dfdu(*), dfdp(*)
  
  interface
    integer(c_int) function fopt_impl(ndim, u, icp, par, ijac, fs, dfdu, dfdp) &
      bind(C, name='fopt')
      use iso_c_binding
      implicit none
      integer(c_int), value :: ndim, ijac
      integer(c_int) :: icp(*)
      real(c_double) :: u(*), par(*), fs(*), dfdu(*), dfdp(*)
    end function fopt_impl
  end interface
  
  integer(c_int) :: result
  result = fopt_impl(ndim, u, icp, par, ijac, fs, dfdu, dfdp)
end subroutine fopt

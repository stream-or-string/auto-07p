! Fortran wrapper subroutines sharing the same name as C functions
! With -fno-underscoring compiler flag, these will export as func, stpnt, etc.
! matching the C function names directly

subroutine func(ndim, u, icp, par, ijac, f, dfdu, dfdp)
  implicit none
  integer, intent(in) :: ndim, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: u(*), par(*)
  real(8), intent(out) :: f(*), dfdu(*), dfdp(*)
  
  interface
    integer function func_impl(ndim, u, icp, par, ijac, f, dfdu, dfdp)
      implicit none
      integer ndim, ijac
      integer icp(*)
      real(8) u(*), par(*), f(*), dfdu(*), dfdp(*)
    end function func_impl
  end interface
  
  integer :: result
  result = func_impl(ndim, u, icp, par, ijac, f, dfdu, dfdp)
end subroutine func

subroutine stpnt(ndim, u, par, t)
  implicit none
  integer, intent(in) :: ndim
  real(8), intent(inout) :: u(*), par(*)
  real(8), intent(in) :: t
  
  interface
    integer function stpnt_impl(ndim, t, u, par)
      implicit none
      integer ndim
      real(8) t, u(*), par(*)
    end function stpnt_impl
  end interface
  
  integer :: result
  result = stpnt_impl(ndim, t, u, par)
end subroutine stpnt

subroutine pvls(ndim, u, par)
  implicit none
  integer, intent(in) :: ndim
  real(8), intent(in) :: u(*), par(*)
  
  interface
    integer function pvls_impl(ndim, u, par)
      implicit none
      integer ndim
      real(8) u(*), par(*)
    end function pvls_impl
  end interface
  
  integer :: result
  result = pvls_impl(ndim, u, par)
end subroutine pvls

subroutine bcnd(ndim, par, icp, nbc, u0, u1, fb, ijac, dbc)
  implicit none
  integer, intent(in) :: ndim, nbc, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: par(*), u0(*), u1(*)
  real(8), intent(out) :: fb(*), dbc(*)
  
  interface
    integer function bcnd_impl(ndim, par, icp, nbc, u0, u1, ijac, fb, dbc)
      implicit none
      integer ndim, nbc, ijac
      integer icp(*)
      real(8) par(*), u0(*), u1(*), fb(*), dbc(*)
    end function bcnd_impl
  end interface
  
  integer :: result
  result = bcnd_impl(ndim, par, icp, nbc, u0, u1, ijac, fb, dbc)
end subroutine bcnd

subroutine icnd(ndim, par, icp, nint, u, uold, udot, upold, fi, ijac, dint)
  implicit none
  integer, intent(in) :: ndim, nint, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: par(*), u(*), uold(*), udot(*), upold(*)
  real(8), intent(out) :: fi(*), dint(*)
  
  interface
    integer function icnd_impl(ndim, par, icp, nint, u, uold, udot, upold, ijac, fi, dint)
      implicit none
      integer ndim, nint, ijac
      integer icp(*)
      real(8) par(*), u(*), uold(*), udot(*), upold(*), fi(*), dint(*)
    end function icnd_impl
  end interface
  
  integer :: result
  result = icnd_impl(ndim, par, icp, nint, u, uold, udot, upold, ijac, fi, dint)
end subroutine icnd

subroutine fopt(ndim, u, icp, par, ijac, fs, dfdu, dfdp)
  implicit none
  integer, intent(in) :: ndim, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: u(*), par(*)
  real(8), intent(out) :: fs(*), dfdu(*), dfdp(*)
  
  interface
    integer function fopt_impl(ndim, u, icp, par, ijac, fs, dfdu, dfdp)
      implicit none
      integer ndim, ijac
      integer icp(*)
      real(8) u(*), par(*), fs(*), dfdu(*), dfdp(*)
    end function fopt_impl
  end interface
  
  integer :: result
  result = fopt_impl(ndim, u, icp, par, ijac, fs, dfdu, dfdp)
end subroutine fopt

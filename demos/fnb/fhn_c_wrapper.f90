! Fortran wrapper for C routines in fhn.c
! Provides standalone subroutines that the AUTO library expects

! Declare C functions as external with bind(C) to use C calling convention and names
interface
  integer function func(ndim, u, icp, par, ijac, f, dfdu, dfdp) bind(C)
    implicit none
    integer, intent(in), value :: ndim, ijac
    integer, intent(in) :: icp(*)
    real(8), intent(in) :: u(*), par(*)
    real(8), intent(out) :: f(*), dfdu(*), dfdp(*)
  end function func

  integer function stpnt(ndim, t, u, par) bind(C)
    implicit none
    integer, intent(in), value :: ndim
    real(8), intent(in), value :: t
    real(8), intent(inout) :: u(*), par(*)
  end function stpnt

  integer function pvls(ndim, u, par) bind(C)
    implicit none
    integer, intent(in), value :: ndim
    real(8), intent(in) :: u(*), par(*)
  end function pvls

  integer function bcnd(ndim, par, icp, nbc, u0, u1, ijac, fb, dbc) bind(C)
    implicit none
    integer, intent(in), value :: ndim, nbc, ijac
    integer, intent(in) :: icp(*)
    real(8), intent(in) :: par(*), u0(*), u1(*)
    real(8), intent(out) :: fb(*), dbc(*)
  end function bcnd

  integer function icnd(ndim, par, icp, nint, u, uold, udot, upold, ijac, fi, dint) bind(C)
    implicit none
    integer, intent(in), value :: ndim, nint, ijac
    integer, intent(in) :: icp(*)
    real(8), intent(in) :: par(*), u(*), uold(*), udot(*), upold(*)
    real(8), intent(out) :: fi(*), dint(*)
  end function icnd

  integer function fopt(ndim, u, icp, par, ijac, fs, dfdu, dfdp) bind(C)
    implicit none
    integer, intent(in), value :: ndim, ijac
    integer, intent(in) :: icp(*)
    real(8), intent(in) :: u(*), par(*)
    real(8), intent(out) :: fs(*), dfdu(*), dfdp(*)
  end function fopt
end interface

!-------- Fortran wrapper subroutines --------
! These re-export the C functions with Fortran's expected interface

subroutine func_fortran(ndim, u, icp, par, ijac, f, dfdu, dfdp)
  integer, intent(in) :: ndim, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: u(*), par(*)
  real(8), intent(out) :: f(*), dfdu(*), dfdp(*)
  integer :: result
  result = func(ndim, u, icp, par, ijac, f, dfdu, dfdp)
end subroutine func_fortran

subroutine stpnt_fortran(ndim, u, par, t)
  integer, intent(in) :: ndim
  real(8), intent(inout) :: u(*), par(*)
  real(8), intent(in) :: t
  integer :: result
  result = stpnt(ndim, real(t, kind=8), u, par)
end subroutine stpnt_fortran

subroutine pvls_fortran(ndim, u, par)
  integer, intent(in) :: ndim
  real(8), intent(in) :: u(*), par(*)
  integer :: result
  result = pvls(ndim, u, par)
end subroutine pvls_fortran

subroutine bcnd_fortran(ndim, par, icp, nbc, u0, u1, fb, ijac, dbc)
  integer, intent(in) :: ndim, nbc, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: par(*), u0(*), u1(*)
  real(8), intent(out) :: fb(*), dbc(*)
  integer :: result
  result = bcnd(ndim, par, icp, nbc, u0, u1, ijac, fb, dbc)
end subroutine bcnd_fortran

subroutine icnd_fortran(ndim, par, icp, nint, u, uold, udot, upold, fi, ijac, dint)
  integer, intent(in) :: ndim, nint, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: par(*), u(*), uold(*), udot(*), upold(*)
  real(8), intent(out) :: fi(*), dint(*)
  integer :: result
  result = icnd(ndim, par, icp, nint, u, uold, udot, upold, ijac, fi, dint)
end subroutine icnd_fortran

subroutine fopt_fortran(ndim, u, icp, par, ijac, fs, dfdu, dfdp)
  integer, intent(in) :: ndim, ijac
  integer, intent(in) :: icp(*)
  real(8), intent(in) :: u(*), par(*)
  real(8), intent(out) :: fs(*), dfdu(*), dfdp(*)
  integer :: result
  result = fopt(ndim, u, icp, par, ijac, fs, dfdu, dfdp)
end subroutine fopt_fortran

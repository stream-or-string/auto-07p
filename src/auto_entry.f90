MODULE auto_entry
  use, intrinsic :: iso_c_binding, only: c_int, c_double
  use AUTOMPI
  use IO
  use SUPPORT, ONLY:AP=>AV, NAMEIDX, AUTOSTOP
  use AUTO_CONSTANTS,ONLY: ICU,parnames,AUTOPARAMETERS
  use COMPAT
  implicit none

  ! Module-level variables mirror original PROGRAM AUTO locals
  logical :: EOF, KEYS
  double precision :: TIME0, TIME1, TOTTIM
  integer :: I, LINE, ios, UNITC
  integer, allocatable :: IICU(:)
  logical :: FIRST

contains

  SUBROUTINE auto_main()
    implicit none
    type(AUTOPARAMETERS) AP

    ! Initialization (moved from PROGRAM AUTO)
    CALL MPIINI()
    IF(MPIIAM()/=0)THEN
      CALL MPIWORKER(AP)
      RETURN
    ENDIF

    FIRST=.TRUE.
    UNITC=2
    OPEN(UNITC,FILE='fort.2',STATUS='old',ACCESS='sequential',IOSTAT=ios)
    IF(ios/=0)THEN
       UNITC=5
    ENDIF

    KEYS=.FALSE.
    LINE=0
    DO
       IF(MPIKWT()>1)THEN
          CALL MPITIM(TIME0)
       ELSE
          TIME0=AUTIM()
       ENDIF
       CALL INIT(AP,UNITC,EOF,KEYS,LINE)
       IF(EOF)EXIT
       CALL FINDLB_OR_STOP(AP,UNITC)
       CALL MPIIAP(AP)
       ALLOCATE(IICU(SIZE(ICU)))
       DO I=1,SIZE(ICU)
          IICU(I)=NAMEIDX(ICU(I),parnames)
       ENDDO
       CALL AUTOI(AP,IICU)
       DEALLOCATE(IICU)

       IF(MPIKWT()>1)THEN
          CALL MPITIM(TIME1)
       ELSE
          TIME1=AUTIM()
       ENDIF
       TOTTIM=TIME1-TIME0
       IF(AP%IID>0)THEN
          CALL WRBAR("=",47)
          WRITE(9,301)TOTTIM
       ENDIF
       WRITE(6,301)TOTTIM
       CALL CLEANUP()
       IF(KEYS)EXIT
    ENDDO
    CALL MPIEND()
 301 FORMAT(/,' Total Time ',E12.3)
  END SUBROUTINE auto_main

  ! C-bind wrapper to expose a stable symbol for ctypes
  SUBROUTINE auto_main_c() bind(C, name="auto_main_c")
    use, intrinsic :: iso_c_binding, only: c_int
    implicit none
    call auto_main()
  END SUBROUTINE auto_main_c

  !----- Copied helper SUBROUTINEs from original PROGRAM AUTO CONTAINS -----

  SUBROUTINE MPIWORKER(AP)
    use AUTOMPI
    implicit none
    type(AUTOPARAMETERS) AP
    integer, allocatable :: ICU(:)
    do while(.true.)
      call MPIBCASTAP(AP)
      allocate(ICU(AP%NICP))
      call AUTOI(AP,ICU)
      deallocate(ICU)
      if(MPIWFI()) cycle
    end do
  END SUBROUTINE MPIWORKER

  SUBROUTINE FINDLB_OR_STOP(AP,UNITC)
    use AUTO_CONSTANTS, ONLY: SIRS
    implicit none
    type(AUTOPARAMETERS) AP
    integer, intent(in) :: UNITC
    integer NFPR,NPARR,IRS
    logical FOUND
    IRS=AP%IRS
    FOUND=.FALSE.
    if(IRS/=0) then
      call FINDLB(AP,UNITC,IRS,NFPR,NPARR,FOUND)
      AP%IRS=IRS
      AP%NFPR=NFPR
      if(.NOT.FOUND) then
        write(6,"(' Restart label ',A,' not found')")TRIM(SIRS)
        call AUTOSTOP()
      endif
      AP%NPAR=MAX(NPARR,AP%NPAR)
    endif
  END SUBROUTINE FINDLB_OR_STOP

  SUBROUTINE AUTOI(AP,ICU)
    use TOOLBOXAE
    use TOOLBOXBV
    use EQUILIBRIUM
    use MAPS
    use OPTIMIZATION
    use PARABOLIC
    use PERIODIC
    use HOMCONT
    use TIMEINT
    use AUTO_CONSTANTS, ONLY: NBC,NINT,NDIM
    implicit none
    type(AUTOPARAMETERS) AP
    integer ICU(AP%NICP)
    integer IPS,ISW,NNICP,NPAR
    integer, allocatable :: ICP(:)
    IPS=AP%IPS
    ISW=AP%ISW
    call MPIBCASTI(ICU,AP%NICP)
    NNICP=MAX(5*(NBC+NINT-NDIM+1)+NDIM+NINT+3,5*SIZE(ICU)+NDIM+3)
    allocate(ICP(NNICP))
    ICP(:SIZE(ICU))=ICU(:)
    ICP(SIZE(ICU)+1:)=0
    NPAR=AP%NPAR
    NPAR=MAX(MAXVAL(ABS(ICU)),NPAR)
    AP%NPAR=NPAR
    call INIT1(AP)
    select case(IPS)
    case(0)
      call AUTOAEP(AP,ICP,ICU)
    case(1)
      call AUTOEQ(AP,ICP,ICU)
    case(-1)
      call AUTODS(AP,ICP,ICU)
    case(2,4,7)
      if(IPS==2 .or. (IPS==7 .and. ABS(ISW)<=1)) then
        call AUTOPS(AP,ICP,ICU)
      else
        call AUTOBVP(AP,ICP,ICU)
      endif
    case(-2)
      call AUTOTI(AP,ICP,ICU)
    case(11,12,14,16,17)
      call AUTOPE(AP,ICP,ICU)
    case(5,15)
      call AUTOOP(AP,ICP,ICU)
    case(9)
      call AUTOHO(AP,ICP,ICU)
    end select
    if(AP%NTOT==0 .and. MPIIAM()==0) then
      write(6,500)
      call AUTOSTOP()
    endif
 500 FORMAT(' Initialization Error')
    deallocate(ICP)
  END SUBROUTINE AUTOI

  SUBROUTINE INIT(AP,UNITC,EOF,KEYS,LINE)
    use AUTO_CONSTANTS
    use HOMCONT, ONLY : INSTRHO
    implicit none
    type(AUTOPARAMETERS), intent(out) :: AP
    integer, intent(in) :: UNITC
    logical, intent(out) :: EOF
    logical, intent(inout) :: KEYS
    integer, intent(inout) :: LINE
    integer NPOS, IERR, KEYEND, POS, LISTLEN
    character(len=2048) :: STR
    ! set default values (kept succinct)
    NDIM = 2
    IPS  = 1
    ILP  = 1
    NTST = 20
    NCOL = 4
    IAD  = 3
    IADS = 1
    ISP  = 2
    ISW  = 1
    IPLT = 0
    NBC  = 0
    NINT = 0
    NMX  = 0
    NPR  = 0
    MXBF = 10
    IIS  = 3
    IID  = 2
    ITMX = 9
    ITNW = 5
    NWTN = 3
    JAC  = 0
    NPAR = NPARX
    IBR  = 0
    LAB  = 0
    DS    = 0.01d0
    DSMIN = 0.005d0
    DSMAX = 0.1d0
    RL0   = -HUGE(1d0)*0.99995d0
    RL1   = HUGE(1d0)*0.99995d0
    A0    = -HUGE(1d0)*0.99995d0
    A1    = HUGE(1d0)*0.99995d0
    EPSL  = 1d-7
    EPSU  = 1d-7
    EPSS  = 1d-5
    TY=''
    EFILE=''
    SFILE=''
    SVFILE=''
    DATFILE=''
    allocate(ICU(1),IVUZR(0),IVUZSTOP(0),IVTHU(0),parnames(0),unames(0),SP(0))
    allocate(STOPS(0),UVALS(0),PARVALS(0))
    ICU(1)='1'
    NPOS=1
    do
      call READC(UNITC,EOF,LINE,NPOS,STR,KEYEND,POS,LISTLEN,IERR)
      if(EOF .or. IERR==-1) exit
      KEYS=.TRUE.
      if(IERR==1) then
        call INSTRHO(STR(1:KEYEND),STR(POS:),LISTLEN,IERR)
      endif
      if(IERR==1) then
        write(6,'(A,A,A,I2)')"Unknown AUTO constant ", STR(1:KEYEND)," on line ",LINE
        call AUTOSTOP()
      else if(IERR==3) then
        write(6,"(A,I2,A)") " Error in fort.2 or c. file: bad value on line ", LINE,"."
        call AUTOSTOP()
      endif
    end do
    if(EOF .and. IERR/=-1 .and. .not. KEYS) then
      return
    endif
    AP%NDIM=NDIM
    AP%IPS=IPS
    AP%IRS=IRS
    AP%ILP=ILP
    AP%NTST=NTST
    AP%NCOL=NCOL
    AP%IAD=IAD
    AP%IADS=IADS
    AP%ISP=ISP
    AP%ISW=ISW
    AP%IPLT=IPLT
    AP%NBC=NBC
    AP%NINT=NINT
    AP%NMX=NMX
    AP%NUZR=0
    do I=1,SIZE(IVUZR)
      AP%NUZR=AP%NUZR+SIZE(IVUZR(I)%VAR)
    enddo
    do I=1,SIZE(IVUZSTOP)
      AP%NUZR=AP%NUZR+SIZE(IVUZSTOP(I)%VAR)
    enddo
    AP%NPR=NPR
    AP%MXBF=MXBF
    AP%IIS=IIS
    AP%IID=IID
    AP%ITMX=ITMX
    AP%ITNW=ITNW
    AP%NWTN=NWTN
    AP%JAC=JAC
    AP%NPAR=NPAR
    AP%IBR=IBR
    AP%LAB=LAB
    AP%NICP=SIZE(ICU)
    AP%NTEST=2
    AP%NDM=NDIM
    AP%NPARI=0
    AP%ITP=0
    AP%ITPST=0
    AP%NFPR=1
    AP%NTOT=0
    AP%NINS=0
    AP%DS=DS
    AP%DSMIN=ABS(DSMIN)
    AP%DSMAX=ABS(DSMAX)
    AP%RDS=DS
    AP%RL0=RL0
    AP%RL1=RL1
    AP%A0=A0
    AP%A1=A1
    AP%EPSL=EPSL
    AP%EPSU=EPSU
    AP%EPSS=EPSS
    AP%DET=0.d0
    AP%FLDF=0.d0
    AP%HBFF=0.d0
    AP%BIFF=0.d0
    AP%SPBF=0.d0
    EOF=.FALSE.
  END SUBROUTINE INIT

  SUBROUTINE CLEANUP()
    use AUTO_CONSTANTS, ONLY : IVTHU,IVUZR,IVUZSTOP,IVTHL,ICU,parnames, &
         unames,SP,STOPS,PARVALS,UVALS
    implicit none
    do I=1,SIZE(IVUZR)
      deallocate(IVUZR(I)%VAR)
    enddo
    do I=1,SIZE(IVUZSTOP)
      deallocate(IVUZSTOP(I)%VAR)
    enddo
    deallocate(IVTHU,IVUZR,IVUZSTOP,IVTHL,ICU,parnames,unames,SP,STOPS, &
         PARVALS,UVALS)
  END SUBROUTINE CLEANUP

  SUBROUTINE INIT1(AP)
    use AUTO_CONSTANTS, ONLY:IVTHL,TY
    use SUPPORT, ONLY: LBTYPE
    double precision, parameter :: HMACH=1.0d-7
    type(AUTOPARAMETERS) AP
    integer J
    double precision DS,DSMIN,FC
    DS=AP%DS
    DSMIN=AP%DSMIN
    if(AP%ISW.EQ.0) AP%ISW=1
    if(DS.EQ.0.d0) DS=0.1
    if(DSMIN.EQ.0.d0) DSMIN=1.0D-4*ABS(DS)
    FC=1.d0+HMACH
    AP%DS=FC*DS
    AP%DSMIN=DSMIN/FC
    AP%DSMAX=FC*AP%DSMAX
    AP%NPARI=0
    if(.NOT.ALLOCATED(IVTHL)) then
      if(AP%IPS==2 .OR. AP%IPS==12) then
        allocate(IVTHL(1))
        IVTHL(1)%INDEX='11'
        IVTHL(1)%VAR=0d0
      else
        allocate(IVTHL(0))
      endif
    endif
    if(len_trim(TY)>=2) then
      do I=-9,9
        if(LBTYPE(I)==TY(1:2)) then
          AP%ITP=I
          exit
        endif
      enddo
      if(TY(1:2)=='GH') then
        AP%ITP=-32
      endif
      if(.NOT.(AP%IPS<=1 .OR. AP%IPS==5 .OR. AP%IPS==11)) then
        if(AP%ITP==1) then
          AP%ITP=6
        else if(AP%ITP==2) then
          AP%ITP=5
        endif
      endif
    endif
    return
  END SUBROUTINE INIT1

END MODULE auto_entry

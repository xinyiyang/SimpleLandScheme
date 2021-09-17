!************************************************************************
! Model basic setting 
! including: (1) common physical constants
!            (2) land prognostic variables setting
!            (3) land parameters setting
!            (4) namelist for Land 
!            (5) ATMO (in) variables setting used to force simple LSM
!            (6) namelist for ATMO
!            (7) output variables setting
! 
!                                            -- Xinyi Yang
!                                               04/14/2021
!************************************************************************

Module PhysicalConstants
  Implicit None
  Real, Parameter ::          &
       &    AirDensity=1.20   & ! air density            [kg/m^3]
       &  , Rair=287.040      & ! gas constant air       [J/kg/K]
       &  , Hlatent=2.43d6    & ! latent heat            [J/kg]
       &  , Cp=1.004d3          ! heat capacity          [J/kg/K] 

End Module PhysicalConstants


Module LandVariable
!************************************************************************
! Prognostic variables (only) on the Land
!   (1) energy balance (Unit:W/m**2)
!       Evap = EvapI + EvapT 
!       Evap  :: total evaporation
!       EvapT :: evapotranspiration, EvapI :: interception loss
!       SH    :: sensible heat  
!       Ts    :: surface temperature
!   (2) water balance 
!       WD    :: water depth, unit: mm
!       wet   :: wetness, unitless
!       Runs  :: surface runoff, unit: W/m**2
!       Rung  :: subsurface runoff
!       Runt  :: total runoff, where Runf = Runs +Rung
!   (3) aerodynamic resistance : Ra
!       Ra    :: Ra=1/(ndc * effective wind speed)
!************************************************************************
  Use Dimensions

  Implicit None
  Real, Dimension(nx,ny), Target   :: Evap, EvapI, EvapT, SH, Ts       ! energy

  Real, Dimension(nx,ny), Target   :: WD, wet, Runt, Runs              ! water

  Real, Dimension(nx,ny), Target   :: Ra                               ! Land parameters

  
End Module LandVariable



Module LandParameter
!************************************************************************
! Parameter values for Simple LSM
! Two ways, prescribed in advance or based surface type setting values.  
! note: 1. all the parameters setting here are replaceable through
!          reading prescribed *.nc/*.dat files (e.g.,vary with geographically
!          distinct soil types. 
!************************************************************************
  Use Dimensions

  Implicit None
  ! (1) prescribed in advance
  Real, Dimension(nx,ny)     :: sfctype, albedo, ndc                ! neutral drag coefficient
  !Real, Dimension(nx,ny)     :: Z0                                 ! roughness
  
  ! (2)setting values based on surface type 
  Integer, Parameter         :: ntype = 4                           ! num of surface type, including ocean
  Real, Dimension(0:ntype-1) :: rsmin = (/0., 150., 200.,200./)     ! min surface resistance, unit(m/s )
  Real, Dimension(0:ntype-1) :: albd  = (/.07, .12, .19,.30 /)      ! get albedo from sfc type  
  Real, Dimension(0:ntype-1) :: rl    = (/.0024,2.,.1,.05/)         ! roughness length, unit(m), can be calculated by veg. height 
  Real, Dimension(0:ntype-1) :: lai   = (/0.,6.,3.,1./)             ! Leaf Area Index
  Real, Dimension(0:ntype-1) :: WDmax = (/0.,500.,400.,300./)       ! field capacity/ water depth, unit(mm)       

End Module LandParameter



Module NameListLandDef
!************************************************************************
! Read absolute directories from 'LandNameList' file (~/lsm/utility/)
! Includes: (1) albedo,  (2) sfc type            ------ Land Parameter
!           (3) sfc Temp (4) 1st soil wetness    ------ Land Init
!           (5) model output data                ------ Land Output 
!************************************************************************
  implicit none
  Character(len=130)              :: fn_albedo, fn_sfctype
  Character(len=130)              :: fn_ts,     fn_wetness
  Character(len=130)              :: fn_output

  namelist /nmlLandParameter/        fn_albedo, fn_sfctype
  namelist /nmlLandVarInit/          fn_ts,     fn_wetness
  namelist /nmlLandVarOut/          fn_output

End Module NameListLandDef



Module ATMO_in
!************************************************************************
! ATMO Forcing data:
! Include:  1. precipitation,radiation flux,Ta,wind field, specific humudity
!           2. 3D  (time x lat x lon)
!           3. Upward SW radiation is caculated by Subroutine UpwardSWRadiationFlux
!           4. Upward LW radiation is caculated by Subroutine UpwardLWRadiationFlux
!           4. Here we used var(time x lat x lon) to force model
!Note:
!     Only use for forcing LSM and evaluate scheme preformance.  
!************************************************************************

  Use Dimensions

  Implicit None
  ! ATMO data mode, forcing data (time x lat x lon)
  ! should be deleted if coupled to CAM
  Real, ALLOCATABLE,Dimension(:,:,:)         :: pr_ts, SWdw_ts, LWdw_ts, us_ts, vs_ts, Ta_ts, qa_ts
  ! derived variable 
  Real, ALLOCATABLE,Dimension(:,:,:)         :: SWuw_ts, LWuw_ts
  ! ith step forcing data (lat x lon)
  Real, Dimension(nx,ny)                     :: pr, SWdw, LWdw, SWuw, LWuw, us, vs, Ta, qa

End Module ATMO_in



Module NameListAtmoForceDef
!************************************************************************
! Read absolute directories from 'ATMONameList' file (~/lsm/utility/)   
!************************************************************************
  implicit none
  Character(len=130)              :: fn_SWdw, fn_LWdw, fn_pr, fn_us, fn_vs, fn_Ta, fn_qa

  namelist /nmlAtmoForcing/          fn_SWdw, fn_LWdw, fn_pr, fn_us, fn_vs, fn_Ta, fn_qa

End Module NameListAtmoForceDef



Module LandOutput
!************************************************************************
! Model output 3D (time x lat x lon))
!************************************************************************
  Use Dimensions

  Implicit None

  Real, ALLOCATABLE,Dimension(:,:,:)         :: SH_out, Evap_out, Ts_out, EvapT_out                     ! energy
  Real, ALLOCATABLE,Dimension(:,:,:)         :: wet_out, WD_out, Runs_out, Runt_out                     ! water

End Module LandOutput

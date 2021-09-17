Subroutine land
!************************************************************************
! Simple Land surface model version beta 
!
! 
!                                            -- Xinyi Yang
!                                               04/14/2021
!************************************************************************
  
   Use Dimensions,           Only     : nx, ny, deltt
   Use LandParameter,        Only     : sfctype, WDmax, rsmin, lai
   Use LandVariable,         Only     : Ts, SH, Evap, EvapI, EvapT, WD, wet, Ra, Runt, Runs
   Use PhysicalConstants,    Only     : Hlatent
   Use ATMO_in,              Only     : SWdw, SWuw, LWdw, LWuw, Ta, pr

   Implicit None

   ! local variables
   Integer                            :: itype                               ! sfc type index
   Real                               :: Rnet, FEnet, FWnet
   Real                               :: EvapImax, tau_0, Fitc               ! Interception loss related local variables
   Real                               :: Wimax, rints, tau_r, tiny           ! Interception loss related local variables
   Real                               :: beta                                ! Evap parameter, fuction of wetness
   Real                               :: Rungmax, Rung                       ! Run off parameters
   Real                               :: Coeffs, Coeffg, CHE                 ! Run off parameters
   Real                               :: HCsoil                              ! heat capacity of soil
   Integer                            :: i , j                               ! loop index


   Data tiny/0.0000000001/                   ! tiny to avoid division by zero
   ! non-surface type dependent parameters
   Data Wimax/0.1/                           ! max intercepted water per leaf area; kg/m2 (mm)
   Data rints/1.06e-3/                       ! storm intensity, 3.8mm/hr(from ARME)->mm/s  
   Data tau_r/4320./                         ! storm duration,  1.2hrs ->s
   Data Rungmax/4.e-4/                       ! subsurface runoff at saturation; kg/m2(mm)/s
   Data CHE/4/                               ! Clapp-Hornberger exponent

   HCsoil = 4.18e3*1.e3*.1                   ! 1cal/g/K * 1g/cm3 * .1m;  J/M2,
                                             ! soil heat capacity * density * Depth
                                             ! assume .1m water-like soil


   Do j=1,ny
      Do i=1,nx
         itype = int(sfctype(i,j))
         If(itype.Ne.0.) Then

            !-----------------------------------------------------------------------------
            ! Interception loss; stochastic rainfall effects included (adapted from Zeng 1996)
            !-----------------------------------------------------------------------------

               Rnet  = SWdw(i,j)-SWuw(i,j)+LWdw(i,j)-LWuw(i,j)            ! net sfc radiation

               EvapImax = Rnet-SH(i,j)                                    ! simply set EvapImax to available energy
                                                                          ! sensible heat is calculated by sfcflux.f90 in advance

               EvapImax = Max(tiny,EvapImax)                              ! minimum of tiny if too small
            
               tau_0  = Wimax*lai(itype)/EvapImax*Hlatent                 ! time to evaporate a saturated  can

               Fitc   = (tau_r+tau_0*.8)*pr(i,j)/(Hlatent*rints*tau_r)    ! interception function

               EvapI(i,j) = EvapImax*Fitc                                 ! interception loss

               EvapI(i,j) = min(EvapI(i,j),0.5*pr(i,j))                   ! cap EvapI



            !-----------------------------------------------------------------------------
            ! evaporation; aerodynamic resistance 
            !-----------------------------------------------------------------------------

               wet(i,j)=WD(i,j)/WDmax(itype)                              ! wetness
               
               beta=Sqrt(Sqrt(wet(i,j))) 

               ! potential Evap = ET * Ra is calculated in sfcflux.f90
               EvapT(i,j)=beta*Ra(i,j)/(rsmin(itype)+Ra(i,j))*EvapT(i,j)  ! actual ET = beta * Potential ET

               Evap(i,j)=EvapI(i,j)+EvapT(i,j)                            ! total Evap



            !-----------------------------------------------------------------------------
            ! runoff (adapted from BATS)
            !-----------------------------------------------------------------------------

               Coeffs    = wet(i,j)**4                                    ! surface runoff parameter

               Runs(i,j) = Coeffs*(pr(i,j)-EvapI(i,j))                    ! surface runoff, BATS formulation

               Coeffg    = wet(i,j)**(2*CHE+3)                            ! subsurface runoff parameter

               Rung      = Coeffg*Rungmax*Hlatent                         ! optimization for speed

               Runt(i,j) = Runs(i,j)+Rung                                 ! total runoff; in W/m2


            
            !-----------------------------------------------------------------------------
            ! soil moisture equation: one-layer model
            !-----------------------------------------------------------------------------

               FWnet=(pr(i,j)-Evap(i,j)-Runt(i,j))/Hlatent                ! net water flux; mm/s

               WD(i,j)=WD(i,j)+deltt*FWnet                                ! water depth

               WD(i,j)=Max(WD(i,j),0.)                                    ! zero if negative (due to numerics)

               if (WD(i,j)/WDmax(itype).gt.1.00) then 
                  write(*,*) 'warning! wet=',WD(i,j)/WDmax(itype),i,j
               end if

               !wet(i,j)=Min(Dwet(i,j),0.9999)                                ! cap wetness



            !-----------------------------------------------------------------------------
            ! soil moisture equation: one-layer model
            !    ground temperature; 10cm water-like soil gives a 20min/K damping rate
            !    with typical flux; this mimics the surface soil layer response. 
            !-----------------------------------------------------------------------------
               FEnet= Rnet-Evap(i,j)-SH(i,j)       ! net energy absorbed by surface

               Ts(i,j)=Ts(i,j)+deltt*FEnet/HCsoil

               Ts(i,j)=min(Ts(i,j),350.)           ! cap surface temperature

         End If
      End Do
   End Do

   Return
End Subroutine land

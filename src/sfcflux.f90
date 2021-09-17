Subroutine Surfaceflux
!************************************************************************
! Surface fluxes including sensible heat and Potential Evaporation
! Computes:
! FTs               !sensible heat                     W/m**2
! Potential Evap    !evaporation                       W/m**2
!
!                                            -- Xinyi Yang
!                                               04/14/2021
!************************************************************************

    Use Dimensions,           Only     : nx,ny
    Use LandParameter,        Only     : sfctype, ndc
    Use LandVariable,         Only     : Ts, SH, EvapT, Ra
    Use PhysicalConstants,    Only     : Cp, AirDensity, Hlatent
    Use ATMO_in,              Only     : Ta, us, vs, qa


    Implicit None

    ! local variables and functions
    Integer                            :: i, j                ! loop index
    real, external                     :: hsat                ! hsat - function
    Real, Dimension(nx,ny)             :: ws                  ! effective wind speed for Evap and FTs


    Call SfcWindForFlux(us,vs,ws)

    Do j=1,ny
        Do i=1,nx
            ! ===========================Aerodynamic Resistanc===================================
                Ra(i,j)= 1/(ndc(i,j)*ws(i,j))

            ! ===============================Potential Evaporation===============================
                ! AirDensity: [kg/m^3]
                ! Cp        : [J/kg/K] 
                ! Hlatent   : [J/kg] 
                ! Ra        :  s/m
                ! qa        : kg/kg or unitless

                EvapT(i,j)= AirDensity * Cp * (1/Ra(i,j)) * ( hsat(Ts(i,j)) * Hlatent/Cp - qa(i,j))

                if (EvapT(i,j).le.0) then
                    EvapT(i,j) = 0.
                end if



            ! ===============================Sensible Heat=====================================
                SH(i,j)=AirDensity * Cp * (1/Ra(i,j)) *(Ts(i,j)-Ta(i,j))
                ! Limit the heat flux into the ocean to 5 W/m^2.
                !if  (STYPE(i,j)==0.) FTs(i,j)=max(FTs(i,j),-5.)

        End Do
    End Do

  Return
End Subroutine Surfaceflux



Function hsat(T1)
    real      :: T1, T, esat    
    T = T1-273.15
    esat = .6108d0*dexp(17.27d0*T/(237.3+T))*10  ! Tetens equation where temperature T is in °C 
                                               ! and  esat is in hPa by *10
    hsat = .622*esat/(1000.-0.378*esat)          ! unit= kg/kg, assuming Pressure=1000hpa
  
  Return
End Function hsat



Subroutine SfcWindForFlux(us,vs,EWS)
  ! Note: the wind speed for evaporation/sensible heat is allowed to be
  !   computed differently from that for momentum; without a
  !   PBL parameterization q,T at surface are not simulated accurately enough.
  !   This leads to somewhat too sensitive dependence of evaporation on wind
  !   speed.  The evaporation-wind feedback, therefore MJO is also quite
  !   sensitive to this parameterization.
  ! 

  Use Dimensions
  Implicit None
  Real, Dimension(nx,ny), Intent(in)  :: us,vs
  Real, Dimension(nx,ny), Intent(out) :: EWS
  Real, Parameter                     :: eta       = 0.6        &
                    &                  , VVsFmin   = 5.0        & ! minimum surface wind speed for EvapT and SH
                    &                  , VsCoeff   = -0.17        ! winds proj. coeff. for EvapT

  Real, Dimension(nx,ny)              :: WS                       ! Wind speed
  

  ! effective surface wind speed for Evaporation and Sensible heat
    WS=us**2+vs**2
    EWS=Sqrt(VVsFmin**2+eta**2*WS)

  Return
End Subroutine SfcWindForFlux

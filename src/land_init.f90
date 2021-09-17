!************************************************************************
! Initilize Land time-independent Varibels:
! including: (1) albedo, land surface type,neutral drag coefficient
!            (2) surface temp, wetness at time t=0
! 
!                                            -- Xinyi Yang
!                                               04/14/2021
!************************************************************************

Subroutine LandInit

   Use Dimensions,       Only     : nx,ny
   Use LandParameter,    Only     : sfctype, albedo, ndc, rl, albd, WDmax
   Use LandVariable,     Only     : Ts, WD, wet
   Use NameListLandDef

   Implicit None
  
   Integer                       :: itype            ! sfc type index
   Integer                       :: error            ! test whether open file correctly
   Integer                       :: i, j

   Real                          :: vkc, hpbl        ! Von Karman constant, height of PBL

   print*,"Start to read LAND initial condition and parameters:"
   ! use namelist reading filenames of datasets
   open(10, file = "../utility/LandNameList",status="old",iostat=error)   ! lsm/utility/LandNameList is used to update data filename
   if (error/=0) then 
      write(*,*) "Open file fail."
      stop 
   end if
   read(10, nml=nmlLandParameter)
   read(10, nml=nmlLandVarInit)
   Close(10)
      print*,"    LandNameList has been SUCCESSFULLY read!"


   ! reading prescribed albedo.nc
   open(20,file=fn_albedo,form='unformatted',status="old",access="SEQUENTIAL",action='read',iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if
   read(20) albedo  ! annual mean surface albedo
   close(20)
         print*,"       SUCCESSFULLY read:",fn_albedo

   ! reading prescibed sfc_type.nc
   open(20,file=fn_sfctype,form='unformatted',status="old",access="SEQUENTIAL",action='read',iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if
      read(20) sfctype   ! surface type 
   close(20)
         print*,"       SUCCESSFULLY read:",fn_sfctype

   ! reading Ts at time t= 0
   open(20,file=fn_ts,form='unformatted',status="old",access="SEQUENTIAL",action='read',iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if
      read(20) Ts  ! skin surface temperature
   close(20)
         print*,"       SUCCESSFULLY read:",fn_ts

   ! reading wetness(unit: %) at time t= 0
   open(20,file=fn_wetness,form='unformatted',status="old",access="SEQUENTIAL",action='read',iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if
      read(20) wet  ! wetness
   close(20)
         print*,"       SUCCESSFULLY read:",fn_wetness

   Do j=1,ny
      Do i =1,nx
         itype = int(sfctype(i,j))

         !*****surface albedo based on sfc type***************
         ! albedo(i,j)=albd(itype)


         !*********neutral drag coefficient***********
         vkc  = 0.4                                              ! Von Karman constant
         hpbl = 2000.                                            ! 2km height of PBL
         ndc(i,j)= 1./(Log(.025*hpbl/rl(itype))/vkc+8.4)**2      ! Deardorff (1972) where hpbl = 2000 


         !*****surface Temprature***************
         ! Ts(i,j) = 292.

         !*****Water Depth***************
         If(itype .Ne. 0.) Then
            WD(i,j) =WDmax(itype)*wet(i,j)                       ! get initial condition form observed data to start
            !WD(i,j) =WDmax(itype)*0.6                           ! 60% saturation to start
         End If 
      end Do 
   end Do
         print*,"    Water depth and neutral drag coefficient has been SUCCESSFULLY initialized!"
   print*, "Land Initialization Done!"
   return
   
End Subroutine LandInit

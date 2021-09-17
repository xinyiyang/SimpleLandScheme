!************************************************************************
! Read ATMO variables who are driving land process:
! including: 
!     precipitation, radiation flux, Ta, wind speed, specific humudity
!
! Note:
!       Var      |       original unit          |        unit in model
!       pr       |        kg m-2 s-1            |           w m-2
!    radiation   |          w m-2               |           w m-2
!   wind speed   |            m/s               |           m/s
!       Ts       |            K                 |           K
!  specific hum  |           kg/kg              |           kg/kg
! 
!                                            -- Xinyi Yang
!                                               04/14/2021
!************************************************************************

Subroutine AtmoForcing

   Use Dimensions
   Use PhysicalConstants, only : Hlatent,Cp
   Use ATMO_in
   Use NameListAtmoForceDef

  

   Implicit None

   integer                 :: i, j, it
   integer                 :: nrec = 0
   integer                 :: ivar = 1
   Integer                 :: error            ! test whether file open correctly

   ALLOCATE(pr_ts(nx,ny,nstep),SWdw_ts(nx,ny,nstep),LWdw_ts(nx,ny,nstep),SWuw_ts(nx,ny,nstep),LWuw_ts(nx,ny,nstep))
   ALLOCATE(us_ts(nx,ny,nstep),vs_ts(nx,ny,nstep),Ta_ts(nx,ny,nstep),qa_ts(nx,ny,nstep))

   print*,"Start to read ATMO forcing data:"
   ! use namelist reading filenames of datasets
   open(10, file = "../utility/ATMONameList",status="old",iostat=error)
   if (error/=0) then 
      write(*,*) "Open file fail."
      stop 
   end if
   read(10, nml=nmlAtmoForcing)
   Close(10)
   print*,"    ATMONameList has been SUCCESSFULLY read!"

   
   ! precipitation
   open(20,file=fn_pr,form='unformatted',status="old",access="direct",action='read',recl=4*ivar*nx*ny,iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if

      do it=1,nstep
         nrec = nrec + 1
         read(20,rec=nrec) ((vs_ts(i,j,it),i=1,nx),j=1,ny) 
      end do
   pr_ts = vs_ts*Hlatent
   Close(20)
         print*,"       SUCCESSFULLY read:",fn_pr 

   nrec = 0
   ! total wind speed
   open(20,file=fn_us,form='unformatted',status="old",access="direct",action='read',recl=4*ivar*nx*ny,iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if

      do it=1,nstep
         nrec = nrec + 1
         read(20,rec=nrec) ((us_ts(i,j,it),i=1,nx),j=1,ny)  
      end do
   Close(20)
   vs_ts = 0.
         print*,"       SUCCESSFULLY read:",fn_us

   nrec = 0
   ! downward SW radiation flux
   open(20,file=fn_SWdw,form='unformatted',status="old",access="direct",action='read',recl=4*ivar*nx*ny,iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if 

      do it=1,nstep 
         nrec = nrec + 1
         read(20,rec=nrec) ((SWdw_ts(i,j,it),i=1,nx),j=1,ny)  
      end do
   Close(20)
   SWuw_ts = 0.
         print*,"       SUCCESSFULLY read:",fn_SWdw

   nrec = 0
   ! downward LW radiation flux
   open(20,file=fn_LWdw,form='unformatted',status="old",access="direct",action='read',recl=4*ivar*nx*ny,iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if

      do it=1,nstep
         nrec = nrec + 1
         read(20,rec=nrec) ((LWdw_ts(i,j,it),i=1,nx),j=1,ny)  
      end do
   Close(20)
   LWuw_ts = 0.
         print*,"       SUCCESSFULLY read:",fn_LWdw

   nrec = 0
   ! temperature of air (bottom layer)
   open(20,file=fn_Ta,form='unformatted',status="old",access="direct",action='read',recl=4*ivar*nx*ny,iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if
      
      do it=1,nstep 
         nrec = nrec + 1
         read(20,rec=nrec) ((Ta_ts(i,j,it),i=1,nx),j=1,ny)  
      end do
   Close(20)
         print*,"       SUCCESSFULLY read:",fn_Ta

   nrec = 0
   ! specific humidty (bottom layer)
   open(20,file=fn_qa,form='unformatted',status="old",access="direct",action='read',recl=4*ivar*nx*ny,iostat=error)
      if (error/=0) then 
         write(*,*) "Open file fail."
         stop
      end if

      do it=1,nstep
         nrec = nrec + 1
         read(20,rec=nrec) ((vs_ts(i,j,it),i=1,nx),j=1,ny)
      end do
   qa_ts= vs_ts *Hlatent/Cp  ! unit to K
   Close(20)
   vs_ts = 0.
         print*,"       SUCCESSFULLY read:",fn_qa

   print*, "ATMO forcing data read Done!"
   Return

End Subroutine AtmoForcing


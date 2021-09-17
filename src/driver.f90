Subroutine LandProcess

   use Dimensions
   Use LandVariable
   Use LandParameter,     Only: sfctype
   Use ATMO_in
   Use LandOutput

   implicit none
   Integer                   :: it, i, j             ! loop index
   Integer                   :: itype                ! sfc type index
   !Integer                   :: ivar, irec           ! output index

   ALLOCATE(Ts_out(nx,ny,nstep),Evap_out(nx,ny,nstep),EvapT_out(nx,ny,nstep),SH_out(nx,ny,nstep))
   ALLOCATE(wet_out(nx,ny,nstep),Runs_out(nx,ny,nstep),Runt_out(nx,ny,nstep),WD_out(nx,ny,nstep))

   !call LandInit
   !call AtmoForcing
   print *, "Model starts to run"
   Do it = 1 , nstep
         pr(:,:)    = pr_ts(:,:,it)
         Ta(:,:)    = Ta_ts(:,:,it)
         us(:,:)    = us_ts(:,:,it)
         vs(:,:)    = vs_ts(:,:,it)
         qa(:,:)    = qa_ts(:,:,it)

         LWdw(:,:)  = LWdw_ts(:,:,it)
         call UpwardLWRadiationFlux
         SWdw(:,:) = SWdw_ts(:,:,it)
         call UpwardSWRadiationFlux
          
         call Surfaceflux
         call land

      ! set missing value over ocean 
      Do j=1,ny
         Do i =1,nx
            itype = int(sfctype(i,j))
            If(itype.EQ.0.) Then
               Ts(i,j)    = -32767   ! temperature
               Evap(i,j)  = -32767   ! total evapotranspiration
               !EvapI(i,j) = -32767  ! total evapotranspiration
               EvapT(i,j) = -32767   ! total evapotranspiration
               SH(i,j)     = -32767  ! sensible heat 

               wet(i,j)   = -32767   ! wetness
               WD(i,j)    = -32767   ! water depth
               Runs(i,j)  = -32767   ! surface runoff
               Runt(i,j)  = -32767   ! total runoff
            End If 
         End DO
      End Do

      Ts_out(:,:,it)    = Ts(:,:)
      Evap_out(:,:,it)  = Evap(:,:)
      !EvapI_out(:,:,it) = EvapI(:,:)
      EvapT_out(:,:,it) = EvapT(:,:)
      SH_out(:,:,it)    = SH(:,:)
      
      WD_out(:,:,it)    = WD(:,:)
      Runs_out(:,:,it)  = Runs(:,:)
      Runt_out(:,:,it)  = Runt(:,:)
      wet_out(:,:,it)   = wet(:,:)
   
      !print *, "Model is running at",it,"step"
   
   End Do

   ! deallocate ATMO forcing memory 
   Deallocate(pr_ts, SWdw_ts, LWdw_ts, SWuw_ts, LWuw_ts)
   Deallocate(us_ts,vs_ts,Ta_ts,qa_ts)

   print *, "Model has been SUCCESSFULLY run!"


End Subroutine LandProcess
!-mcmodel=large
!-mcmodel=medium 
!gfortran -mcmodel=medium modelsetting.o atmo_forcing.o land_init.o radiationflux.o sfcflux.o land.o run.f90
!gfortran -I/share/kkraid/yangx2/apps/netcdf4-needed/include -L/share/kkraid/yangx2/apps/netcdf4-needed/lib -lnetcdff -lnetcdf bnd_init.o forcing.o modelsetting.o parameter.o ReadNC.o sflux.o var_init.o test.f90

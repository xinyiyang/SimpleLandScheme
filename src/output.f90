Subroutine LandOutput

   Use Dimensions
   Use NameListLandDef
   Use LandOutput

   implicit none
   Integer                   :: it, i, j             ! loop index
   Integer                   :: itype                ! sfc type index
   Integer                   :: ivar, irec           ! output index
   Integer                   :: error                ! test whether open file correctly

   ! use namelist reading directory of output data
   open(10, file = "../utility/LandNameList",status="old",iostat=error)
! lsm/utility/LandNameList is used to update data filename
   if (error/=0) then 
      write(*,*) "Open file fail."
      stop 
   end if
   read(10, nml=nmlLandVarOut)
   Close(10)

   ivar = 8
   open(unit=13,file=fn_output,status='replace',&
         &form="unformatted",convert='LITTLE_ENDIAN',access="direct",recl=4*ivar*nx*ny)    
   irec=1
      do it=1,nstep 
         write(13,rec=irec) ((Ts_out(i,j,it),i=1,nx),j=1,ny),((Evap_out(i,j,it),i=1,nx),j=1,ny),&
                            &((EvapT_out(i,j,it),i=1,nx),j=1,ny),((SH_out(i,j,it),i=1,nx),j=1,ny),&
                            &((Runs_out(i,j,it),i=1,nx),j=1,ny),((Runt_out(i,j,it),i=1,nx),j=1,ny),&
                            &((wet_out(i,j,it),i=1,nx),j=1,ny),((WD_out(i,j,it),i=1,nx),j=1,ny)
         irec=irec+1
      end do 
   close(unit=13)
   
   Deallocate(SH_out, Evap_out, Ts_out, EvapT_out)
   Deallocate(wet_out, WD_out, Runs_out, Runt_out)

   print *, "Model output has been SUCCESSFULLY written!"
   print*, "Model output directory:",fn_output


End Subroutine LandOutput

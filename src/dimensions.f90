Module Dimensions
!************************************************************************
! Model basic setting 
! 1. horizontal resolution 
! 2. delt t
! 3. total time integration steps
!************************************************************************
  implicit none
  Integer, Parameter :: nx    = 128           & ! longitude grid size
       &              , ny    = 64           & ! latitude grid size        
       &              , deltt = 10800        & ! unit MUST be "s" 
       &              , nstep = 87656          ! unitless, changeable, total time integration steps 
                                
End Module Dimensions

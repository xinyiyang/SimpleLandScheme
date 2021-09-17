program LandMain

  implicit none

  call LandInit
  call AtmoForcing
  call LandProcess 

  call LandOutput

End program LandMain

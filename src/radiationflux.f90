Subroutine UpwardLWRadiationFlux

   Use LandVariable,    only       : Ts
   Use ATMO_in,         only       : LWuw



   Implicit None

   Real, Parameter ::               &
         &    sigma = 5.67d-8       &  
         &  , es    = 1!0.98
   
   LWuw=es*sigma*(Ts**4)
     
   Return
End subroutine UpwardLWRadiationFlux



Subroutine UpwardSWRadiationFlux

   Use LandParameter,   only       : albedo
   Use ATMO_in,         only       : SWdw, SWuw

   Implicit None

      SWuw=SWdw*albedo
     
   Return
End subroutine UpwardSWRadiationFlux
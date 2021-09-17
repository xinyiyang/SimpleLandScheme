#!/bin/csh -f
gfortran -c dimensions.f90
gfortran -c modelsetting.f90
gfortran -c land_init.f90
gfortran -c atmo_forcing.f90    
gfortran -c radiationflux.f90                                                                      
gfortran -c sfcflux.f90                                                                        
gfortran -c land.f90    
gfortran -c driver.f90
gfortran -c output.f90                                                                                  

gfortran -mcmodel=medium dimensions.o  modelsetting.o atmo_forcing.o land_init.o radiationflux.o sfcflux.o land.o driver.o output.o main.f90 -o model.run


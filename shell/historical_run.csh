#!/bin/csh -f
# A historical run test written by Xinyi Yang 09/15/2021

#------------------------------------- User-defined ----------------------------------------
# Directory of LSM Model 
     set LSMHOME    = /share/kkraid/yangx2/fortran/lsm
     set LSMSCR     = ${LSMHOME}/src
     set LSMUTI     = ${LSMHOME}/utility
    
     set case       = historical_run
     if ( -e ${LSMHOME}/output/${case}/) rm -rf ${LSMHOME}/output/${case}/
     mkdir ${LSMHOME}/output/${case}
     set LSMOUT     = ${LSMHOME}/output/${case}
     
     set dir_output = ${LSMHOME}/output/${case}/output.dat

# Model grid setting (passing it to ~/src/dimensions.f90)
     setenv NX     128                           # longitude grid size
     setenv NY     64                            # latitude grid size 
     setenv DELTT  10800                         # unit MUST be "s" , here uses 3-hourly, 3 x 60 x 60 =1088
     setenv NSTEP  87656                         # unitless, changeable, total time integration steps 

# Land Initialization (MUST consistent with model grid setting)
     set dir_albedo   = /share/kkraid/yangx2/fortran/qtcm/bnddata/alb.t42.dat
     set dir_sfctype  = /share/kkraid/yangx2/fortran/qtcm/bnddata/stype.t42.dat

     set dir_ts       = /share/kkraid/yangx2/fortran/qtcm/bnddata/skt.t42.dat
     set dir_wetness  = /share/kkraid/yangx2/fortran/qtcm/bnddata/swvl1.t42.dat

# ATMO Forcing (MUST consistent with model grid setting)
     set dir_frc_pr   = /share/kkraid/yangx2/fortran/qtcm/forcing/prcp/prcp.t42.dat
     set dir_frc_SWdw = /share/kkraid/yangx2/fortran/qtcm/forcing/dswrf/dswrf.t42.dat
     set dir_frc_LWdw = /share/kkraid/yangx2/fortran/qtcm/forcing/dlwrf/dlwrf.t42.dat
     set dir_frc_Ta   = /share/kkraid/yangx2/fortran/qtcm/forcing/tas/tas.t42.dat
     set dir_frc_us   = /share/kkraid/yangx2/fortran/qtcm/forcing/wind/wind.t42.dat
     set dir_frc_qa   = /share/kkraid/yangx2/fortran/qtcm/forcing/shum/shum.t42.dat




#---------------------------------- Passing to Model --------------------------------------
#
# (1) Define grid size
#

rm -f ${LSMSCR}/dimensions.f90
cat > ${LSMSCR}/dimensions.f90<< EOF
Module Dimensions
!************************************************************************
! Model basic setting 
! 1. horizontal resolution 
! 2. delt t
! 3. total time integration steps
!************************************************************************
  implicit none
  Integer, Parameter :: nx    = ${NX}           & ! longitude grid size
       &              , ny    = ${NY}           & ! latitude grid size        
       &              , deltt = ${DELTT}        & ! unit MUST be "s" 
       &              , nstep = ${NSTEP}          ! unitless, changeable, total time integration steps 
                                
End Module Dimensions
EOF


#
# (2) Define Land Namelist
#

rm -f ${LSMUTI}/LandNameList
cat > ${LSMUTI}/LandNameList<< EOF
&nmlLandParameter
fn_albedo = '${dir_albedo}'
fn_sfctype ='${dir_sfctype}'
/

&nmlLandVarInit
fn_ts = '${dir_ts}'
fn_wetness ='${dir_wetness}'
/

&nmlLandVarOut
fn_output = '${dir_output}'
/
EOF


#
# (3) Define ATMO forcing Namelist
#
rm -f ${LSMUTI}/ATMONameList
cat > ${LSMUTI}/ATMONameList<< EOF
&nmlAtmoForcing
fn_pr   = '${dir_frc_pr}'
fn_SWdw = '${dir_frc_SWdw}'
fn_LWdw = '${dir_frc_LWdw}'
fn_us   = '${dir_frc_us}'
fn_qa   = '${dir_frc_qa}'
fn_Ta   = '${dir_frc_Ta}'
/
EOF


#---------------------------------- Compile Model --------------------------------------
rm -f ${LSMSCR}/compile.csh

cat > ${LSMSCR}/compile.csh<< EOF
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

EOF
cd ${LSMSCR}
csh compile.csh

# copy .ctl and .csh files to post-process output
cp -r ${LSMHOME}/output/sample/. ${LSMOUT}

#---------------------------------- Run Model --------------------------------------
echo job started at `date` > ${LSMOUT}/run.log

cd ${LSMSCR}
./model.run >> ${LSMOUT}/run.log

echo job end at `date` >> ${LSMOUT}/run.log


# .dat to nc
cd ${LSMOUT}
rm -f *.nc
csh dat2nc.csh

  


# GEOtop simulations for TEMPLINK project

## Matsch_B2_DVM_Optim_001
- Info: starting simulation for B2 Mazia site copied from: 
https://github.com/EURAC-Ecohydro/MonaLisa/tree/master/geotop/1D/Matsch_B2_DVM_Optim_001
- Purpose: make first tests in R for Templink
- Results: 
	- Run with no errors
	- Simulated and observed SMC are quite different
	
## Templink_B2_001
- Info:  Starts from Matsch_B2_DVM_Optim_001
- Changes: 
	- Simulation period
		InitDateDDMMYYYYhhmm	=	01/11/2013 00:00
		EndDateDDMMYYYYhhmm	=	    31/10/2017 23:00
	- no more dynamic vegetation parameters
	- Input Observations meteo.txt extended 
		Several gaps in wind speed
		Missed incoming radation after January 2016
	- Validation Observations obs.txt extedned 
	- Inclueded in Obs soil temperatue
- Results: 
	- running

## Templink_B2_002
- Info:  Starts from Templink_B2_001
- Changes:
	-Select the right header for incoming radiation
	-Incoming radiation and wind speed were completed from input file of Matsch_B2_DVM_Optim_001 and met_IT-MtM data from EarthObs (FLUXDATA) 
- Results:	
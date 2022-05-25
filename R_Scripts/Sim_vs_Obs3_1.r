#!/usr/bin/env Rscript
# file Sim_vs_Obs3_1.r
#
# This script is a first example for comparing GEOtop outputs 
# with Templink simuations
#
# author: Raul Serban, Giacomo Bertoldi on 11-05-2022

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

###############################################################################


#### Compare soil temperature simulation to observation at station B2 ####
library(geotopbricks)
library(tidyverse)
library(ggpmisc)

#Open GEOtop simulation path
path <- "C:/Users/rserban/OneDrive - Scientific Network South Tyrol/WORKZONE/Bolzano_2021/GEOtop/Git/Templink/Templink_sim/Templink_B2_001"

path <- "C:/Users/gbertoldi/OneDrive - Scientific Network South Tyrol/Git/TEMPLINK/Templink_sim/Templink_B2_002"

path_to_plot <- "C:/Users/rserban/OneDrive - Scientific Network South Tyrol/WORKZONE/Bolzano_2021/GEOtop/Git/Templink/Plot/"

path_to_plot <- "C:/Users/gbertoldi/OneDrive - Scientific Network South Tyrol/Git/TEMPLINK/Plot/"


# Load Soil temp output file a
Tsim  <- get.geotop.inpts.keyword.value("SoilAveragedTempProfileFile",
                                       wpath=path,data.frame=TRUE,
                                       formatter="%04d") [,c(1,7:15)] #Select columns date_time and soil temp simulations at all depths
Tsim$Date12.DDMMYYYYhhmm. <- as.POSIXct(Tsim$Date12.DDMMYYYYhhmm., format = "%d/%m/%Y %H:%M", tz="GMT")

# Change more readable header names
colnames(Tsim) <- c("Date_Time","Tsim10","Tsim43","Tsim120","Tsim300","Tsim700","Tsim1600","Tsim3800","Tsim8800","Tsim20300") #Depths are in mm

#Open observation
Obs <- get.geotop.inpts.keyword.value("ObservationProfileFile",
                                     wpath=path,data.frame=TRUE,
                                     formatter="%04d")           #are open as zoo objects
#when convert back to data frame the date-time is automatic formatted
Tobs <- fortify.zoo(Obs, name = "Date_Time") [,c(1,7:16)] #select only date_time and soil temp at all depths
#Obs$Date12.DDMMYYYYhhmm. <- as.POSIXct(Obs$Date12.DDMMYYYYhhmm., format = "%d/%m/%Y %H:%M", tz="GMT")

# Convert chr to numeric
col<-2:11                      # number of columns to convert
for (i in col){
  Tobs[,i] <- as.numeric(Tobs[,i])
}

# Change more readable header names
#names(Obs)[names(Obs)=='Date12.DDMMYYYYhhmm.'] <- 'Date_Time'

# Compare simulation to observation
### Only matching times
# to make more general, needs interpolation if time granularity is different
# to make more general put outside column selection
#compare <- left_join(Tsim, Tobs, by="Date_Time") %>%   #better with NAs for timeseries plot
  na.omit()  #Keep only rows with observational data
compare <- left_join(Tsim, Tobs, by="Date_Time")

## Plot timeseries
# to make more general put outside column selection
# possible extension more "interactive" plots with basic scrolling and zooming features
p1 <- compare %>%
  as_tibble() %>%
  select(Date_Time, Tsim43, Ts_CI_z5) %>%
  pivot_longer(-1) %>%
  ggplot(aes(Date_Time, value, color=name))+
  geom_line()+
  labs(y = bquote('Temperature (°C)'), x='Date', subtitle="B2: Soil temperature", color = "")+
  theme_bw()+
  theme(legend.position = "bottom")

## Plot linear models v4 
# Prepare data
compare <- na.omit(compare)  #Keep only rows with observational data
x <- compare %>%
  mutate(o=Ts_CI_z5,
         p=Tsim43) 
# Calculate rmse, R2, and r2
R2 <- round(1 - ( sum((x$o - x$p)^2) / sum((x$o - mean(x$o))^2)), 2) 
rmse <- round(sqrt(sum((x$o - x$p)^2) / (length(x$o))), 2)
r2 <- round(cor(x$o, x$p)^2, 2) #Pearson's r2
# Plot
p2 <- ggplot(x, aes(x=o, y=p))+
  geom_point()+
  stat_poly_line(se = F)+
  labs(x = "Observed Ts_CI_z5", y = "Predicted Tsim43",
       title = substitute(
         paste(italic("r")^2, " = ", r2, " | ", italic("R")^2, " = ", R2, " | ",italic("RMSE"), " = ", rmse), 
         list(r2 = r2, R2 = R2, rmse = rmse)))+
  theme_bw()

## Plot linear models using stat_poly_eq
#Problem is that R2 is like Pearson's r2 calculated previously
formula <- y ~ x

p3 <- ggplot(x, aes(x=o, y=p))+
  geom_point()+
  stat_poly_line(formula = formula, se = F)+
  stat_poly_eq(aes(label = paste(after_stat(eq.label), 
                                 after_stat(rr.label), 
                                 after_stat(p.value.label), 
                                 sep = '*" ; "*')),
               label.x = "left",
               formula = formula)+
  labs(x = "Observed Ts_CI_z5", y = "Predicted Tsim43")+
  theme_bw()

## save the plot


library(gridExtra) #For grid arrangement
png(paste(path_to_plot,"Templink_B2_001.png",sep = ""), width = 15, height = 23, units = "cm", res=250)
grid.arrange(p1, p2, p3, ncol=1)
dev.off()


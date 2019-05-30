#' Calculates solar geometry for use in the SHADE2 model
#' @description Translation of solarC.m
#'
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#'
#' @return Returns solar altitude, azimuth, and declination
#' @export

#===============================================================================
#Calculating solar position and sun-stream geometry
#Created 11/30/2017
#===============================================================================
  solar_c <- function(driver_file, Lat, Lon){
    #Getting numerical day
      jdate <- (driver_file[, "DOY"] - 1) + (driver_file[, "Hour"] / 24)

    #Getting the offset
      tz_offset <- driver_file[, "offset"]

    #-------------------------------------------------
    #Defining solar geometry
    #-------------------------------------------------
      #Solar declination
        solar_dec <- 23.45 * ((pi) / 180) * sin(((2 * pi) * (jdate + 284)) / 365.25)

      #Calculating true solar time
        #Mean solar time (I'll come back and revisit this and replace it with something else)
          MST <- jdate + ((Lon - tz_offset * 15) / 361)

        #Equation of time
          B <- (pi / 182) * (jdate - 81)
          EOT <- ((9.87 * sin(2 * B)) - (7.53 * cos(B)) - (1.5 * sin(B))) / 1440

        #True solar time
          TST <- MST + EOT

      #Solar altitude (The way I originally coded it is commented out)
         #solar_altitude<-asin(sin(solar_dec)*sin(lat*(pi/180))-cos(solar_dec)*cos(lat*(pi/180))*cos(2*pi*TST))

        #This is an adjustment from the Li (2006) code which deals with negative solar altitudes
          sin_solar_altitude <- (sin(solar_dec) * sin(Lat * (pi / 180)) - cos(solar_dec) *
              cos(Lat * (pi / 180)) * cos(2 * pi * TST))

          sin_solar_altitude[sin_solar_altitude < 0] <- 0
          solar_altitude <- asin(sin_solar_altitude)

      #Solar azimuth (The +/- depends on the solar azimuth angle, see pg. 145 in Li (2012))
        solar_azimuth2 <- acos((cos(solar_dec) * sin(2 * pi * TST)) / cos(solar_altitude))
        ifelse(solar_azimuth2 + (pi / 2) >= (pi / 2) & solar_azimuth2 + (pi / 2) <= 1.5 * pi,
          solar_azimuth <- (pi / 2) + solar_azimuth2,
          solar_azimuth <- (pi / 2) - solar_azimuth2)

    return(c(solar_altitude, solar_azimuth))

  } #End solar_c

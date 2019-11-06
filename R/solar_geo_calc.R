#' Calculates solar geometry for use in the SHADE2 model
#' @description This function feeds into the solar_c function and calculates
#' the solar altitude, solar azimuth, and the solar declination
#' angle. The calculated solar azimuth is a first estimate that needs to be
#' adjusted in solar_c based on latitude and the solar declination angle.
#' Based on the original solarC.m matlab code.
#'
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#'
#' @return Returns solar altitude, an initial estimate of azimuth, and declination
#' @export
#===============================================================================
#Calculating solar position and sun-stream geometry
#Created 11/5/2019
#===============================================================================
  solar_geo_calc <- function(driver_file, Lat, Lon){
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

        #This is an adjustment from the Li (2006) code which deals with negative solar altitudes
        #Is this reference correct? PS 2019
          sin_solar_altitude <- (sin(solar_dec) * sin(deg2rad(Lat)) - cos(solar_dec) *
              cos(deg2rad(Lat)) * cos(2 * pi * TST))

          solar_altitude <- asin(sin_solar_altitude)

      #First estimate of solar azimuth that will be modified in solar_c.R
        solar_azimuth2 <- acos((cos(solar_dec) * sin(2 * pi * TST)) / cos(solar_altitude))
        
    return(data.frame(solar_altitude, solar_azimuth2, solar_dec))
        
  } #End solar_geo_calc function
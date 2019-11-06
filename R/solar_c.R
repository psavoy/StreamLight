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
#Created 11/5/2019
#===============================================================================
  solar_c <- function(driver_file, Lat, Lon, ...){
    #Calculate the solar altitude, declination, and initial estimate of solar azimuth
      geo_initial <- solar_geo_calc(driver_file, Lat, Lon)
      
    #Add a column to store the adjusted azimuth
     geo_initial$solar_azimuth <- NA     

    #When Latitude is > solar declination additional considerations are required to 
    #determine the correct azimuth
    #Generate a logical index where Latitude is greater than solar declination 
      lat_greater <- deg2rad(Lat) > geo_initial[, "solar_dec"]  
    
    #Add a small amount of time (1 minute) and recalculate azimuth 
      azimuth_tmp <- azimuth_adj(driver_file = driver_file[lat_greater, ], Lat = Lat, Lon = Lon)
     
    #Generate a logical index where azimuth_tmp is greater than the initial estimate
      az_tmp_greater <- azimuth_tmp > geo_initial[lat_greater, "solar_azimuth2"] 
    
    #Generate a logical index where both Lat > solar_dec & azimuth_tmp > azimuth
      add_az <- lat_greater == TRUE & az_tmp_greater == TRUE
      geo_initial[add_az, "solar_azimuth"] <- (pi / 2) + geo_initial[add_az, "solar_azimuth2"]
     
      
      sub_az <- lat_greater == TRUE & az_tmp_greater == FALSE
      geo_initial[sub_az, "solar_azimuth"] <- (pi / 2) - geo_initial[sub_az, "solar_azimuth2"]
    
    #When Latitude is < solar declination all angles are 90 - azimuth
      geo_initial[!lat_greater, "solar_azimuth"] <- (pi / 2) - driver_file[!lat_greater, "solar_azimuth2"]
    
      
    return(geo_initial[, c("solar_altitude", "solar_azimuth")])
      
  } #End solar_c function
  
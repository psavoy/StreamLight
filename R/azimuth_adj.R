#' Helper function for determining the correct solar azimuth
#' @description This function feeds into the solar_c function and is used to
#' help determine the correct solar azimuth for locations where latitude is
#' greater than the solar declination angle. Based on the original solarC.m 
#' matlab code.
#'
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#'
#' @return Returns an estimate of azimuth for the current timestep + 1 minute.
#' @export
#===============================================================================
#Calculate a temporary azimuth based on current timestep + 1 minute
#Created 11/5/2019
#===============================================================================
  azimuth_adj <- function(driver_file, Lat, Lon){
    #Add a minute
      driver_file$Hour <- driver_file[, "Hour"] + (1 / 60 / 24)
    
    return(solar_geo_calc(driver_file, Lat, Lon)$solar_azimuth2)
    
  } #End azimuth_adj function
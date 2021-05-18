#' Calculate light transmission as a function of depth and and the
#' irradiance attenuation coefficient
#' @description Calculates transmission of light in the water as a function
#' of depth and the irradiance attenuation coefficient (Kd). The decision of
#' how to produce a timeseries of Kd is left to the user based on their interests
#' and available data. An empirical relationship to estimate Kd from turbidity
#' is presented in the model documentation and associated publication.
#'
#' @param driver The site driver file
#'
#' @return Returns a dataframe of predicted light at the benthic surface
#' @export
#===============================================================================
#Modeling transmission as a function of depth and the irradiance attenuation coefficient
#Created 1/31/2020
#===============================================================================
predict_transmission <- function(driver){
  #Assign the irradiance attenuation coefficient
    kd <- driver[, "kd_pred"]

  #Calculate transmission as a function of depth
    transmission <- exp(-kd * driver[, "depth"])

  #Calculate light reaching the bed
    PAR_turb <- driver[, "PAR_subsurface"] * transmission

  return(data.frame(PAR_turb, kd))

} #End predict_transmission function

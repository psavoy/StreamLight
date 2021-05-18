#' Calculate reflection from the water surface
#' @description This function calculates reflection on the water surface based on
#' solar geometry following Kirk (2011) Light and photosynthesis in
#' aquatic ecosystems.
#'
#' @param driver The site driver file
#' @param solar_geo Solar geometry, calculated from solar_geo_calc.R
#'
#' @return Returns the % surface reflection
#' @export
#===============================================================================
#Calculating proportion of reflected light off the water surface
#===============================================================================
surface_reflection <- function(driver_file, solar_geo){
  #Solar zenith angle
    SZA <- solar_geo[, "SZA"]

  #Calculate the angle of refraction (Kirk (2011) Eq. 2.19)
    refraction_angle <- asin(sin(SZA) / 1.33)

  #Calculate the proportion of reflected light (Fresnel's equation) (Kirk (2011) Eq. 2.19)
    reflectance <- ((1/2) * (sin(SZA - refraction_angle) ^ 2) / (sin(SZA + refraction_angle) ^ 2)) +
      ((1/2) * (tan(SZA - refraction_angle) ^ 2) / (tan(SZA + refraction_angle) ^ 2))

    transmittance <- 1 - reflectance

  #Get the light just below the surface of the water
    return(driver_file[, "PAR_surface"] * transmittance)

} #End surface_reflection function


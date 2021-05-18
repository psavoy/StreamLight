#' Calculate light absorption in pure water
#' @description Calculates light absorption as a function of depth in clear water,
#' using the mean absorption coefficient for pure water derived from
#' Pope & Fry 1997 Absorption spectrum ~380–700 nm of pure water. II.
#' Integrating cavity measurements. Effectively, this assumes that attenuation is
#' solely a function of absorption from pure water. In other words, the irradiance
#' attenuation coefficient (Kd) will be equal to just the absorption coefficient for
#' pure water.
#'
#' @param driver The site driver file
#' @param absorb_coef Absorption coefficient of clear water. Defaults to the
#' value derived from Pope & Fry (1997) as explained above (absorb_coef = 0.1521645).
#'
#' @return Returns a dataframe of predicted light at the benthic surface and the
#' irradiance attenuation coefficient.
#' @export
#===============================================================================
#Function to calculate light absorption in clear water as a function of depth
#===============================================================================
absorption <- function(driver, absorb_coef = 0.1521645){
  #Scattering coefficient
    scat_coef <- 0 #I don't know this information yet
    kd <- absorb_coef + scat_coef

  #Calculate transmission as a function of depth
    transmission <- exp(-kd * driver[, "depth"])

  #Calculate light reaching the bed
    PAR_wc <- driver[, "PAR_subsurface"] * transmission

  return(data.frame(PAR_wc, kd))

} #End absorption function

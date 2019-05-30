#' Model to predict light at the stream surface#'
#' @description A combination of the SHADE2 model (Li et al. 2012) and Campbell &
#' Norman (1998) radiative transfer model
#'
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#' @param stream_azimuth #ADD DETAILS
#' @param bottom_width #ADD DETAILS
#' @param BH Bank height
#' @param BS Bank slope
#' @param WL Water level
#' @param TH Tree height
#' @param overhang Effectively canopy radius
#' @param overhang_height height of the maximum canopy overhang (think canopy radius)
#' @param x_LAD Leaf angle distribution, default = 1
#'
#' @return Returns a time series of predicted light at the stream surface
#' @export

#===============================================================================
#Function for predicting light at the stream surface
#===============================================================================
  stream_light <- function(driver_file, Lat, Lon, stream_azimuth, bottom_width, BH, BS, WL, TH, overhang, overhang_height, x_LAD){
    #-------------------------------------------------
    #Defining input parameters
    #-------------------------------------------------
      #Some error catching for SHADE2 input parameters
        if(is.na(overhang)) {overhang <- 0}

        if(overhang == 0) {overhang_height <- TH}
        if(is.na(overhang_height)) {overhang_height <- 0.75 * TH}

    #-------------------------------------------------
    #Predicting transmission of light through the canopy
    #-------------------------------------------------
      rad_trans <- rad_transfer_calc(driver_file, Lat, Lon, x_LAD)

    #-------------------------------------------------
    #Running the SHADE2 model
    #-------------------------------------------------
      shade <- setNames(data.frame(matrix(SHADE2(driver_file, Lat, Lon,
        stream_azimuth, bottom_width, BH, BS, WL, TH, overhang, overhang_height),
        ncol = 2)), c("veg_shade", "bank_shade"))

      #Temporary until I figure out the best way to stitch these functions together
        rad_trans$veg_shade <- shade[, "veg_shade"]
        rad_trans$bank_shade <- shade[, "bank_shade"]

    #Calculating weighted mean of irradiance at the stream surface
      PAR_inc <- rad_trans[, "SW_inc"] * 2.114 #Convert incoming to PAR

      rad_trans$PAR_stream <- (rad_trans[, "PAR_bc"] * rad_trans[, "veg_shade"]) +
        (PAR_inc * (1 - rad_trans[, "veg_shade"]))

    #Getting the output
      return(rad_trans)

  } #End stream_light function


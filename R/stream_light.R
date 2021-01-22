#' Model to predict light at the stream surface#'
#' @description A combination of the SHADE2 model (Li et al. 2012) and Campbell &
#' Norman (1998) radiative transfer model
#'
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#' @param channel_azimuth #ADD DETAILS
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
#Last updated 1/15/2021
#===============================================================================
  stream_light <- function(driver_file, Lat, Lon, channel_azimuth, bottom_width, BH, BS, WL, TH, overhang, overhang_height, x_LAD){
    #-------------------------------------------------
    #Defining input parameters
    #-------------------------------------------------
      #Some error catching for SHADE2 input parameters
        if(is.na(overhang)) {overhang <- 0}

        if(overhang == 0) {overhang_height <- TH}
        if(is.na(overhang_height)) {overhang_height <- 0.75 * TH}

    #-------------------------------------------------
    #Add columns to store the data
    #-------------------------------------------------
      #Partition total incoming SW radiation (W m-2) to PAR (umol m-2 s-1)
        driver_file$PAR_inc <- driver_file[, "SW_inc"] * 2.114

      driver_file$PAR_bc <- NA
      driver_file$veg_shade <- NA
      driver_file$bank_shade <- NA
      driver_file$PAR_surface <- NA

    #-------------------------------------------------
    #Defining solar geometry
    #-------------------------------------------------
      solar_geo <- solar_geo_calc(driver_file, Lat, Lon) #PS 2019

      #Generate a logical index of night and day. Night = SZA > 90
        day_index <- solar_geo[, "SZA"] <= (pi * 0.5)
        night_index <- solar_geo[, "SZA"] > (pi * 0.5)

    #-------------------------------------------------
    #Predicting transmission of light through the canopy
    #-------------------------------------------------
      driver_file[day_index, "PAR_bc"] <- RT_CN_1998(driver_file[day_index, ], solar_geo[day_index, ], x_LAD)
      driver_file[night_index, "PAR_bc"] <- 0

    #-------------------------------------------------
    #Running the SHADE2 model
    #-------------------------------------------------
      shade <- setNames(data.frame(matrix(SHADE2(driver_file[day_index, ], solar_geo[day_index, ], Lat, Lon,
        channel_azimuth, bottom_width, BH, BS, WL, TH, overhang, overhang_height),
        ncol = 2)), c("veg_shade", "bank_shade"))

      #Temporary until I figure out the best way to stitch these functions together
        driver_file[day_index, "veg_shade"] <- shade[, "veg_shade"]
        driver_file[day_index, "bank_shade"] <- shade[, "bank_shade"]

    #-------------------------------------------------
    #Calcuating the weighted mean of light reaching the stream surface
    #-------------------------------------------------
      #Calculating weighted mean of irradiance at the stream surface
        driver_file[day_index, "PAR_surface"] <- (driver_file[day_index, "PAR_bc"] * driver_file[day_index, "veg_shade"]) +
          (driver_file[day_index, "PAR_inc"] * (1 - (driver_file[day_index, "veg_shade"] + driver_file[day_index, "bank_shade"])))

        driver_file[night_index, "PAR_surface"] <- 0

    #Getting the output
      return(driver_file)

  } #End stream_light function


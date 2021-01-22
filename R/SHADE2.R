#' SHADE2 model from Li et al. (2012) Modeled riparian stream shading:
#' Agreement with field measurements and sensitivity to riparian conditions
#' @description Translation of shdexe.m
#'
#' @param driver The site driver file
#' @param solar Solar geometry, calculated from solar_geo_calc.R
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#' @param channel_azimuth Channel azimuth
#' @param bottom_width #ADD DETAILS
#' @param BH Bank height
#' @param BS Bank slope
#' @param WL Water level
#' @param overhang Effectively canopy radius
#' @param TH Tree height
#' @param overhang_height height of the maximum canopy overhang (think canopy radius)
#'
#' @return Returns total percent of the wetted width shaded by the bank and by vegetation
#' @export
#===============================================================================
#Running the SHADE2 model from Li et al. (2012) Modeled riparian stream shading:
#Agreement with field measurements and sensitivity to riparian conditions
#Created 3/15/2018
#===============================================================================
  SHADE2 <- function(driver, solar, Lat, Lon, channel_azimuth, bottom_width, BH, BS, WL, TH, overhang, overhang_height){
    #-------------------------------------------------
    #Defining solar geometry
    #-------------------------------------------------
      SHD_solar_geo <- solar_c(driver, solar, Lat, Lon) #PS 2019

      solar_azimuth <- SHD_solar_geo[, "solar_azimuth"]
      solar_altitude <- SHD_solar_geo[, "solar_altitude"]

    #-------------------------------------------------
    #Taking the difference between the sun and stream azimuth (sun-stream)
    #-------------------------------------------------
      #This must be handled correctly to determine if the shadow falls towards the river
      #[sin(delta)>0] or towards the bank
        #Eastern shading
          delta_prime <- solar_azimuth - (channel_azimuth * pi / 180)
          delta_prime[delta_prime < 0] <- pi + abs(delta_prime[delta_prime < 0] )%%(2 * pi) #PS 2019
          delta_east <- delta_prime%%(2 * pi)

        #Western shading
          ifelse(delta_east < pi,delta_west <- delta_east + pi, delta_west <- delta_east - pi)

    #Calculating shade from the "eastern" bank
      eastern_shade <- matrix(ncol = 2, shade_calc(delta_east, solar_altitude, bottom_width,
        BH, BS, WL, TH, overhang, overhang_height))

        east_bank_shade <- eastern_shade[, 1]
        east_veg_shade <- eastern_shade[, 2] #- eastern_shade[, 1] #PS 7/9/2018

    #Calculating shade from the "eastern" bank
      western_shade <- matrix(ncol = 2, shade_calc(delta_west, solar_altitude, bottom_width,
        BH, BS, WL, TH, overhang, overhang_height))

        west_bank_shade <- western_shade[, 1]
        west_veg_shade <- western_shade[, 2] #- western_shade[, 1] #PS 7/9/2018

    #Getting the total amount of vegetation shading, for now I am ignoring bank shading P.S. 2016
      total_veg_shade <- east_veg_shade + west_veg_shade
        total_veg_shade[total_veg_shade > 1] <- 1

      total_bank_shade <- east_bank_shade + west_bank_shade
        total_bank_shade[total_bank_shade > 1] <- 1

    return(c(total_veg_shade, total_bank_shade))

  } #End SHADE2 function

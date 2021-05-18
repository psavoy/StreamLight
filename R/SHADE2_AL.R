#' Modified version of the SHADE2 model
#' @description This is a modified version of the SHADE2 function in this package
#' designed to work with the aqua_light function. The SHADE2 function in this package
#' is based on the original SHADE2 model from Li et al. (2012) Modeled riparian
#' stream shading: Agreement with field measurements and sensitivity to riparian conditions
#'
#' @param driver The site driver file
#' @param solar Solar geometry, calculated from solar_geo_calc.R
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#' @param channel_azimuth Channel azimuth
#' @param bankfull_width Bankfull width (m)
#' @param BH Bank height (m)
#' @param TH Tree height (m)
#' @param overhang Effectively canopy radius
#' @param overhang_height height of the maximum canopy overhang (think canopy radius)
#'
#' @return Returns total percent of the wetted width shaded by the bank and by vegetation
#' @export
#===============================================================================
#Running the SHADE2 model from Li et al. (2012) Modeled riparian stream shading:
#Agreement with field measurements and sensitivity to riparian conditions
#Created 3/2/2021
#===============================================================================
SHADE2_AL <- function(driver, solar, Lat, Lon, channel_azimuth, bankfull_width, BH, TH, overhang, overhang_height){
  #-------------------------------------------------
  #Defining solar geometry
  #-------------------------------------------------
    SHD_solar_geo <- StreamLight::solar_c(
      driver_file = driver,
      solar_geo = solar,
      Lat = Lat,
      Lon = Lon
    ) #PS 2019

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

  #-------------------------------------------------
  #Calculate the length of shading for each bank
  #-------------------------------------------------
    #Temporary solution while I check out these changes
      water_width <- driver[, "width"]

    #Setting widths > bankfull, = bankfull
      water_width[water_width > bankfull_width] <- bankfull_width

    #Calculating shade from the "eastern" bank
      eastern_shade_length <- matrix(ncol = 2,
        shade_calc_AL(
          delta = delta_east,
          solar_altitude = solar_altitude,
          water_width = water_width,
          WL = driver[, "depth"],
          bankfull_width = bankfull_width,
          BH = BH,
          TH = TH,
          overhang = overhang,
          overhang_height = overhang_height
        )
      )

        east_bank_shade_length <- eastern_shade_length[, 1]
        east_veg_shade_length <- eastern_shade_length[, 2] #- eastern_shade[, 1] #PS 7/9/2018


    #Calculating shade from the "eastern" bank
      western_shade_length <- matrix(ncol = 2,
        shade_calc_AL(
          delta = delta_west,
          solar_altitude = solar_altitude,
          water_width = water_width,
          WL = driver[, "depth"],
          bankfull_width = bankfull_width,
          BH = BH,
          TH = TH,
          overhang = overhang,
          overhang_height = overhang_height
        )
      )

        west_bank_shade_length <- western_shade_length[, 1]
        west_veg_shade_length <- western_shade_length[, 2] #- western_shade[, 1] #PS 7/9/2018

  #-------------------------------------------------
  #Calculate the total length of bank shading
  #-------------------------------------------------
    #Calculate the total length of bank shading
      total_bank_shade_length <- east_bank_shade_length + west_bank_shade_length

    #Generate a logical index where the length of bank shading is longer than wetted width
      reset_bank_max_index <- total_bank_shade_length > water_width

    #If total bank shade length is longer than wetted width, set to wetted width
      total_bank_shade_length[reset_bank_max_index] <- water_width[reset_bank_max_index] #PS 2021

  #-------------------------------------------------
  #Calculate the total length of vegetation shading
  #-------------------------------------------------
    #Calculate the total length of vegetation shading
      total_veg_shade_length <- east_veg_shade_length + west_veg_shade_length

    #Generate a logical index where the length of vegetation shading is longer than wetted width
      reset_veg_max_index <- total_veg_shade_length > water_width

    #If total vegetation shade length is longer than wetted width, set to wetted width
      total_veg_shade_length[total_veg_shade_length > water_width] <- water_width[reset_veg_max_index] #PS 2021

  #-------------------------------------------------
  #Calculating the percentage of water that is shaded
  #-------------------------------------------------
    perc_shade_bank <- (total_bank_shade_length) / water_width
      perc_shade_bank[perc_shade_bank > 1] <- 1

    perc_shade_veg <- (total_veg_shade_length - total_bank_shade_length) / water_width
      perc_shade_veg[perc_shade_veg > 1] <- 1

  return(c(perc_shade_veg, perc_shade_bank))

} #End SHADE2_AL function

#' Calculating the percent of the wetted width shaded by banks and vegetation
#' modified for use with aqua_light
#' @description A modified version of the shade_calc function designed to
#' work with the changes reflected in the aqua_light function.
#'
#' @param delta difference between the sun and stream azimuth (sun-stream)
#' @param solar_altitude Solar altitude (radians) calculated by solar_c.R
#' @param water_width Wetted water width
#' @param WL Water level
#' @param bankfull_width Bankfull width
#' @param BH Bank height
#' @param TH Tree height
#' @param overhang Effectively canopy radius
#' @param overhang_height height of the maximum canopy overhang (think canopy radius)
#'
#' @return Returns percent of the wetted width shaded by the bank and by vegetation
#' @export
#===============================================================================
#Calculating the percent of the wetted width shaded by banks and vegetation. Corresponds
#to r_shade in the matlab code
#Created 3/15/2018
#===============================================================================
shade_calc_AL <- function(delta, solar_altitude, water_width, WL, bankfull_width, BH, TH, overhang, overhang_height){
  #Setting widths > bankfull, = bankfull
    water_width[water_width > bankfull_width] <- bankfull_width

  #Setting WL > BH, = BH
    WL[WL > BH] <- BH

  #-------------------------------------------------
  #Calculating the shading produced by the bank
  #-------------------------------------------------
    #Calculating the length of the shadow perpendicular to the bank produced by the bank
      bank_shadow_length <- (1 / tan(solar_altitude)) * (BH - WL) * sin(delta)

    #Finding the amount of exposed bank in the horizontal direction
      exposed_bank <- (bankfull_width - water_width) * 0.5 #PS 2019

    #Finding how much shade falls on the surface of the water
      stream_shade_bank <- bank_shadow_length - exposed_bank
      stream_shade_bank[stream_shade_bank < 0] <- 0

      #If max bank shanding is longer than wetted width, set to width
        stream_shade_bank[stream_shade_bank > water_width] <-
          water_width[stream_shade_bank > water_width] #PS 2020

  #-------------------------------------------------
  #Calculating the shading produced by the Vegetation
  #-------------------------------------------------
    #From top of the tree
      stream_shade_top <- (1 / tan(solar_altitude)) * (TH + BH - WL) * sin(delta) - exposed_bank
        stream_shade_top[stream_shade_top < 0] <- 0

    #From the overhang
      stream_shade_overhang <- (1 / tan(solar_altitude)) * (overhang_height + BH - WL)*
        sin(delta) + overhang - exposed_bank
        stream_shade_overhang[stream_shade_overhang < 0] <- 0

    #Selecting the maximum and minimum
      veg_shade_bound <- matrix(ncol = 2, c(stream_shade_top, stream_shade_overhang))

    #Maximum
    #Note, here I take a departure from the r_shade matlab code. For some reason the code
    #Takes the maximum - min shadow length, but in the paper text it clearly states max
    #See pg 14 Li et al. (2012)
      stream_shade_veg_max <- apply(veg_shade_bound, 1, FUN = max)

      #If the maximum shadow length is longer than the wetted width, set to width
        stream_shade_veg_max[stream_shade_veg_max > water_width] <- water_width[stream_shade_veg_max > water_width] #PS 2020

  return(c(stream_shade_bank, stream_shade_veg_max)) #PS 2021

} #End shade_calc_variable function

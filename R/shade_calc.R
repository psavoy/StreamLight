#' Calculating the percent of the wetted width shaded by banks and vegetation
#' @description Translation of r_shade.m
#'
#' @param delta difference between the sun and stream azimuth (sun-stream)
#' @param solar_altitude Solar altitude (radians) calculated by solar_c.R
#' @param bottom_width #ADD DETAILS
#' @param BH Bank height
#' @param BS Bank slope
#' @param WL Water level
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
  shade_calc <- function(delta, solar_altitude, bottom_width, BH, BS, WL, TH, overhang, overhang_height){
    #-------------------------------------------------
    #Calculating the shading produced by the bank
    #-------------------------------------------------
      #Calculating the length of the shadow perpendicular to the bank produced by the bank
        bank_shadow_length <- (1 / tan(solar_altitude)) * (BH - WL) * sin(delta)

      #Finding the amount of exposed bank in the horizontal direction
        exposed_bank <- (BH - WL) / BS
          #if(BH - WL <= 0 | BS == 0) exposed_bank <- 0 #P.S. , commented this out because
          #I think I assumed that this couldn't be negative even if its confusing to be so

      #Finding how much shade falls on the surface of the water
        stream_shade_bank <- bank_shadow_length - exposed_bank
        stream_shade_bank[stream_shade_bank < 0] <- 0

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
            stream_shade_veg_max[stream_shade_veg_max > bottom_width + WL * (1/BS + 1/BS)] <- bottom_width + WL*(1/BS + 1/BS)

    #-------------------------------------------------
    #Calculating the percentage of water that is shaded
    #-------------------------------------------------
      #Calculating the width of the water surface assuming it is shaped like a trapezoid
        water_width <- bottom_width + WL * (1/BS + 1/BS)

        perc_shade_bank <- (stream_shade_bank) / water_width
          perc_shade_bank[perc_shade_bank > 1] <- 1

        perc_shade_veg <- stream_shade_veg_max / water_width
          perc_shade_veg[perc_shade_veg > 1] <- 1

    return(c(perc_shade_bank, perc_shade_veg))

  } #End shade_calc function

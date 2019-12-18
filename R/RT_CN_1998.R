#' Calculate below canopy PAR
#' @description This function calculates below canopy PAR
#'
#'References
#'#' \itemize{
#'   \item Campbell & Norman (1998) An introduction to Environmental biophysics (abbr C&N (1998))
#'   \item Spitters et al. (1986) Separating the diffuse and direct component of global
#'         radiation and its implications for modeling canopy photosynthesis: Part I
#'         components of incoming radiation
#'   \item Goudriaan (1977)
#' }
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#' @param x_LAD Leaf angle distribution, default = 1
#'
#' @return Returns a time series of below canopy PAR
#' @export
#===============================================================================
#Calculating light transmission through canopies
#===============================================================================
  RT_CN_1998 <- function(driver_file, Lat, Lon, x_LAD, ...){
    #-------------------------------------------------
    #Solar geometry
    #-------------------------------------------------
      #Calculate the solar geometry
        solar_geo <- solar_geo_calc(driver_file, Lat, Lon)

      #Solar zenith angle
        SZA <- solar_geo[, "SZA"]

      #Solar elevation angle
        elev <- solar_geo[, "solar_altitude"]

    #-------------------------------------------------
    #Partitioning incoming shorwave radiation into beam and diffuse components
    #Following Spitters et al. (1986)
    #-------------------------------------------------
      #Calculate the extra-terrestrial irradiance (Spitters et al. (1986) Eq. 1)
        Qo <- 1370 * sin(elev) * (1 + 0.033 * cos(deg2rad(360 * driver_file[, "DOY"] / 365)))

      #The relationship between fraction diffuse and atmospheric transmission
      #Spitters et al. (1986) appendix
        atm_trns <- driver_file[, "SW_inc"] / Qo
        R <- 0.847 - (1.61 * sin(elev)) + (1.04 * sin(elev) * sin(elev))
        K <- (1.47 - R) / 1.66

        #Spitters et al. (1986) Eqs. 20a-20d
          diffuse_calc <- function(atm_trns, R, K){
            if(atm_trns <= 0.22){fdiffuse <- 1.0}
            if(atm_trns > 0.22 & atm_trns <= 0.35){fdiffuse <- 1.0-(6.4 * (atm_trns - 0.22)*(atm_trns - 0.22))}
            if(atm_trns > 0.35 & atm_trns <= K){fdiffuse <- 1.47 - (1.66 * atm_trns)}
            if(atm_trns > K){fdiffuse <- R}
            return(fdiffuse)
          } #End diffuse_calc

        #Calculate the fraction of diffuse radiation
          diff_df <- data.frame(atm_trns, R, K)
          frac_diff <- mapply(diffuse_calc, atm_trns = diff_df[, "atm_trns"],
            R = diff_df[, "R"], K = diff_df[, "K"])

        #Partition into diffuse and beam radiation
          rad_diff <- frac_diff * driver_file[, "SW_inc"] #Diffuse
            rad_beam <- driver_file[, "SW_inc"] - rad_diff #Beam

    #-------------------------------------------------
    #Partition diffuse and beam radiation into PAR following Goudriaan (1977)
    #-------------------------------------------------
      I_od <- 0.5 * rad_diff
      I_ob <- 0.5 * rad_beam

    #-------------------------------------------------
    #Calculating beam radiation transmitted through the canopy
    #-------------------------------------------------
      #Calculate the ratio of projected area to hemi-surface area for an ellipsoid
      #C&N (1998) Eq. 15.4 sensu Campbell (1986)
        kbe <- sqrt((x_LAD ^ 2) + (tan(SZA)) ^ 2)/(x_LAD + (1.774 *
          ((x_LAD + 1.182) ^ -0.733)))

      #Fraction of incident beam radiation penetrating the canopy
      #C&N (1998) Eq. 15.1 and leaf absorptivity as 0.8 (C&N (1998) pg. 255)
      #as per Camp
        tau_b <- exp(-sqrt(0.8) * kbe * driver_file[, "LAI"])

      #Beam radiation transmitted through the canopy
        beam_trans <- I_ob * tau_b

    #-------------------------------------------------
    #Calculating diffuse radiation transmitted through the canopy
    #-------------------------------------------------
      #Function for performing the integration
        integ_func <- function(angle, d_SZA, x_LAD, LAI){
          exp(-(sqrt((x_LAD ^ 2) + (tan(angle)) ^ 2)/(x_LAD + (1.774 *
            ((x_LAD + 1.182) ^ -0.733)))) * LAI) * sin(angle) * cos(angle) * d_SZA
        } #End integ_func

      #Function to calculate the diffuse transmission coefficient
        dt_calc <- function(LAI, ...){
          #Create a sequence of angles to integrate over
            angle_seq <- deg2rad(seq(from = 0, to = 89, by = 1))

          #Numerical integration
            d_SZA <- (pi / 2) / length(angle_seq)

          #Diffuse transmission coefficient for the canopy (C&N (1998) Eq. 15.5)
            result <- 2 * sum(integ_func(angle_seq[1:length(angle_seq)], d_SZA, x_LAD = 1,
              LAI = LAI))

          return(result)
        } #End dt_calc function

      #Diffuse transmission coefficient for the canopy (C&N (1998) Eq. 15.5)
        tau_d <- sapply(driver_file[, "LAI"], FUN = dt_calc)

      #Extinction coefficient for black leaves in diffuse radiation
        Kd <- -log(tau_d) / driver_file[, "LAI"]

      #Diffuse radiation transmitted through the canopy
        diff_trans <- I_od * exp(-sqrt(0.8) * Kd * driver_file[, "LAI"])

    #Get the total light transmitted through the canopy
      transmitted <- beam_trans + diff_trans
      PPFD <- transmitted * 1/0.235 #Convert from W m-2 to umol m-2 s-1
      return(PPFD)

  } #End RT_CN_1998 function

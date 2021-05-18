#' Model to predict photosynthetically active radiation at the benthic surface.
#' @description This function builds on the stream_light function by adding in
#' several key components. First, it makes some modifications to allow better
#' handling of dynamic wetted widths. Secondly, it moves beyond making predictions
#' at the stream surface and includes the influence of surface reflection and
#' attenuation as a function of depth and clarity to predict PAR at the benthic
#' surface. Note that aqua_light will still output estimates of PAR at the
#' stream surface denoted by the column "PAR_surface".
#'
#' @param driver_file The model driver file
#' @param Lat The site Latitude
#' @param Lon The site Longitude
#' @param channel_azimuth Channel azimuth
#' @param bankfull_width Bankfull width
#' @param BH Bank height
#' @param WL Water level
#' @param TH Tree height
#' @param overhang Effectively canopy radius
#' @param overhang_height height of the maximum canopy overhang (think canopy radius)
#' @param x_LAD Leaf angle distribution, default = 1
#'
#' @return Returns a time series of predicted photosynthetically active radiation
#' @export
#===============================================================================
#Function for predicting light at the stream surface
#===============================================================================
aqua_light <- function(driver_file, Lat, Lon, channel_azimuth, bankfull_width, BH, TH, overhang, overhang_height, x_LAD){
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
    solar_geo <- solar_geo_calc(
      driver_file = driver_file,
      Lat = Lat,
      Lon = Lon
    ) #PS 2019

    #Generate a logical index of night and day. Night = SZA > 90
      day_index <- solar_geo[, "SZA"] <= (pi * 0.5)
      night_index <- solar_geo[, "SZA"] > (pi * 0.5)

  #-------------------------------------------------
  #Predicting transmission of light through the canopy
  #-------------------------------------------------
    driver_file[day_index, "PAR_bc"] <- RT_CN_1998(
      driver_file = driver_file[day_index, ],
      solar_geo = solar_geo[day_index, ],
      x_LAD = x_LAD
    )

  #-------------------------------------------------
  #Generate a logical index where there is depth
  #-------------------------------------------------
    is_depth <- !is.na(driver_file[, "depth"]) #PS 2021
    no_depth <- is.na(driver_file[, "depth"]) #PS 2020

    #Generate a logical index where I should use the dynamic light model
      dynamic_index <- day_index == TRUE & is_depth == TRUE
      static_index <- day_index == TRUE & no_depth == TRUE

  #-------------------------------------------------
  #Running the SHADE2 model during the daytime
  #-------------------------------------------------
    #Dynamic version of the model (changing width and depth)
      shade_disch <- setNames(data.frame(matrix(
        SHADE2_AL(
          driver = driver_file[dynamic_index, ],
          solar = solar_geo[dynamic_index, ],
          Lat = Lat,
          Lon = Lon,
          channel_azimuth = channel_azimuth,
          bankfull_width = bankfull_width,
          BH = BH,
          TH = TH,
          overhang = overhang,
          overhang_height = overhang_height
        ),
        ncol = 2)), c("veg_shade", "bank_shade")
      )

      #Temporary until I figure out the best way to stitch these functions together
        driver_file[dynamic_index, "veg_shade"] <- shade_disch[, "veg_shade"]
        driver_file[dynamic_index, "bank_shade"] <- shade_disch[, "bank_shade"]

    #Run the static model for days without dynamic width/depth
      if(sum(static_index != 0)){
        shade_static <- setNames(data.frame(matrix(
          SHADE2(
            driver = driver_file[static_index, ],
            solar = solar_geo[static_index, ],
            Lat = Lat,
            Lon = Lon,
            channel_azimuth = channel_azimuth,
            bottom_width = bankfull_width,
            BH = BH,
            BS = 100,
            WL = BH,
            TH = TH,
            overhang = overhang,
            overhang_height = overhang_height
          ),
          ncol = 2)), c("veg_shade", "bank_shade")
        )

        #Temporary until I figure out the best way to stitch these functions together
          driver_file[static_index, "veg_shade"] <- shade_static[, "veg_shade"]
          driver_file[static_index, "bank_shade"] <- shade_static[, "bank_shade"]

      } #End if statement

  #-------------------------------------------------
  #Calcuating the weighted mean of light reaching the stream surface
  #-------------------------------------------------
    #Calculating weighted mean of irradiance at the stream surface
      driver_file[day_index, "PAR_surface"] <- (driver_file[day_index, "PAR_bc"] * driver_file[day_index, "veg_shade"]) +
        (driver_file[day_index, "PAR_inc"] * (1 - (driver_file[day_index, "veg_shade"] + driver_file[day_index, "bank_shade"])))

  #-------------------------------------------------
  #Calculating light just below the surface (water surface reflection)
  #-------------------------------------------------
    driver_file$PAR_subsurface <- NA

    driver_file[day_index, "PAR_subsurface"] <- surface_reflection(driver_file[day_index, ], solar_geo[day_index, ])

  #-------------------------------------------------
  #Calculating attenuation from pure water
  #-------------------------------------------------
    driver_file$PAR_water <- NA
    #driver_file$kd_water <- NA

    #Mean absorption coefficient for pure water derived from
    #Pope & Fry 1997 Absorption spectrum ~380–700 nm! of pure water. II. Integrating cavity measurements
      water_absorption <- absorption(driver_file[dynamic_index, ], absorb_coef = 0.1521645)

      driver_file[dynamic_index, "PAR_water"] <- water_absorption[, "PAR_wc"]
      driver_file[dynamic_index, "kd_water"] <- water_absorption[, "kd"] #Future removal?

  #-------------------------------------------------
  #Calculating attenuation (based on empirical relation between kd and turbidity)
  #-------------------------------------------------
    driver_file$PAR_turb <- NA
    driver_file$kd_turb <- NA

    #Generate a logical index where I should use the dynamic light model with turbidity
      is_kd_pred <- !is.na(driver_file[, "kd_pred"]) #PS 2020
      kd_pred_index <- day_index == TRUE & is_depth == TRUE & is_kd_pred == TRUE

    #Calculate light transmission as influenced by turbidity
      transmission_estimates <- predict_transmission(driver_file[kd_pred_index, ])

      driver_file[kd_pred_index, "PAR_turb"] <- transmission_estimates[, "PAR_turb"]
      driver_file[kd_pred_index, "kd_turb"] <- transmission_estimates[, "kd"] #Future removal

  #Getting the output
    return(driver_file)

} #End aqua_light function


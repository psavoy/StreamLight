#' Generates rough graphs and daily summaries of model outputs
#' @description This function calculates daily mean (umol m-2 s-1) or total (kmol m-2 d-1)
#' incoming and predicted light
#'
#' @param pred_dir The read directory where model predictions are located, "C:/
#' @param Site The Site_ID
#' @param plot Logical indicator. If plot = TRUE, then a timeseries of total daily
#' light is plotted (mol m-2 d-1) for both incoming and predicted light
#' @param return Logical indicator. If return = TRUE, then return a data frame
#' containing daily means and sums of both incoming and predicted light
#'
#' @return Returns daily mean (umol m-2 s-1) and total (kmol m-2 d-1) incoming and
#' predicted light
#'
#' @export

#===============================================================================
#Function to plot daily model estimates
#Created 6/13/2019
#===============================================================================
  daily_light <- function(pred_dir, Site, plot, return){
    #Read in predicted
      setwd(pred_dir)
      pred <- readRDS(paste(Site, "_predicted.rds", sep = ""))

    #Partition total incoming SW radiation (W m-2) to PAR (umol m-2 s-1)
      pred$PAR_inc <- pred[, "SW_inc"] * 2.114

    #-------------------------------------------------
    #Finding only days with complete coverage
    #-------------------------------------------------
      #Find out the timestep
        timestep <- length(unique(pred[, "Hour"]))

      #Number of observations per day
        pred_count <- setNames(plyr::count(na.omit(pred[, "jday"])), c("jday", "count"))

      #Days with complete observations
        days_comp <- pred_count[pred_count[, "count"] == timestep, "jday"]

      #Subsetting for only days that have complete observations
        complete <- pred[pred[, "jday"] %in% days_comp, ]

    #-------------------------------------------------
    #Daily summary
    #-------------------------------------------------
      #Calculate as a daily mean
        daily_mean <- aggregate(cbind(PAR_inc, PAR_stream, LAI) ~ jday + Year + DOY,
          data = complete, FUN = mean)

          colnames(daily_mean)[4:6] <- c("Inc_mean", "Pred_mean", "LAI")

      #Calculate as daily sum
        #Convert to mol m-2 h-1
          complete$PAR_inc_mol <- complete[, "PAR_inc"] * 60 * 60 / 1000000
          complete$PAR_stream_mol <- complete[, "PAR_stream"] * 60 * 60 / 1000000

        #Aggregate to daily sums (mol m-2 d-1)
          daily_sum <- aggregate(cbind(PAR_inc_mol, PAR_stream_mol) ~ jday + Year + DOY,
            data = complete, FUN = sum)

            colnames(daily_sum)[4:5] <- c("Inc_sum", "Pred_sum")

      #Merging together the mean and sum
        merged <- na.omit(merge(daily_mean, daily_sum, by = c("jday", "Year", "DOY")))

      #Ordering the data
        ordered <- merged[order(merged[, "Year"], merged[, "DOY"]), ]

      #Adding in a date column
        ordered$Date <-  as.Date(paste(ordered[, "Year"], "-", ordered[, "DOY"],
          sep = ""), format = "%Y-%j")

    #-------------------------------------------------
    #Plotting data when plot == "TRUE"
    #-------------------------------------------------
      if(plot == TRUE){
        par(mar = c(4, 5, 0.5, 2), oma = c(0, 0, 1, 0.5))

        plot(ordered[, "Date"], ordered[, "Inc_sum"], pch = 20, col = "grey60",
          ylim = c(0, 80), ylab = "", xlab = "")

        points(ordered[, "Date"], ordered[, "Pred_sum"], pch = 20,
          col = "darkorange")

        #Add graphical elements
          mtext(side = 1, "Date", line = 2)
          mtext(side = 2, expression(paste("PAR ", "(kmol"," m"^{-2},
            "d"^{-1},")")), line = 2)
          mtext(side = 3, Site, line = -1.5, adj = 0.05)

          legend("topright", inset(0.2, 0.2), ncol = 2,
            xpd = TRUE, c("Incoming", "Predicted"), bty = "n", pch = c(20, 20),
            col = c("grey60", "darkorange"))
      } #End if statement

    #Get the final output
      final <- ordered[, c("Date", "jday", "Year", "DOY", "Inc_mean", "Pred_mean",
        "Inc_sum", "Pred_sum", "LAI")]

    #Return data
      if(return == TRUE){return(final)}

  } #End

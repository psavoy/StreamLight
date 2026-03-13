# Helper function for determining the correct solar azimuth

This function feeds into the solar_c function and is used to help
determine the correct solar azimuth for locations where latitude is
greater than the solar declination angle. Based on the original solarC.m
matlab code.

## Usage

``` r
azimuth_adj(driver_file, Lat, Lon)
```

## Arguments

- driver_file:

  The model driver file

- Lat:

  The site Latitude

- Lon:

  The site Longitude

## Value

Returns an estimate of azimuth for the current timestep + 1 minute.

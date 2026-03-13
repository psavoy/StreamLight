# Calculates solar geometry

This function calculates solar declination, altitude, zenith angle, and
an initial estimate of azimuth. This initial estimate of solar azimuth
is passed to the solar_c function where it is adjusted based on latitude
and the solar declination angle. This code is based on the original
solarC.m matlab code.

## Usage

``` r
solar_geo_calc(driver_file, Lat, Lon)
```

## Arguments

- driver_file:

  The model driver file

- Lat:

  The site Latitude

- Lon:

  The site Longitude

## Value

Returns solar declination, altitude, zenith angle, and an initial
estimate of azimuth

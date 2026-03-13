# Calculates solar geometry for use in the SHADE2 model

Translation of solarC.m

## Usage

``` r
solar_c(driver_file, solar_geo, Lat, Lon, ...)
```

## Arguments

- driver_file:

  The model driver file

- solar_geo:

  Solar geometry, calculated from solar_geo_calc.R

- Lat:

  The site Latitude

- Lon:

  The site Longitude

## Value

Returns solar altitude, azimuth, and declination

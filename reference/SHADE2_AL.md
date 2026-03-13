# Modified version of the SHADE2 model

This is a modified version of the SHADE2 function in this package
designed to work with the aqua_light function. The SHADE2 function in
this package is based on the original SHADE2 model from Li et al. (2012)
Modeled riparian stream shading: Agreement with field measurements and
sensitivity to riparian conditions

## Usage

``` r
SHADE2_AL(
  driver,
  solar,
  Lat,
  Lon,
  channel_azimuth,
  bankfull_width,
  BH,
  TH,
  overhang,
  overhang_height
)
```

## Arguments

- driver:

  The site driver file

- solar:

  Solar geometry, calculated from solar_geo_calc.R

- Lat:

  The site Latitude

- Lon:

  The site Longitude

- channel_azimuth:

  Channel azimuth

- bankfull_width:

  Bankfull width (m)

- BH:

  Bank height (m)

- TH:

  Tree height (m)

- overhang:

  Effectively canopy radius

- overhang_height:

  height of the maximum canopy overhang (think canopy radius)

## Value

Returns total percent of the wetted width shaded by the bank and by
vegetation

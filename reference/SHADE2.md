# SHADE2 model from Li et al. (2012) Modeled riparian stream shading: Agreement with field measurements and sensitivity to riparian conditions

Translation of shdexe.m

## Usage

``` r
SHADE2(
  driver,
  solar,
  Lat,
  Lon,
  channel_azimuth,
  bottom_width,
  BH,
  BS,
  WL,
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

- bottom_width:

  \#ADD DETAILS

- BH:

  Bank height

- BS:

  Bank slope

- WL:

  Water level

- TH:

  Tree height

- overhang:

  Effectively canopy radius

- overhang_height:

  height of the maximum canopy overhang (think canopy radius)

## Value

Returns total percent of the wetted width shaded by the bank and by
vegetation

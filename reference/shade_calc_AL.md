# Calculating the percent of the wetted width shaded by banks and vegetation modified for use with aqua_light

A modified version of the shade_calc function designed to work with the
changes reflected in the aqua_light function.

## Usage

``` r
shade_calc_AL(
  delta,
  solar_altitude,
  water_width,
  WL,
  bankfull_width,
  BH,
  TH,
  overhang,
  overhang_height
)
```

## Arguments

- delta:

  difference between the sun and stream azimuth (sun-stream)

- solar_altitude:

  Solar altitude (radians) calculated by solar_c.R

- water_width:

  Wetted water width

- WL:

  Water level

- bankfull_width:

  Bankfull width

- BH:

  Bank height

- TH:

  Tree height

- overhang:

  Effectively canopy radius

- overhang_height:

  height of the maximum canopy overhang (think canopy radius)

## Value

Returns percent of the wetted width shaded by the bank and by vegetation

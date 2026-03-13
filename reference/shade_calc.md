# Calculating the percent of the wetted width shaded by banks and vegetation

Translation of r_shade.m

## Usage

``` r
shade_calc(
  delta,
  solar_altitude,
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

- delta:

  difference between the sun and stream azimuth (sun-stream)

- solar_altitude:

  Solar altitude (radians) calculated by solar_c.R

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

Returns percent of the wetted width shaded by the bank and by vegetation

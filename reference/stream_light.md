# Model to predict light at the stream surface

A combination of the SHADE2 model (Li et al. 2012) and Campbell & Norman
(1998) radiative transfer model

## Usage

``` r
stream_light(
  driver_file,
  Lat,
  Lon,
  channel_azimuth,
  bottom_width,
  BH,
  BS,
  WL,
  TH,
  overhang,
  overhang_height,
  x_LAD
)
```

## Arguments

- driver_file:

  The model driver file

- Lat:

  The site Latitude

- Lon:

  The site Longitude

- channel_azimuth:

  \#ADD DETAILS

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

- x_LAD:

  Leaf angle distribution, default = 1

## Value

Returns a time series of predicted light at the stream surface

# Model to predict photosynthetically active radiation at the benthic surface.

This function builds on the stream_light function by adding in several
key components. First, it makes some modifications to allow better
handling of dynamic wetted widths. Secondly, it moves beyond making
predictions at the stream surface and includes the influence of surface
reflection and attenuation as a function of depth and clarity to predict
PAR at the benthic surface. Note that aqua_light will still output
estimates of PAR at the stream surface denoted by the column
"PAR_surface".

## Usage

``` r
aqua_light(
  driver_file,
  Lat,
  Lon,
  channel_azimuth,
  bankfull_width,
  BH,
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

  Channel azimuth

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

- x_LAD:

  Leaf angle distribution, default = 1

- WL:

  Water level

## Value

Returns a time series of predicted photosynthetically active radiation

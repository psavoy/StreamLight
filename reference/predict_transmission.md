# Calculate light transmission as a function of depth and and the irradiance attenuation coefficient

Calculates transmission of light in the water as a function of depth and
the irradiance attenuation coefficient (Kd). The decision of how to
produce a timeseries of Kd is left to the user based on their interests
and available data. An empirical relationship to estimate Kd from
turbidity is presented in the model documentation and associated
publication.

## Usage

``` r
predict_transmission(driver)
```

## Arguments

- driver:

  The site driver file

## Value

Returns a dataframe of predicted light at the benthic surface

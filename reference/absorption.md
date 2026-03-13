# Calculate light absorption in pure water

Calculates light absorption as a function of depth in clear water, using
the mean absorption coefficient for pure water derived from Pope & Fry
1997 Absorption spectrum ~380–700 nm of pure water. II. Integrating
cavity measurements. Effectively, this assumes that attenuation is
solely a function of absorption from pure water. In other words, the
irradiance attenuation coefficient (Kd) will be equal to just the
absorption coefficient for pure water.

## Usage

``` r
absorption(driver, absorb_coef = 0.1521645)
```

## Arguments

- driver:

  The site driver file

- absorb_coef:

  Absorption coefficient of clear water. Defaults to the value derived
  from Pope & Fry (1997) as explained above (absorb_coef = 0.1521645).

## Value

Returns a dataframe of predicted light at the benthic surface and the
irradiance attenuation coefficient.

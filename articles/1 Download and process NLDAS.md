# 1. Download and process NLDAS

## Introduction

This article describes downloading and processing total incoming
shortwave radiation (W m⁻²) using the **StreamLightUtils** package.
Total incoming shortwave radiation (W m⁻²) is provided by the National
Land Data Assimilation System (NLDAS) at hourly timesteps at 0.125
degree spatial resolution. There are two potential workflows available:
1.) download data for a single site, and 2.) bulk download of data for
many sites.

### Earthdata login

Previously, this packaged used the NASA data rods service to download
NLDAS data. However, this service has been retired and a new workflow is
required.

**Downloading NLDAS data now requires an Earthdata login.** If you do
not already have an account, you can [register for a new Earthdata
account](https://urs.earthdata.nasa.gov/users/new). Once you have an
account, you may [login to your
account](https://urs.earthdata.nasa.gov/). From your account page, click
on the “generate token” tab and paste the token string into a txt file
and save it somewhere locally as token.txt. **Note** please be careful
where you save this token and make sure not to accidentally include it
in projects that are managed on places like GitHub. Unfortunately, you
will have to generate a new token every 60 days as they expire.

You can then read the access token into R, modifying to reflect the path
where your token is saved.

``` r
#Read in Earthdata access token
  access_token <- readLines("<path_to_token>/token.txt")
```

### 1. Downloading and processing NLDAS data for a single site

Incoming shortwave radiation data at a single site can be downloaded
using the function **nldas_get** which has the following structure:

**nldas_get**(*Site_ID*, *Lat*, *Lon*, *startDate*, *endDate*,
*access_token*, *save_dir*, )

- *Site_ID* The site identifier (“Site_ID”)
- *Lat* The site latitude
- *Lon* The site longitude
- *startDate* The starting date for the downloaded data (“YYYY-MM-DD”)
- *endDate* The ending date for the downloaded data (“YYYY-MM-DD”).
  Default is the current date via Sys.Date()
- *access_token* An Earthdata access token. Requires an Earthdata
  profile to generate the token.
- *save_dir* The save directory for the downloaded data to be placed in.
  For example, “C:/”

During the download some light formatting is done to extract relevant
date and time information. The downloaded data can then be prepped for
creating a model driver file by using the function **nldas_prep** which
has the following structure:

**nldas_prep**(*read_dir*, *write_output*, *save_dir*)

- *read_dir* The directory containing the downloaded NLDAS data.
- *write_output* A logical value indicating whether the output should be
  written to disk (write_output = TRUE) or returned to the R environment
  (write_output = FALSE). The default value is FALSE since for most
  datasets this is a suitable approach; however, for very large datasets
  (thousands of sites) it may be easier to write files to disk instead
  of storing them in the workspace.
- *save_dir* An optional parameter to use only when write_output = TRUE
  that indicates the save directory for files to be placed in. For
  example, “C:/”.

Note, the **nldas_prep** is only creating a named list of all downloaded
NLDAS data, where the names are the site ids. This is done to faciliate
the later steps of creating a model driver file.

``` r
library("StreamLightUtils")
    
#Download NLDAS data at NC_NHC
  nldas_get(
    Site_ID = "NC_NHC",
    Lat = 35.9925, 
    Lon = -79.0460,     
    startDate = "2022-01-01",
    endDate = "2024-12-31",
    access_token = access_token,
    save_dir = here::here("data", "nldas")
  )
  
#Prep the downloaded NLDAS data for creating a model driver file
  nldas_prepped <- nldas_prep(
    read_dir = here::here("data", "nldas")
  )
```

### 2. Downloading and processing NLDAS data for multiple sites

Incoming shortwave radiation data at multiple sites can be downloaded
using the function **nldas_get_bulk** which has the following structure:

**nldas_get_bulk**(*site_locs*, *startDate*, *endDate*, *access_token*,
*save_dir*, )

- *site_locs* A table with Site_ID, Lat, and Lon, and optionally
  startDate and endDate.
- *startDate* An optional parameter. By default, if nothing is provided
  the function assumes that site_locs has a column that contains
  startDate. Alternatively, a single startDate can be provided as an
  argument for the download (YYYY-MM-DD).
- *endDate* An optional parameter. By default, if nothing is provided
  the function assumes that site_locs has a column that contains
  endDate. Alternatively, a single endDate can be provided as an
  argument for the download (YYYY-MM-DD).
- *access_token* An Earthdata access token. Requires an Earthdata
  profile to generate the token.
- *save_dir* The save directory for the downloaded data to be placed in.
  For example, “C:/”.

This function can essentially be used in two ways: 1.) you can specify
arguments of startDate and endDate, which may be helpful if you want to
download the same timeframe of data for all sites, or 2.) specify
columns of startDate and endDate in the file you pass for site_locs,
which could be helpful if you want different timeframes of data for each
site.

If data fails to download for a site, the **nldas_get_bulk** function
will automatically check and retry downloading data for all sites with
missing data. However, it is possible that data does not exist for a
site. Consequently, it is prudent to confirm the successfully downloaded
sites.

``` r
#Read in a table with initial site information
  data("NC_params", package = "StreamLight") 
  sites <- NC_params

#Download NLDAS data at NC_NHC
  nldas_get_bulk(
    site_locs = sites,
    startDate = "2022-01-01",
    endDate = "2024-12-31",
    access_token = access_token,
    save_dir = here::here("data", "nldas")
  )

#Prep the downloaded NLDAS data for creating a model driver file
  nldas_prepped <- nldas_prep(
    read_dir = here::here("data", "nldas")
  )
```

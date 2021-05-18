# 1. Introduction

The **StreamLight** package contains two primary functions for predicting photosynthetically active radiation (PAR) for rivers and streams:

1. The **<span style="color:DarkOrange">stream_light</span>** function predicts PAR at the water surface as a function of channel geometry, riparian vegetation canopy structure and phenology, and sun-earth geometry.
2. The **<span style="color:DarkOrange">aqua_light</span>** function predicts PAR at the benthic surface. The **<span style="color:DarkOrange">aqua_light</span>** function builds on the **<span style="color:DarkOrange">stream_light</span>** function by allowing for dynamic changes in water width and depth, as well as for accounting for reflection from the water surface and attenuation within the water column as a function of depth and clarity.

**Usage:** If you use the **StreamLight** package in your research please cite this package. To see the suggested citation for this package, run citation("StreamLight") in the R prompt. Additionally, please cite the appropriate manuscript associated with the function you used:

- **<span style="color:DarkOrange">stream_light</span>**  function
  - Savoy, P., Bernhardt, E., Kirk, L., Cohen, M. J., & Heffernan, J. B. (2021). A seasonally dynamic model of light at the stream surface. Freshwater Science, 40(April), 000–000. https://doi.org/10.1086/714270
- **<span style="color:DarkOrange">aqua_light</span>**  function
  - Savoy, P., & Harvey, J. W. (2021). Predicting light regime controls on primary productivity across CONUS river networks. Geophysical Research Letters, 48, e2020GL092149. https://doi.org/10.1029/2020GL092149

**Package support:** Development of the **StreamLight** package has been supported by a National Science Foundation (NSF) Macrosystem Program Grant (#EF 1442439) and by the USGS Water Availability and Use Science Program.

# 2. Reference articles

See the full [**StreamLight** documentation](https://psavoy.github.io/StreamLight/) for individual articles on how to use the package. The documentation page contains a number of articles that detail the usage of the **StreamLight** and **StreamLightUtils** packages. Throughout these articles some terms are emphasized using the below key. 

**Key**

- **packages**
- **<span style="color:DarkOrange">functions</span>**
- *<span style="color:#009faf">function arguments</span>*
- **<span style="color:#009688">"column names"</span>**

Individual articles go into depth on each of the following subjects.

**Outline**

1. **Download and process NLDAS incoming shortwave radiation**

   Covers downloading and processing National Land Data Assimilation System (NLDAS) total incoming shortwave radiation (W m<sup>-2</sup>) using the **StreamLightUtils** package.

2. **Download and process MODIS LAI**

   Covers downloading and processing MODIS leaf area index (LAI, m<sup>2</sup> m<sup>-2</sup>) using the **StreamLightUtils** package.

3. **Using <span style="color:DarkOrange">stream_light</span>**

   Covers the creation of driver files, a parameter file, and running **<span style="color:DarkOrange">stream_light</span>**.  

4. **Using <span style="color:DarkOrange">aqua_light</span>**

   Covers the creation of driver files, a parameter file, and running **<span style="color:DarkOrange">aqua_light</span>**.  

# 3. Getting started

For convenience, a series of functions have been included in the companion package **StreamLightUtils** to derive some of the values required for parameter files and to create standardized driver files for use with **StreamLight**. Where possible, remotely sensed data products with good broadscale coverage are used to derive these inputs within **StreamLightUtils**. There are of course many potential sources for similar data that could be used to create driver files and users are welcome to create their own workflow for creating driver or parameter files. 

For first time installation run the following code:

```R
#Install the devtools package if you do not already have it   
  install.packages("devtools")

#Use the devtools packge to install StreamLightUtils
  devtools::install_github("psavoy/StreamLightUtils")
  devtools::install_github("psavoy/StreamLight")
```

Before beginning, Load the **StreamLightUtils** and **StreamLight** libraries.

```R
library("StreamLightUtils")
library("StreamLight")
```









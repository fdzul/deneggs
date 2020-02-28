# **deneggs**

[![Build Status](https://travis-ci.org/pages-themes/cayman.svg?branch=master)](https://travis-ci.org/pages-themes/cayman) [![Gem Version](https://badge.fury.io/rb/jekyll-theme-cayman.svg)](https://badge.fury.io/rb/jekyll-theme-cayman)

*deneggs is a package It is a package developed in the department of prevention and control of diseases transmitted by vector of the Secretary of Health of Veracruz [Secretary of Health of Veracruz](https://www.ssaver.gob.mx/) and with Authorization of the federal level. (#usage).*


## **overview**

**deneggs** is a package to generate predictive maps of the number of eggs or adults in areas where it is not collected.The predictive maps are generated using geostatistical analysis in the [INLA](http://www.r-inla.org/) framework. 

  - `**spde_pred_map**()` generate the predictive map.
  - `eggs_map()` generates an entomological risk map or an egg density map.
  - `loc_grid_points()` It is a complementary function that helps in the creation of grid of the locality in the prediction stack in [INLA](http://www.r-inla.org/).
  - `mesh()` It is a complementary function that helps in the creation of mesh.

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)
* [Features](#features)
* [Status](#status)
* [Inspiration](#inspiration)
* [Contact](#contact)


## Instalation

``` r
# The easiest way to get dplyr is to install the whole tidyverse:
install.packages("deneggs")
```

### Development version

To get a bug fix, or use a feature from the development version, you can
install deneggs from GitHub.

``` r
# install.packages("devtools")
devtools::install_github("fdzul/deneggs")
``` 

## Inspiration
Add here credits. Project inspired by..., based on...

## Getting help

If you encounter a clear bug, please file a minimal reproducible example
on [github](https://github.com/fdzul/deneggs/issues). For questions
and other discussion, please use 

-----

Please note that this project is released with a [Contributor Code of
Conduct](https://dplyr.tidyverse.org/CODE_OF_CONDUCT). By participating
in this project you agree to abide by its terms.

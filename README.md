
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **deneggs**

[![Build
Status](https://travis-ci.org/pages-themes/cayman.svg?branch=master)](https://travis-ci.org/pages-themes/cayman)
[![Gem
Version](https://badge.fury.io/rb/jekyll-theme-cayman.svg)](https://badge.fury.io/rb/jekyll-theme-cayman)[![Github
All
Releases](https://img.shields.io/github/downloads/fdzul/deneggs/total.svg)]()
[![Netlify
Status](https://api.netlify.com/api/v1/badges/ce21544b-5fef-4761-9103-70b483e2907f/deploy-status)](https://app.netlify.com/sites/dancing-tiramisu-fdd5c0/deploys)

# deneggs <img src="man/figures/logo.png" align="right" height="139" alt="" />

The **deneggs** package was developed by the
[CENAPRECE](https://www.gob.mx/salud/cenaprece) dengue prevention and
control program in collaboration with
[INDRE](https://www.gob.mx/salud/acciones-y-programas/instituto-de-diagnostico-y-referencia-epidemiologicos-mision-vision-y-politica-de-calidad-181639?state=published)
(Entomology Laboratory), [INSP](https://www.insp.mx) (Health Systems
Research Center & Population Health Research Center), and the states of
Veracruz, Tabasco, and Yucatan.

## **Overview**

The **deneggs** package was designed to generate predictive maps of the
number of eggs or adults through geostatistical analysis using
stochastic partial differential equations (SPDE) and integrated nested
Laplace with [R-INLA](http://www.r-inla.org/). The objective of
geostatistical analysis is to predict the response variable (eggs or
adults) in areas or zones where entomological collection was not carried
out, such as unsampled blocks.

Geostatistical analysis of entomological surveillance with ovitraps and
adult collections was performed using the **deneggs** package. The
package is part of dengueverse and has three functions for predicting
the number of eggs in areas where they were not collected from a
location.

- **`spde_pred_map`**

- **`eggs_hotspots`**

- **`eggs_hotspots_week`**

The spde_pred_map function performs geostatistical analysis per week
with seven different distributions (poisson, zeroinflatedpoisson0,
zeroinflatedpoisson1, nbinomial, nbinomial2, zeroinflatednbinomial0, &
zeroinflatednbinomial1). The eggs_hotspots function performed the
analysis per week with only one distribution, and the eggs_hotspots_week
function performed the analysis for all weeks of the year.

In addition, the denegg package has complementary functions associated
with geostatistical analysis.

## Instalation

### Development version

To get a bug fix, or use a feature from the development version, you can
install deneggs from GitHub. For an in-depth review of all the features,
please refer to the reference section.

devtools

``` r
# install.packages("devtools")
devtools::install_github("fdzul/deneggs")
```

pak

``` r
# install.packages("pak")
pak::pkg_install("fdzul/deneggs")
```

## Authors

List of [contributors](https://github.com/fdzul/deneggs/contributors)
who participated in this project.

## License

This project is licensed under the MIT License - see the
[LICENSE.md](LICENSE.md) file for details

## Inspiration

The package was inspired by the need to contribute to making decisions
in the dengue prevention and control program, specifically to identify
dengue vector hotspots and use the entomological information generated
by the program.

## Getting help

If you encounter a clear bug, please file a minimal reproducible example
on [github](https://github.com/fdzul/deneggs/issues). For questions and
other discussion, please feel free to contact me
(<felipe.dzul.m@gmail.com>)

------------------------------------------------------------------------

Please note that this project is released with a [Contributor Code of
Conduct](https://dplyr.tidyverse.org/CODE_OF_CONDUCT). By participating
in this project you agree to abide by its terms.

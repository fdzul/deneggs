
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **deneggs**

[![Build
Status](https://travis-ci.org/pages-themes/cayman.svg?branch=master)](https://travis-ci.org/pages-themes/cayman)
[![Gem
Version](https://badge.fury.io/rb/jekyll-theme-cayman.svg)](https://badge.fury.io/rb/jekyll-theme-cayman)[![Github
All
Releases](https://img.shields.io/github/downloads/fdzul/deneggs/total.svg)]()

**deneggs is a package developed in the department of prevention and
control of diseases transmitted by vector of the [Secretary of Health of
Veracruz](https://www.ssaver.gob.mx/) and with colaboration of the
[CENAPRECE](https://www.gob.mx/salud/cenaprece)**

## **overview**

**deneggs** is a package to generate predictive maps of the number of
eggs or adults in areas where it is not collected.The predictive maps
are generated using geostatistical analysis in the
[INLA](http://www.r-inla.org/) framework.

-   **`deneggs::spde_pred_map()`** generate the predictive mapand
    calculate the hotspots. Run the models with six distributions.
-   **`deneggs::eggs_hotspots()`** generate the predictive map and
    calculate the hotspots. Run the model with one distribution.
-   **`deneggs::animap_vector_hotblocks()`** generate the animated map
    of hotblocks of eggs abundance.
-   **`deneggs::ovitraps_read()`** reads current ovitramp databases and
    historical.
-   **`deneggs::eggs_map()`** generates an entomological risk map or an
    egg density map.
-   **`deneggs::loc_grid_points()`** It is a complementary function that
    helps in the creation of grid of the locality in the prediction
    stack in [INLA](http://www.r-inla.org/).
-   **`mesh()`** It is a complementary function that helps in the
    creation of mesh.

## Instalation

``` r
# The easiest way to get deneggs is to install:
install.packages("deneggs")
```

### Development version

To get a bug fix, or use a feature from the development version, you can
install deneggs from GitHub.

mac

``` r
# install.packages("devtools")
devtools::install_github("fdzul/deneggs")
```

linux fedora

``` r
# install.packages("devtools")
remotes::install_github("fdzul/deneggs")
```

### **`deneggs::spde_pred_map()`** return a list with six object:

-   **`data`** is the original dataset of the ovitrap.
-   **`pred`** is the predicction dataset of *the Ae. aegypti* eggs.
-   **`dics`** is a dataframe with the dics of six distribution
    (poisson, zeroinflatedpoisson0, 1, zeroinflatedpoisson1, nbinomial,
    nbinomial2, zeroinflatednbinomial0, zeroinflatednbinomial1).
-   **`hotspots`** a dataset with the eggs prediction and the hotspots
    eggs.
-   **`loc`** is the loclaity limit.
-   **`map`** is the map prediction.

``` r
# Step 1. define the paths 
library(magrittr)
library(sf)
path_lect <- "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/12_Guerrero"
path_coord =  "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/12_Guerrero/DescargaOvitrampasMesFco.txt"

acapulco <- deneggs::spde_pred_map(path_lect = path_lect,
                                   cve_ent = "12",
                                   locality  = c("Acapulco de Juárez"),
                                   path_coord =  path_coord,
                                   longitude  = "Pocision_X",
                                   latitude =  "Pocision_Y",
                                   aproximation = "gaussian",
                                   integration = "eb",
                                   k = 20,
                                   palette_vir  = "magma",
                                   leg_title = "Huevos",
                                   week = lubridate::epiweek(Sys.Date())-2,
                                   plot = TRUE,
                                   var = "Huevecillos",
                                   cell_size = 1000,
                                   alpha = .99)
```

<img src="man/figures/README-example-1.png" width="100%" style="display: block; margin: auto;" />

``` r

knitr::kable(head(acapulco$data), "simple")
```

|      | Clave.x           | Entidad.x   | Jurisdiccion  | Municipio.x        | Localidad.x        | Sector | Manzana |   Ovitrampa | Huevecillos | No.Lectura | Fecha.Lectura | Fecha.Recoleccion.Papeleta | Semana.Epidemiologica | Usuario  | Fecha.Captura | RFC.del.Operador | CAMEX | Clave.y           | Entidad.y   | Municipio.y            | Localidad.y             | Pocision\_X | Pocision\_Y | FechaGeo   |
|------|:------------------|:------------|:--------------|:-------------------|:-------------------|-------:|--------:|------------:|------------:|:-----------|:--------------|:---------------------------|----------------------:|:---------|:--------------|:-----------------|:------|:------------------|:------------|:-----------------------|:------------------------|------------:|------------:|:-----------|
| 7201 | 12001000103060758 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    306 |     758 | 12001018871 |          NA | 34         | 18/12/2020    | 18/12/2020                 |                    51 | c1207:10 | 19/12/2020    | PEHA730423Q80    | SI    | 12001000103060758 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.80358 |    16.82112 | 26/04/2018 |
| 7202 | 12001000103060758 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    306 |     758 | 12001018872 |           3 | 34         | 18/12/2020    | 18/12/2020                 |                    51 | c1207:10 | 19/12/2020    | PEHA730423Q80    | SI    | 12001000103060758 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.80358 |    16.82113 | 26/04/2018 |
| 7203 | 12001000103060758 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    306 |     758 | 12001018873 |           2 | 34         | 18/12/2020    | 18/12/2020                 |                    51 | c1207:10 | 19/12/2020    | PEHA730423Q80    | SI    | 12001000103060758 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.80388 |    16.82023 | 26/04/2018 |
| 7204 | 12001000103060758 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    306 |     758 | 12001018874 |           0 | 34         | 18/12/2020    | 18/12/2020                 |                    51 | c1207:10 | 19/12/2020    | PEHA730423Q80    | SI    | 12001000103060758 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.80380 |    16.82020 | 26/04/2018 |
| 7205 | 12001000103060733 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    306 |     733 | 12001018875 |           0 | 34         | 18/12/2020    | 18/12/2020                 |                    51 | c1207:10 | 19/12/2020    | PEHA730423Q80    | SI    | 12001000103060733 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.80475 |    16.82151 | 26/04/2018 |
| 7206 | 12001000103060733 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    306 |     733 | 12001018876 |           3 | 34         | 18/12/2020    | 18/12/2020                 |                    51 | c1207:10 | 19/12/2020    | PEHA730423Q80    | SI    | 12001000103060733 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.80465 |    16.82150 | 26/04/2018 |

``` r
knitr::kable(head(acapulco$pred), "simple")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|
| -99.70839 | 16.71783 |   10.67464 | 11.82568 | 1.235099 | 1.235099 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 |
| -99.71302 | 16.72005 |   10.65358 | 11.64921 | 1.261346 | 1.261346 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 |
| -99.71764 | 16.72228 |   10.23380 | 10.06743 | 1.452240 | 1.452240 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 |
| -99.71533 | 16.72228 |   10.40324 | 10.69944 | 1.369551 | 1.369551 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 |
| -99.71302 | 16.72228 |   10.79439 | 12.02678 | 1.236413 | 1.236413 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 |
| -99.72226 | 16.72451 |   10.75880 | 11.27469 | 1.371532 | 1.371532 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 |

``` r
knitr::kable(head(acapulco$dics), "simple")
```

|      dic | fam                    |
|---------:|:-----------------------|
| 54438.09 | poisson                |
| 36099.52 | zeroinflatedpoisson0   |
| 36120.26 | zeroinflatedpoisson1   |
| 21727.63 | nbinomial              |
| 22400.06 | nbinomial2             |
| 21069.52 | zeroinflatednbinomial0 |

``` r
knitr::kable(head(acapulco$hotspots), "simple")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic | z\_score   | hotspots    |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|:-----------|:------------|
| -99.70839 | 16.71783 |   10.67464 | 11.82568 | 1.235099 | 1.235099 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 | 0.17022279 | No Hotspots |
| -99.71302 | 16.72005 |   10.65358 | 11.64921 | 1.261346 | 1.261346 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 | 0.02814144 | No Hotspots |
| -99.71764 | 16.72228 |   10.23380 | 10.06743 | 1.452240 | 1.452240 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 | 0.03956312 | No Hotspots |
| -99.71533 | 16.72228 |   10.40324 | 10.69944 | 1.369551 | 1.369551 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 | 0.02618988 | No Hotspots |
| -99.71302 | 16.72228 |   10.79439 | 12.02678 | 1.236413 | 1.236413 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 | 0.29358801 | No Hotspots |
| -99.72226 | 16.72451 |   10.75880 | 11.27469 | 1.371532 | 1.371532 |       NA |     NA |   51 | zeroinflatednbinomial0 | 21064.11 | 0.13294394 | No Hotspots |

``` r
# The locality limit of Acapulco
plot(sf::st_geometry(acapulco$loc))
```

<img src="man/figures/README-example-2.png" width="100%" style="display: block; margin: auto;" />

``` r
# prediction of the number of Ae. aegypty eggs in the metropolitan area of Acapulco
acapulco$map
```

<img src="man/figures/README-example-3.png" width="100%" style="display: block; margin: auto;" />

``` r
# prediction of the number of eggs in the metropolitan area of Monterrey 
deneggs::eggs_hotspots(path_lect = "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/19_NuevoLeon",
                       cve_ent = "19",
                       locality  = c("Ciudad General Escobedo", "Ciudad Apodaca",
                                     "Guadalupe", "Monterrey", "Ciudad Santa Catarina",
                                     "San Pedro Garza García", "Ciudad Benito Juárez",
                                     "San Nicolás de los Garza", "Montebello"),
                       path_coord =  "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/19_NuevoLeon/DescargaOvitrampasMesFco.txt",
                       longitude  = "Pocision_X",
                       latitude =  "Pocision_Y",
                       aproximation = "gaussian",
                       integration = "eb",
                       fam = "zeroinflatednbinomial1",
                       k = 30,
                       palette_vir  = "magma",
                       leg_title = "Huevos",
                       plot = FALSE,
                       hist_dataset = FALSE, #####
                       sem = lubridate::epiweek(Sys.Date())-2,
                       var = "eggs",
                       cell_size = 1000,
                       alpha = .99)$map
```

<img src="man/figures/README-example-4.png" width="100%" style="display: block; margin: auto;" />

``` r
# prediction of the number of eggs in the metropolitan area of Merida
deneggs::eggs_hotspots(path_lect = "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/31_Yucatan",
                       cve_ent = "31",
                       locality  = c("Mérida"),
                       path_coord =  "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/31_yucatan/DescargaOvitrampasMesFco.txt",
                       longitude  = "Pocision_X",
                       latitude =  "Pocision_Y",
                       aproximation = "gaussian",
                       integration = "eb",
                       fam = "zeroinflatednbinomial1",
                       k = 30,
                       palette_vir  = "magma",
                       leg_title = "Huevos",
                       plot = FALSE,
                       hist_dataset = FALSE, #####
                       sem = lubridate::epiweek(Sys.Date())-2,
                       var = "eggs",
                       cell_size = 1000,
                       alpha = .99)$map
```

<img src="man/figures/README-example-5.png" width="100%" style="display: block; margin: auto;" />

``` r
# prediction of the number of eggs in the metropolitan area of Guadalajara
deneggs::eggs_hotspots(path_lect = "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/14_Jalisco",
                       cve_ent = "14",
                       locality  = c("Guadalajara", "Tlaquepaque", "Zapopan", "Tonalá"),
                       path_coord =  "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/14_Jalisco/DescargaOvitrampasMesFco.txt",
                       longitude  = "Pocision_X",
                       latitude =  "Pocision_Y",
                       aproximation = "gaussian",
                       integration = "eb",
                       fam = "zeroinflatednbinomial1",
                       k = 40,
                       palette_vir  = "magma",
                       leg_title = "Huevos",
                       plot = FALSE,
                       hist_dataset = FALSE, #####
                       sem = lubridate::epiweek(Sys.Date())-2,
                       var = "eggs",
                       cell_size = 1000,
                       alpha = .99)$map
```

<img src="man/figures/README-example-6.png" width="100%" style="display: block; margin: auto;" />

## Authors

-   **Felipe Antonio Dzul Manzanilla** -**<https://github.com/fdzul>** -
    Packages developed in github:

    1.  [denhotspots](https://github.com/fdzul/denhotspots).
    2.  [boldenr](https://github.com/fdzul/boldenr).
    3.  [dendata](https://github.com/fdzul/dendata).
    4.  [rgeomex](https://github.com/fdzul/rgeomex).

-   **Fabian Correa Morales**

-   **Luis Hernández Herrera**

-   **Arturo Baez-Hernández**

See also the list of
[contributors](https://github.com/fdzul/deneggs/contributors) who
participated in this project.

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

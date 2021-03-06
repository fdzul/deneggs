
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
path_lect <- "C:/Users/felip/Dropbox/cenaprece_datasets/12_Guerrero"
path_coord <- paste(path_lect,"DescargaOvitrampasMesFco.txt", sep = "/")

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
                                   week = lubridate::epiweek(Sys.Date())-1,
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
| 8455 | 12001000102630043 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    263 |      43 | 12001012561 |           6 | 6          | 26/02/2021    | 26/02/2021                 |                     8 | c1207:18 | 01/03/2021    | GOCY730430EI5    | NO    | 12001000102630043 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.85986 |    16.86853 | 12/05/2014 |
| 8456 | 12001000102180044 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    218 |      44 | 12001012563 |          10 | 6          | 22/02/2021    | 22/02/2021                 |                     8 | c1207:16 | 25/02/2021    | VACA780627S19    | SI    | 12001000102180044 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.85719 |    16.87830 | 12/05/2014 |
| 8457 | 12001000100530051 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |     53 |      51 | 12001012760 |           3 | 6          | 26/02/2021    | 26/02/2021                 |                     8 | c1207:17 | 01/03/2021    | VACA780627S19    | NO    | 12001000100530051 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.91502 |    16.86112 | 27/06/2014 |
| 8458 | 12001000100530051 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |     53 |      51 | 12001012761 |           7 | 6          | 26/02/2021    | 26/02/2021                 |                     8 | c1207:17 | 01/03/2021    | VACA780627S19    | NO    | 12001000100530051 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.91495 |    16.86135 | 27/06/2014 |
| 8459 | 12001000100530051 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |     53 |      51 | 12001012762 |          10 | 6          | 26/02/2021    | 26/02/2021                 |                     8 | c1207:17 | 01/03/2021    | VACA780627S19    | NO    | 12001000100530051 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.91484 |    16.86162 | 27/06/2014 |
| 8460 | 12001000100530051 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |     53 |      51 | 12001012763 |           7 | 6          | 26/02/2021    | 26/02/2021                 |                     8 | c1207:17 | 01/03/2021    | VACA780627S19    | NO    | 12001000100530051 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.91563 |    16.86156 | 27/06/2014 |

``` r
knitr::kable(head(acapulco$pred), "simple")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|
| -99.70839 | 16.71783 |   9.634648 | 4.655073 | 3.534199 | 3.534199 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 |
| -99.71302 | 16.72005 |   9.583629 | 4.499411 | 3.616479 | 3.616479 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 |
| -99.71764 | 16.72228 |  10.005135 | 5.748256 | 3.044626 | 3.044626 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 |
| -99.71533 | 16.72228 |   9.704511 | 4.865771 | 3.428322 | 3.428322 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 |
| -99.71302 | 16.72228 |   9.646772 | 4.691857 | 3.515263 | 3.515263 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 |
| -99.72226 | 16.72451 |  11.308387 | 9.452139 | 2.081397 | 2.081397 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 |

``` r
knitr::kable(head(acapulco$dics), "simple")
```

|      dic | fam                    |
|---------:|:-----------------------|
| 46944.84 | poisson                |
| 31760.89 | zeroinflatedpoisson0   |
| 31772.67 | zeroinflatedpoisson1   |
| 14032.69 | nbinomial              |
| 15124.45 | nbinomial2             |
| 13924.58 | zeroinflatednbinomial0 |

``` r
knitr::kable(head(acapulco$hotspots), "simple")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic | z\_score   | hotspots    |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|:-----------|:------------|
| -99.70839 | 16.71783 |   9.634648 | 4.655073 | 3.534199 | 3.534199 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 | -0.6408057 | No Hotspots |
| -99.71302 | 16.72005 |   9.583629 | 4.499411 | 3.616479 | 3.616479 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 | -0.8739322 | No Hotspots |
| -99.71764 | 16.72228 |  10.005135 | 5.748256 | 3.044626 | 3.044626 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 | -0.7189590 | No Hotspots |
| -99.71533 | 16.72228 |   9.704511 | 4.865771 | 3.428322 | 3.428322 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 | -0.8592798 | No Hotspots |
| -99.71302 | 16.72228 |   9.646772 | 4.691857 | 3.515263 | 3.515263 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 | -0.8091939 | No Hotspots |
| -99.72226 | 16.72451 |  11.308387 | 9.452139 | 2.081397 | 2.081397 |       NA |     NA |    8 | zeroinflatednbinomial0 | 13920.97 | -0.4333133 | No Hotspots |

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
deneggs::eggs_hotspots(path_lect = "C:/Users/felip/Dropbox/cenaprece_datasets/19_nuevo_leon",
                       cve_ent = "19",
                       locality  = c("Ciudad General Escobedo", "Ciudad Apodaca",
                                     "Guadalupe", "Monterrey", "Ciudad Santa Catarina",
                                     "San Pedro Garza García", "Ciudad Benito Juárez",
                                     "San Nicolás de los Garza", "Montebello"),
                       path_coord =  "C:/Users/felip/Dropbox/cenaprece_datasets/19_nuevo_leon/DescargaOvitrampasMesFco.txt",
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
deneggs::eggs_hotspots(path_lect = "C:/Users/felip/Dropbox/cenaprece_datasets/31_yucatan",
                       cve_ent = "31",
                       locality  = c("Mérida"),
                       path_coord =  "C:/Users/felip/Dropbox/cenaprece_datasets/31_yucatan/DescargaOvitrampasMesFco.txt",
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
deneggs::eggs_hotspots(path_lect = "C:/Users/felip/Dropbox/cenaprece_datasets/14_jalisco",
                       cve_ent = "14",
                       locality  = c("Guadalajara", "Tlaquepaque", "Zapopan", "Tonalá"),
                       path_coord =  "C:/Users/felip/Dropbox/cenaprece_datasets/14_jalisco/DescargaOvitrampasMesFco.txt",
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

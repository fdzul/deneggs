
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
remote::install_github("fdzul/deneggs")
```

## **`deneggs::spde_pred_map()`** return a list with six object:

### - **`data`** is the original dataset of the ovitrap.

### - **`pred`** is the predicction dataset of *the Ae. aegypti* eggs.

### - **`dics`** is a dataframe with the dics of six distribution (poisson, zeroinflatedpoisson0, 1, zeroinflatedpoisson1, nbinomial, nbinomial2, zeroinflatednbinomial0, zeroinflatednbinomial1).

### - **`hotspots`** a dataset with the eggs prediction and the hotspots eggs.

### - **`loc`** is the loclaity limit.

### - **`map`** is the map prediction.

``` r
# Step 1. define the paths 
library(magrittr)
path_lect <- "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/12_Guerrero"
path_shp <- "D:/Users/OneDrive/datasets/MG_sep_2019/12_guerrero/conjunto_de_datos/12l.shp"
path_coord =  "D:/Users/OneDrive/datasets/SI_Monitoreo_Vectores/subsistema_vigilancia_dengue/2020/12_Guerrero/DescargaOvitrampasMesFco.txt"

acapulco <- deneggs::spde_pred_map(path_lect = path_lect,
                 path_shp = path_shp,
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
| 5597 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015390 |           3 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84975 |    16.88086 | 11/08/2015 |
| 5598 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015391 |          16 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84999 |    16.88040 | 11/08/2015 |
| 5599 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015392 |          28 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84993 |    16.87995 | 11/08/2015 |
| 5600 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015393 |          24 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84956 |    16.87996 | 11/08/2015 |
| 5601 | 12001000101120053 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    112 |      53 | 12001015402 |           0 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:18 | 24/11/2020    | MOLJ680425165    | SI    | 12001000101120053 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.82800 |    16.92169 | 11/08/2015 |
| 5602 | 12001000101120053 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    112 |      53 | 12001015403 |           0 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:18 | 24/11/2020    | MOLJ680425165    | SI    | 12001000101120053 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.82761 |    16.92173 | 11/08/2015 |

``` r
knitr::kable(head(acapulco$pred), "simple")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|
| -99.70839 | 16.71783 |   10.04623 | 3.162354 | 5.245729 | 5.245729 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71302 | 16.72005 |   10.02330 | 3.075008 | 5.322923 | 5.322923 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71764 | 16.72228 |   10.12196 | 3.448031 | 5.004219 | 5.004219 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71533 | 16.72228 |   10.04068 | 3.144643 | 5.260470 | 5.260470 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71302 | 16.72228 |   10.04565 | 3.161963 | 5.245654 | 5.245654 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.72226 | 16.72451 |   10.54229 | 4.843968 | 4.061820 | 4.061820 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |

``` r
knitr::kable(head(acapulco$dics), "simple")
```

|      dic | fam                    |
|---------:|:-----------------------|
| 69157.90 | poisson                |
| 48792.52 | zeroinflatedpoisson0   |
| 48794.68 | zeroinflatedpoisson1   |
| 24837.15 | nbinomial              |
| 25771.48 | nbinomial2             |
| 24530.23 | zeroinflatednbinomial0 |

``` r
knitr::kable(head(acapulco$hotspots), "simple")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic | z\_score   | hotspots    |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|:-----------|:------------|
| -99.70839 | 16.71783 |   10.04623 | 3.162354 | 5.245729 | 5.245729 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.2201271 | No Hotspots |
| -99.71302 | 16.72005 |   10.02330 | 3.075008 | 5.322923 | 5.322923 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.3218197 | No Hotspots |
| -99.71764 | 16.72228 |   10.12196 | 3.448031 | 5.004219 | 5.004219 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.2646135 | No Hotspots |
| -99.71533 | 16.72228 |   10.04068 | 3.144643 | 5.260470 | 5.260470 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.3170065 | No Hotspots |
| -99.71302 | 16.72228 |   10.04565 | 3.161963 | 5.245654 | 5.245654 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.2669700 | No Hotspots |
| -99.72226 | 16.72451 |   10.54229 | 4.843968 | 4.061820 | 4.061820 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.1483803 | No Hotspots |

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
                       path_shp = "D:/Users/OneDrive/datasets/MG_sep_2019/19_nuevoleon/conjunto_de_datos/19l.shp",
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
                       path_shp = "D:/Users/OneDrive/datasets/MG_sep_2019/31_yucatan/conjunto_de_datos/31l.shp",
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
                       path_shp = "D:/Users/OneDrive/datasets/MG_sep_2019/14_jalisco/conjunto_de_datos/14l.shp",
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

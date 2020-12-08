
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

-   **`spde_pred_map()`** generate the predictive map.
-   **`eggs_map()`** generates an entomological risk map or an egg
    density map.
-   **`loc_grid_points()`** It is a complementary function that helps in
    the creation of grid of the locality in the prediction stack in
    [INLA](http://www.r-inla.org/).
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

## Example

``` r
# Step 1. define the paths 
library(magrittr)
#> Warning: package 'magrittr' was built under R version 4.0.3
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
                 leg_title = "Huevos de Ae. aegypti",
                 week = lubridate::epiweek(Sys.Date())-2,
                 plot = TRUE,
                 var = "Huevecillos",
                 cell_size = 1000,
                 alpha = .99)
#> Warning in scan(file = file, what = what, sep = sep, quote = quote, dec = dec, :
#> embedded nul(s) found in input
#> Warning in scan(file = file, what = what, sep = sep, quote = quote, dec = dec, :
#> embedded nul(s) found in input
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> Warning in proj4string(sp): CRS object has comment, which is lost in output
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> 
#>      PLEASE NOTE:  The components "delsgs" and "summary" of the
#>  object returned by deldir() are now DATA FRAMES rather than
#>  matrices (as they were prior to release 0.0-18).
#>  See help("deldir").
#>  
#>      PLEASE NOTE: The process that deldir() uses for determining
#>  duplicated points has changed from that used in version
#>  0.0-9 of this package (and previously). See help("deldir").
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r
knitr::kable(head(acapulco$data), "simple", caption = "An example table caption.")
```

|      | Clave.x           | Entidad.x   | Jurisdiccion  | Municipio.x        | Localidad.x        | Sector | Manzana |   Ovitrampa | Huevecillos | No.Lectura | Fecha.Lectura | Fecha.Recoleccion.Papeleta | Semana.Epidemiologica | Usuario  | Fecha.Captura | RFC.del.Operador | CAMEX | Clave.y           | Entidad.y   | Municipio.y            | Localidad.y             | Pocision\_X | Pocision\_Y | FechaGeo   |
|------|:------------------|:------------|:--------------|:-------------------|:-------------------|-------:|--------:|------------:|------------:|:-----------|:--------------|:---------------------------|----------------------:|:---------|:--------------|:-----------------|:------|:------------------|:------------|:-----------------------|:------------------------|------------:|------------:|:-----------|
| 5597 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015390 |           3 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84975 |    16.88086 | 11/08/2015 |
| 5598 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015391 |          16 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84999 |    16.88040 | 11/08/2015 |
| 5599 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015392 |          28 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84993 |    16.87995 | 11/08/2015 |
| 5600 | 12001000102150095 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    215 |      95 | 12001015393 |          24 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:17 | 24/11/2020    | EADA0209114T8    | SI    | 12001000102150095 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.84956 |    16.87996 | 11/08/2015 |
| 5601 | 12001000101120053 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    112 |      53 | 12001015402 |           0 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:18 | 24/11/2020    | MOLJ680425165    | SI    | 12001000101120053 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.82800 |    16.92169 | 11/08/2015 |
| 5602 | 12001000101120053 | 12 Guerrero | 1207 Acapulco | Acapulco de Juárez | Acapulco De Juárez |    112 |      53 | 12001015403 |           0 | 29         | 23/11/2020    | 23/11/2020                 |                    48 | c1207:18 | 24/11/2020    | MOLJ680425165    | SI    | 12001000101120053 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |   -99.82761 |    16.92173 | 11/08/2015 |

An example table caption.

``` r
knitr::kable(head(acapulco$pred), "simple", caption = "An example table caption.")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|
| -99.70839 | 16.71783 |   10.04623 | 3.162354 | 5.245729 | 5.245729 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71302 | 16.72005 |   10.02330 | 3.075008 | 5.322923 | 5.322923 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71764 | 16.72228 |   10.12196 | 3.448031 | 5.004219 | 5.004219 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71533 | 16.72228 |   10.04068 | 3.144643 | 5.260470 | 5.260470 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.71302 | 16.72228 |   10.04565 | 3.161963 | 5.245654 | 5.245654 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |
| -99.72226 | 16.72451 |   10.54229 | 4.843968 | 4.061820 | 4.061820 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 |

An example table caption.

``` r
knitr::kable(head(acapulco$dics), "simple", caption = "An example table caption.")
```

|      dic | fam                    |
|---------:|:-----------------------|
| 69157.90 | poisson                |
| 48792.52 | zeroinflatedpoisson0   |
| 48794.68 | zeroinflatedpoisson1   |
| 24837.15 | nbinomial              |
| 25771.48 | nbinomial2             |
| 24530.23 | zeroinflatednbinomial0 |

An example table caption.

``` r
knitr::kable(head(acapulco$hotspots), "simple", caption = "An example table caption.")
```

|         x |        y | pred\_mean | pred\_sd | pred\_ll | pred\_ul | ws\_mean | ws\_sd | week | fam                    |      dic | z\_score   | hotspots    |
|----------:|---------:|-----------:|---------:|---------:|---------:|---------:|-------:|-----:|:-----------------------|---------:|:-----------|:------------|
| -99.70839 | 16.71783 |   10.04623 | 3.162354 | 5.245729 | 5.245729 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.2201271 | No Hotspots |
| -99.71302 | 16.72005 |   10.02330 | 3.075008 | 5.322923 | 5.322923 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.3218197 | No Hotspots |
| -99.71764 | 16.72228 |   10.12196 | 3.448031 | 5.004219 | 5.004219 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.2646135 | No Hotspots |
| -99.71533 | 16.72228 |   10.04068 | 3.144643 | 5.260470 | 5.260470 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.3170065 | No Hotspots |
| -99.71302 | 16.72228 |   10.04565 | 3.161963 | 5.245654 | 5.245654 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.2669700 | No Hotspots |
| -99.72226 | 16.72451 |   10.54229 | 4.843968 | 4.061820 | 4.061820 |       NA |     NA |   48 | zeroinflatednbinomial0 | 24524.27 | -0.1483803 | No Hotspots |

An example table caption.

``` r
plot(sf::st_geometry(acapulco$loc))
```

<img src="man/figures/README-example-2.png" width="100%" />

``` r
acapulco$map
```

<img src="man/figures/README-example-3.png" width="100%" />

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

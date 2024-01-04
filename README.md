
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

- **`deneggs::spde_pred_map()`** generate the predictive mapand
  calculate the hotspots. Run the models with six distributions.
- **`deneggs::eggs_hotspots()`** generate the predictive map and
  calculate the hotspots. Run the model with one distribution.
- **`deneggs::animap_vector_hotblocks()`** generate the animated map of
  hotblocks of eggs abundance.
- **`deneggs::ovitraps_read()`** reads current ovitramp databases and
  historical.
- **`deneggs::eggs_map()`** generates an entomological risk map or an
  egg density map.
- **`deneggs::loc_grid_points()`** It is a complementary function that
  helps in the creation of grid of the locality in the prediction stack
  in [INLA](http://www.r-inla.org/).
- **`mesh()`** It is a complementary function that helps in the creation
  of mesh.

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

- **`data`** is the original dataset of the ovitrap.
- **`pred`** is the predicction dataset of *the Ae. aegypti* eggs.
- **`dics`** is a dataframe with the dics of six distribution (poisson,
  zeroinflatedpoisson0, 1, zeroinflatedpoisson1, nbinomial, nbinomial2,
  zeroinflatednbinomial0, zeroinflatednbinomial1).
- **`hotspots`** a dataset with the eggs prediction and the hotspots
  eggs.
- **`loc`** is the loclaity limit.
- **`map`** is the map prediction.

``` r
# Step 1. define the paths 
library(sf)
path_lect <- "/Users/fdzul/Library/CloudStorage/OneDrive-Personal/datasets/CENAPRECE/2023/12_guerrero/"
path_coord <- paste(path_lect,"DescargaOvitrampasMesFco.txt", sep = "/")

# Step 2. make the prediction
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
                                   week = 30,
                                   plot = TRUE,
                                   var = "Huevecillos",
                                   cell_size = 1000,
                                   alpha = .99)
```

<img src="man/figures/README-spde_acapulco-1.png" width="100%" style="display: block; margin: auto;" />

``` r


knitr::kable(head(acapulco$data), "simple")
```

| Clave.x           | Entidad.x   | Jurisdiccion  | Municipio.x        | Localidad.x        | Sector | Manzana |   Ovitrampa | Huevecillos | No.Lectura | Fecha.Lectura | Fecha.Recoleccion.Papeleta | Semana.Epidemiologica | Usuario  | Fecha.Captura | RFC.del.Operador | CAMEX | Clave.y           | Entidad.y   | Municipio.y            | Localidad.y             | Pocision_X | Pocision_Y | FechaGeo   |
|:------------------|:------------|:--------------|:-------------------|:-------------------|-------:|--------:|------------:|------------:|:-----------|:--------------|:---------------------------|----------------------:|:---------|:--------------|:-----------------|:------|:------------------|:------------|:-----------------------|:------------------------|-----------:|-----------:|:-----------|
| 12001000103040099 | 12 Guerrero | 1207 ACAPULCO | Acapulco de Juárez | Acapulco De Juárez |    304 |      99 | 12001023350 |          32 | 26         | 28/07/2023    | 28/07/2023                 |                    30 | c1207:26 | 31/07/2023    | MEGD970929KC8    | SI    | 12001000103040099 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |  -99.83735 |   16.82435 | 08/04/2019 |
| 12001000101460085 | 12 Guerrero | 1207 ACAPULCO | Acapulco de Juárez | Acapulco De Juárez |    146 |      85 | 12001023363 |         307 | 23         | 24/07/2023    | 24/07/2023                 |                    30 | c1207:28 | 25/07/2023    | AACO650905N6A    | SI    | 12001000101460085 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |  -99.84645 |   16.90038 | 09/04/2019 |
| 12001000101460085 | 12 Guerrero | 1207 ACAPULCO | Acapulco de Juárez | Acapulco De Juárez |    146 |      85 | 12001023364 |          68 | 23         | 24/07/2023    | 24/07/2023                 |                    30 | c1207:28 | 25/07/2023    | AACO650905N6A    | SI    | 12001000101460085 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |  -99.84624 |   16.90018 | 09/04/2019 |
| 12001000101460085 | 12 Guerrero | 1207 ACAPULCO | Acapulco de Juárez | Acapulco De Juárez |    146 |      85 | 12001023365 |           8 | 23         | 24/07/2023    | 24/07/2023                 |                    30 | c1207:28 | 25/07/2023    | AACO650905N6A    | SI    | 12001000101460085 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |  -99.84569 |   16.90015 | 09/04/2019 |
| 12001000101460085 | 12 Guerrero | 1207 ACAPULCO | Acapulco de Juárez | Acapulco De Juárez |    146 |      85 | 12001023366 |          67 | 23         | 24/07/2023    | 24/07/2023                 |                    30 | c1207:28 | 25/07/2023    | AACO650905N6A    | SI    | 12001000101460085 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |  -99.84553 |   16.90026 | 09/04/2019 |
| 12001000101460087 | 12 Guerrero | 1207 ACAPULCO | Acapulco de Juárez | Acapulco De Juárez |    146 |      87 | 12001023367 |           9 | 23         | 24/07/2023    | 24/07/2023                 |                    30 | c1207:28 | 25/07/2023    | AACO650905N6A    | SI    | 12001000101460087 | 12 Guerrero | 001 Acapulco de Juárez | 0001 ACAPULCO DE JUÁREZ |  -99.84566 |   16.90116 | 09/04/2019 |

``` r
knitr::kable(head(acapulco$pred), "simple")
```

|         x |        y | pred_mean |   pred_sd |  pred_ll |  pred_ul | ws_mean | ws_sd | week | fam                    |     dic |
|----------:|---------:|----------:|----------:|---------:|---------:|--------:|------:|-----:|:-----------------------|--------:|
| -99.69653 | 16.71294 |  46.93143 |  8.926602 | 31.85718 | 31.85718 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 |
| -99.70695 | 16.71641 |  47.58182 | 12.139977 | 28.17665 | 28.17665 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 |
| -99.71389 | 16.71989 |  47.50852 | 11.812690 | 28.52137 | 28.52137 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 |
| -99.72084 | 16.72336 |  61.39220 | 53.967423 | 10.45366 | 10.45366 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 |
| -99.71737 | 16.72336 |  51.73372 | 26.331637 | 17.98862 | 17.98862 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 |
| -99.71389 | 16.72336 |  48.46528 | 15.705557 | 24.81079 | 24.81079 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 |

``` r
knitr::kable(head(acapulco$dics), "simple")
```

|       dic | fam                    |
|----------:|:-----------------------|
| 101955.80 | poisson                |
|  89688.48 | zeroinflatedpoisson0   |
|  89771.94 | zeroinflatedpoisson1   |
|  52681.89 | nbinomial              |
|  52799.23 | nbinomial2             |
|  52546.21 | zeroinflatednbinomial0 |

``` r
knitr::kable(head(acapulco$hotspots), "simple")
```

|         x |        y | pred_mean |   pred_sd |  pred_ll |  pred_ul | ws_mean | ws_sd | week | fam                    |     dic | z_score    | hotspots    |
|----------:|---------:|----------:|----------:|---------:|---------:|--------:|------:|-----:|:-----------------------|--------:|:-----------|:------------|
| -99.69653 | 16.71294 |  46.93143 |  8.926602 | 31.85718 | 31.85718 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 | -0.5942301 | No Hotspots |
| -99.70695 | 16.71641 |  47.58182 | 12.139977 | 28.17665 | 28.17665 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 | -0.8254357 | No Hotspots |
| -99.71389 | 16.71989 |  47.50852 | 11.812690 | 28.52137 | 28.52137 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 | -0.4882049 | No Hotspots |
| -99.72084 | 16.72336 |  61.39220 | 53.967423 | 10.45366 | 10.45366 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 | -0.5543260 | No Hotspots |
| -99.71737 | 16.72336 |  51.73372 | 26.331637 | 17.98862 | 17.98862 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 | -0.5017920 | No Hotspots |
| -99.71389 | 16.72336 |  48.46528 | 15.705557 | 24.81079 | 24.81079 |      NA |    NA |   30 | zeroinflatednbinomial1 | 52503.9 | -0.8069366 | No Hotspots |

``` r

# The locality limit of Acapulco
plot(sf::st_geometry(acapulco$loc))
```

<img src="man/figures/README-spde_acapulco-2.png" width="100%" style="display: block; margin: auto;" />

``` r

# prediction of the number of Ae. aegypty eggs in the metropolitan area of Acapulco
acapulco$map
```

<img src="man/figures/README-spde_acapulco-3.png" width="100%" style="display: block; margin: auto;" />

## Prediction of the number of eggs in the metropolitan area of Monterrey

``` r
path_lect <- "/Users/fdzul/Library/CloudStorage/OneDrive-Personal/datasets/CENAPRECE/2023/19_nuevo_leon/"
path_coord <- paste(path_lect,"DescargaOvitrampasMesFco.txt", sep = "/")
deneggs::eggs_hotspots(path_lect = path_lect,
                       cve_ent = "19",
                       locality  = c("Ciudad General Escobedo", "Ciudad Apodaca",
                                     "Guadalupe", "Monterrey", "Ciudad Santa Catarina",
                                     "San Pedro Garza García", "Ciudad Benito Juárez",
                                     "San Nicolás de los Garza", "Montebello"),
                       path_coord =  path_coord,
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
                       sem = 40,
                       var = "eggs",
                       cell_size = 1000,
                       alpha = .99)$map
```

<img src="man/figures/README-spde_monterrey-1.png" width="100%" style="display: block; margin: auto;" />

## Prediction of the number of eggs in the metropolitan area of Merida

``` r
path_lect <- "/Users/fdzul/Library/CloudStorage/OneDrive-Personal/datasets/CENAPRECE/2023/31_yucatan/"
path_coord <- paste(path_lect,"DescargaOvitrampasMesFco.txt", sep = "/")
# prediction of the number of eggs in the metropolitan area of Merida
deneggs::eggs_hotspots(path_lect = path_lect,
                       cve_ent = "31",
                       locality  = c("Mérida"),
                       path_coord =  path_coord,
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
                       sem = 40,
                       var = "eggs",
                       cell_size = 1000,
                       alpha = .99)$map
```

<img src="man/figures/README-spde_merida-1.png" width="100%" style="display: block; margin: auto;" />

## Prediction of the number of eggs in the metropolitan area of Guadalajara

``` r

path_lect <- "/Users/fdzul/Library/CloudStorage/OneDrive-Personal/datasets/CENAPRECE/2023/14_jalisco/"
path_coord <- paste(path_lect,"DescargaOvitrampasMesFco.txt", sep = "/")

deneggs::eggs_hotspots(path_lect = path_lect,
                       cve_ent = "14",
                       locality  = c("Guadalajara", "Tlaquepaque", "Zapopan", "Tonalá"),
                       path_coord =  path_coord,
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
                       sem = 40,
                       var = "eggs",
                       cell_size = 5000,
                       alpha = .99)$map
```

<img src="man/figures/README-spde_guadalajara-1.png" width="100%" style="display: block; margin: auto;" />

## Authors

- **Felipe Antonio Dzul Manzanilla** -**<https://github.com/fdzul>** -
  Packages developed in github:

  1)  [denhotspots](https://github.com/fdzul/denhotspots).
  2)  [boldenr](https://github.com/fdzul/boldenr).
  3)  [dendata](https://github.com/fdzul/dendata).
  4)  [rgeomex](https://github.com/fdzul/rgeomex).

- **Fabian Correa Morales**

- **Luis Hernández Herrera**

- **Arturo Baez-Hernández**

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

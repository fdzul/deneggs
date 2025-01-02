#' eggs_hotblocks
#'
#' @param path_vect is the directory of the ovitrampas dataset.
#' @param cve_edo is the id of state.
#' @param locality is the locality target
#' @param brand is the palette of color, thera are two option google o slack
#' @param wk is the target week.
#'
#' @return
#' @export
#'
#' @examples
eggs_hotblocks <- function(path_vect, cve_edo,
                           locality, brand, wk){

    # Step 1. load the dataset ####
    #x  <- boldenr::read_dataset_bol(path = path_vect,
    #                                dataset = "vectores",
    #                                inf = "Lecturas") |>
    #    dplyr::filter(Semana.Epidemiologica %in% c(week)) |>
    #    dplyr::filter(Localidad %in% c(similiars::find_most_similar_string(locality,
    #                                                                       unique(Localidad)))) |>
    #    dplyr::group_by(Semana.Epidemiologica, Localidad, Clave) |>
    #    dplyr::summarise(mean = round(mean(Huevecillos, na.rm = TRUE),
    #                                  digits = 1),
    #                     .groups = "drop")

    x <- deneggs::ovitraps_read(path = path_vect,
                                current_year = TRUE) |>
        dplyr::filter(week %in% c(wk)) |>
        dplyr::filter(Localidad %in% c(similiars::find_most_similar_string(locality,
                                                                           unique(Localidad)))) |>
        dplyr::group_by(week, Localidad, clave) |>
        dplyr::summarise(mean = round(mean(eggs, na.rm = TRUE),
                                      digits = 1),
                         .groups = "drop") |>
        dplyr::filter(!is.na(mean))

    # Step 2. load the blocks ine 2020 ####
    if(cve_edo %in% c(rep(26:32))){
        blocks_ine <- rgeomex::blocks_ine20_mx_e |>
            dplyr::filter(entidad == cve_edo)

    } else if(cve_edo %in% c(rep(20:25))){
        blocks_ine <- rgeomex::blocks_ine20_mx_d |>
            dplyr::filter(entidad == cve_edo)

    } else if(cve_edo %in% c(rep(15:19))){
        blocks_ine <- rgeomex::blocks_ine20_mx_c |>
            dplyr::filter(entidad == cve_edo)

    } else if(cve_edo %in% c(rep(11:14))){
        blocks_ine <- rgeomex::blocks_ine20_mx_b |>
            dplyr::filter(entidad == cve_edo)

    } else if(cve_edo %in% c(rep(1:10))){
        blocks_ine <- rgeomex::blocks_ine20_mx_a |>
            dplyr::filter(entidad == cve_edo)

    } else{

    }

    blocks_ine <- blocks_ine |>
        dplyr::mutate(cve_geo = paste(stringr::str_pad(entidad, pad = "0", width = 2, side = "left"),
                                      stringr::str_pad(municipio, pad = "0", width = 3, side = "left"),
                                      stringr::str_pad(localidad, pad = "0", width = 4, side = "left"),
                                      stringr::str_pad(seccion, pad = "0", width = 4, side = "left"),
                                      stringr::str_pad(manzana, pad = "0", width = 4, side = "left"),
                                      sep = ""))

    # Step 3. load the locality shapefile ####
    z <- rgeomex::loc_inegi19_mx  |>
        dplyr::filter(NOMGEO %in% c(similiars::find_most_similar_string(locality, unique(NOMGEO))) &
                          cve_edo %in% c(cve_edo))

    if(nrow(z) > 1){
        z <- z  |>    sf::st_union()
    } else {

    }

    # Step 3. left joint control larvario and blocks ine 2020 datasets #### 10542
    x_blocks <- dplyr::left_join(x = blocks_ine |>
                                     dplyr::select(geometry, id, cve_geo),
                                 y = x,
                                 by  = c("cve_geo" = "clave")) |>
        dplyr::filter(!is.na(Localidad)) |>
        dplyr::select(Localidad:geometry)

    x_blocks <- x_blocks |>
        dplyr::bind_cols(boldenr::risk_percentil(x = x_blocks |>
                                                     sf::st_drop_geometry(),
                                                 var = "mean",
                                                 en = FALSE) |>
                             dplyr::select(percentil, risk))


    if(brand == "google"){
        mapview::mapview(x_blocks,
                         zcol = "risk",
                         layer.name = "Manzanas Calientes",
                         color = "white",
                         alpha.regions = 1,
                         col.regions = c("#E01E5A","#ECB22E",
                                         "#2EB67D", "#0C59FE80"))
    } else if(brand == "slack"){
        mapview::mapview(x_blocks,
                         zcol = "risk",
                         layer.name = "Manzanas Calientes",
                         color = "white",
                         alpha.regions = 1,
                         col.regions = c("#E01E5A","#ECB22E",
                                         "#2EB67D", "#36C5F0"))
    } else {

    }


}

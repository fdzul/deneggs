#' eggs_map
#'
#' The function generates an egg map of Aedes Aegypti.
#'
#' @param path_lect is the directory of ovitraps dataset.
#' @param path_coord is the directory of coordinates dataset.
#' @param path_shp is the directory of shepefile dataset.
#' @param loc is the target locality.
#' @param size is the size of point.
#' @param alpha is the transparency of point.
#' @param palette_vir is the name of pallete of viridis.
#' @param risk is logical value, if is TRUE return of percentil map, else only map of eggs.
#' @param weeks is the week number.
#' @param leg_title is title of legend.
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @return a ggplot.
#' @export
#'
#' @examples 1 +1
eggs_map <- function(path_lect, path_coord, path_shp,
                     leg_title,
                     loc, size, alpha, palette_vir, risk, weeks){
    ## Step 2. load the ovitrap dataset ####
    x <- boldenr::read_dataset_bol(path = path_lect,
                                   dataset = "vectores",
                                   inf = "Lecturas") %>%
        dplyr::filter(Localidad %in% c(loc)) %>%
        dplyr::filter(Semana.Epidemiologica %in% c(weeks))
    ## Step 3. load the coordinates dataset ####
    #load("/Users/felipe_dzul/Dropbox/1.Read_Automatic_dataset_platform/RData/SI_monitoreo_vectores/Coordinates_2017.RData")
    y <- read.table(file = path_coord,
                    sep = "\t",
                    header = TRUE,
                    stringsAsFactors = FALSE,
                    fileEncoding = "UCS-2LE")

    # Step 4. joint the coordinates ####
    x$Ovitrampa <- as.numeric(x$Ovitrampa)
    y$Ovitrampa <- as.numeric(y$Ovitrampa)
    xy <- dplyr::left_join(x = x,
                           y = y,
                           by = "Ovitrampa") %>%
        dplyr::filter(!is.na(Huevecillos)) %>%
        as.data.frame() %>%
        dplyr::group_by(Semana.Epidemiologica) %>%
        tidyr::nest() %>%
        dplyr::mutate(risk = purrr::map(data,
                                        boldenr::risk_percentil,
                                        var = "Huevecillos", en = TRUE)) %>%
        dplyr::select(-data) %>%
        tidyr::unnest(cols = c(risk))

    loc_lim <- sf::st_read(path_shp) %>%
        dplyr::filter(NOMBRE %in% c(loc)) %>%
        sf::st_transform(crs = 4326) %>%
        dplyr::select(1:4)
    if(risk == TRUE){
        ggplot2::ggplot(loc_lim) +
            ggplot2::geom_sf(colour = "gray80") +
            ggplot2::coord_sf(datum = NA) +
            ggplot2::geom_point(data = xy,
                                ggplot2::aes(x = Pocision_X,
                                             y = Pocision_Y,
                                             color = risk),
                                size = size,
                                alpha = alpha) +
            ggplot2::labs(x = "", y = "") +
            ggplot2::scale_color_viridis_d(leg_title,
                                           option = palette_vir,
                                           direction = 1) +
            ggplot2::facet_wrap(~Semana.Epidemiologica) +
            ggplot2::theme_bw()
    } else{
        ggplot2::ggplot(loc_lim) +
            ggplot2::geom_sf(colour = "gray80") +
            ggplot2::coord_sf(datum = NA) +
            ggplot2::geom_point(data = xy,
                                ggplot2::aes(x = Pocision_X,
                                             y = Pocision_Y,
                                             color = Huevecillos),
                                size = size,
                                alpha = alpha) +
            ggplot2::labs(x = "", y = "") +
            ggplot2::scale_color_viridis_c(leg_title,
                                           option = palette_vir,
                                           direction = 1) +
            ggplot2::facet_wrap(~Semana.Epidemiologica)+
            ggplot2::theme_bw()
    }

}

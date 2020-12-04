#' animap_vector_hotblocks: a function for create the animated map of hotblocks of eggs.
#'
#' @param path_vector is the directory of ovitrap datasets.
#' @param path_manz is the directory of the blocks shapefile of state.
#' @param path_loc is the directory of the locality limit shapefile.
#' @param locality is the locality target with the ovitraps.
#' @param dir is the directory where the animation will be saved.
#' @param name is the name of the gif file.
#' @param vel is the delay time between images. See also \link[tmap]{tmap_animation}.
#' @param xleg x_leg is the x position of legend. The value is in 0 to 1.
#' @param yleg y_leg is the y position of legend. The value is in 0 to 1.
#'
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#' @return a gif file of animation.
#' @export
#' @seealso \link[tmap]{tmap_animation}
#'
#' @examples 1+1
animap_vector_manz <- function(path_vector, path_manz, path_loc,
                               locality,
                               dir, name, vel, xleg, yleg){
    # Step 1. load the dataset ####
    x  <- boldenr::read_dataset_bol(path = path_vector,
                                    dataset = "vectores",
                                    inf = "Lecturas") %>%
        dplyr::filter(Localidad %in% c(similiars::find_most_similar_string(locality, unique(Localidad)))) %>%
        dplyr::group_by(Semana.Epidemiologica, Localidad, Sector, Manzana) %>%
        dplyr::summarise(mean = round(mean(Huevecillos, na.rm = TRUE), digits = 1)) %>%
        dplyr::mutate(sec_manz = paste(Sector, Manzana, sep = "")) %>%
        tidyr::pivot_wider(id_cols = c( Localidad, sec_manz),
                           names_from = Semana.Epidemiologica,
                           values_from = mean)

    # Step 2. load the shapefile  pf municipalities####
    y <- sf::st_read(path_manz,
                     quiet = TRUE) %>%
        sf::st_transform(crs = 4326) %>%
        dplyr::mutate(sec_manz =  paste(SECCION, MANZANA, sep = ""))

    # Step 3. load the locality shapefile ####
    z <- sf::st_read(path_loc, quiet = TRUE)
    Encoding(z$NOMGEO) <- "latin1"
    z <- z %>%
        dplyr::filter(NOMGEO %in% c(similiars::find_most_similar_string(locality, unique(NOMGEO))) &
                          AMBITO %in% c("Urbana")) %>%
        sf::st_transform(crs = 4326)

    if(nrow(z) > 1){
        z <- z %>%   sf::st_union()
    } else {

    }

    # Step 4. Extract the blocks of the locality ####
    y <- y[z,]

    # Step 5. joint the dataset ####
    xy <- dplyr::left_join(x = y,
                           y = x,
                           by = c("sec_manz")) %>%
        dplyr::filter(!is.na(Localidad))
    xy2 <- xy %>%
        dplyr::select(14:ncol(xy)) %>%
        tidyr::pivot_longer(cols = c(-Localidad,  -geometry),
                            names_to = "week",
                            values_to = "n") %>%
        as.data.frame() %>%
        dplyr::mutate(week = as.numeric(week)) %>%
        dplyr::group_by(week) %>%
        tidyr::nest() %>%
        dplyr::mutate(risk = purrr::map(data,
                                        boldenr::risk_percentil,
                                        var = "n",
                                        en = FALSE)) %>%
        dplyr::select(-data) %>%
        tidyr::unnest(cols = c(risk)) %>%
        as.data.frame() %>%
        dplyr::mutate(week2 = forcats::fct_reorder(paste("Semana Epidemiológica",
                                                         week, sep = " "),
                                                   week)) %>%
        sf::st_set_geometry(value = "geometry")



    # Step 6. animated map with tmap ####
    animated_map <- tmap::tm_shape(shp = z) +
        tmap::tm_polygons(col = "gray85",
                          border.col = "white",
                          lwd = 0.01) +
        tmap::tm_shape(shp = xy2 %>% dplyr::filter(!is.na(risk))) +
        tmap::tm_fill(col = "risk",
                      style = "cat",
                      title = "",
                      palette = c("#F44B1FFF",
                                  "#FF9000FF",
                                  "#35BFFFFF",
                                  "#00F293FF")) +
        tmap::tm_borders(col = "white", lwd = .5) +
        tmap::tm_facets(along = "week2", free.coords = FALSE) +
        tmap::tm_layout(legend.position = c(xleg, yleg))
    tmap::tmap_animation(animated_map,
                         dpi = 300,
                         delay = vel,
                         filename = paste(dir, paste(name, "animated_map.gif",
                                                     sep = "_"), sep = ""),
                         width = 1400,
                         height = 1400)


}

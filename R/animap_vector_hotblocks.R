#' animap_vector_hotblocks: a function for create the animated map of hotblocks of eggs.
#'
#' @param path_vector is the directory of ovitrap datasets.
#' @param cve_edo is the text id of the state.
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
animap_vector_hotblocks <- function(path_vector, locality,cve_edo,
                                    dir, name, vel, xleg, yleg){
    # Step 1. load the dataset ####
    x  <- boldenr::read_dataset_bol(path = path_vector,
                                    dataset = "vectores",
                                    inf = "Lecturas") |>
        dplyr::filter(Localidad %in% c(similiars::find_most_similar_string(locality, unique(Localidad)))) |>
        dplyr::group_by(Semana.Epidemiologica, Localidad, Sector, Manzana) |>
        dplyr::summarise(mean = round(mean(Huevecillos, na.rm = TRUE), digits = 1)) |>
        dplyr::mutate(sec_manz = paste(Sector, Manzana, sep = "")) |>
        tidyr::pivot_wider(id_cols = c( Localidad, sec_manz),
                           names_from = Semana.Epidemiologica,
                           values_from = mean)

    # Step 2. load the blocks ####
    if(cve_edo %in% c(1:10)){
        y <- rgeomex::blocks_ine20_mx_a |>
            sf::st_make_valid() |>
            dplyr::mutate(sec_manz =  paste(seccion, manzana, sep = ""))}
    if(cve_edo %in% c(11:14)){y <- rgeomex::blocks_ine20_mx_b |>
        sf::st_make_valid() |>
        dplyr::mutate(sec_manz =  paste(seccion, manzana, sep = ""))}
    if(cve_edo %in% c(15:19)){y <- rgeomex::blocks_ine20_mx_c |>
        sf::st_make_valid() |>
        dplyr::mutate(sec_manz =  paste(seccion, manzana, sep = ""))}
    if(cve_edo %in% c(20:25)){y <- rgeomex::blocks_ine20_mx_d |>
        sf::st_make_valid() |>
        dplyr::mutate(sec_manz =  paste(seccion, manzana, sep = ""))}
    if(cve_edo %in% c(26:32)){y <- rgeomex::blocks_ine20_mx_e |>
        sf::st_make_valid() |>
        dplyr::mutate(sec_manz =  paste(seccion, manzana, sep = ""))}

    # Step 3. load the locality shapefile ####
    z <- rgeomex::loc_inegi19_mx |>
        dplyr::filter(NOMGEO %in% c(similiars::find_most_similar_string(locality, unique(NOMGEO))) &
                          CVE_ENT %in% c(cve_edo))

    if(nrow(z) > 1){
        z <- z |>   sf::st_union()
    } else {

    }

    # Step 4. Extract the blocks of the locality ####
    y <- y[z,]

    # Step 5. joint the dataset ####
    xy <- dplyr::left_join(x = y,
                           y = x,
                           by = c("sec_manz")) |>
        dplyr::filter(!is.na(Localidad)) |>
        dplyr::select(Localidad:geometry) |>
        tidyr::pivot_longer(cols = c(-Localidad,  -geometry),
                            names_to = "week",
                            values_to = "n") |>
        as.data.frame() |>
        dplyr::mutate(week = as.numeric(week)) |>
        dplyr::group_by(week) |>
        tidyr::nest() |>
        dplyr::mutate(risk = purrr::map(data,
                                        boldenr::risk_percentil,
                                        var = "n",
                                        en = FALSE)) |>
        dplyr::select(-data) |>
        tidyr::unnest(cols = c(risk)) |>
        as.data.frame() |>
        dplyr::mutate(week2 = forcats::fct_reorder(paste("Semana",
                                                         week, sep = " "),
                                                   week)) |>
        sf::st_set_geometry(value = "geometry")



    # Step 6. animated map with tmap ####
    animated_map <- tmap::tm_shape(shp = z) +
        tmap::tm_polygons(col = "gray85",
                          border.col = "white",
                          lwd = 0.01) +
        tmap::tm_shape(shp = xy |> dplyr::filter(!is.na(risk))) +
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

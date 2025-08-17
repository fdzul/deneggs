#' animap_vector_hotblocks: a function for create the animated map of hotblocks of eggs.
#'
#' @param path_ovitraps is the directory of ovitrap datasets.
#' @param cve_edo is the text id of the state.
#' @param locality is the locality target with the ovitraps.
#' @param year is the year target.
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
animap_vector_hotblocks <- function(path_ovitraps, locality,cve_edo,
                                    dir, name, vel, xleg, yleg, year){
    # Step 1. load the dataset ####
    x <- deneggs::ovitraps_read(path = path_ovitraps,
                                current_year = TRUE) |>
        dplyr::filter(Localidad %in% c(rgeomex::find_most_similar_string(locality,
                                                                         unique(Localidad)))) |>
        dplyr::group_by(year, week, Localidad, sector, manzana) |>
        dplyr::summarise(mean = round(mean(eggs, na.rm = TRUE), digits = 1),
                         .groups = "drop") |>
        dplyr::mutate(sec_manz = paste(sector, manzana, sep = "")) |>
        tidyr::pivot_wider(id_cols = c(year, Localidad, sec_manz),
                           names_from = week,
                           values_from = mean) |>
        dplyr::filter(year %in% c(year))

    # Step 2. load the blocks ####
    y <- rgeomex::extract_blocks(cve_edo = cve_edo,
                                 locality = locality)

    # Step 3. load the locality shapefile ####
    z <- y$locality

    if(nrow(z) > 1){
        z <- z |>   sf::st_union()
    } else {

    }

    # Step 4. Extract the blocks of the locality ####
    blocks <- y$block |>
        dplyr::mutate(seccion = stringr::str_pad(seccion,
                                                 width = 4,
                                                 side = "left",
                                                 pad = "0"),
                      manzana = stringr::str_pad(manzana,
                                                 width = 4,
                                                 side = "left",
                                                 pad = "0")) |>
        dplyr::mutate(sec_manz = paste0(seccion, manzana))

    # Step 5. joint the dataset ####
    xy <- dplyr::left_join(x = blocks,
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
                                                         week, year, sep = " "),
                                                   week)) |>
        sf::st_set_geometry(value = "geometry")



    # Step 6. animated map with tmap ####
    animated_map <- tmap::tm_shape(shp = z) +
        tmap::tm_polygons(col = "gray85",
                          border.col = "white",
                          lwd = 0.01) +
        tmap::tm_shape(shp = xy |> dplyr::filter(!is.na(risk))) +
        tmap::tm_polygons(fill = "risk",
                          fill.scale = tmap::tm_scale_categorical(),
                          fill.legend = tmap::tm_legend("risk"),
                          palette = c("#F44B1FFF",
                                      "#FF9000FF",
                                      "#35BFFFFF",
                                      "#00F293FF")) +
        tmap::tm_borders(col = "white", lwd = .5) +
        tmap::tm_facets(pages = "week2", free.coords = FALSE) +
        tmap::tm_layout(legend.position = c(xleg, yleg))


    tmap::tmap_animation(animated_map,
                         dpi = 300,
                         delay = vel,
                         filename = paste(dir, paste(name, "animated_map.gif",
                                                     sep = "_"), sep = ""),
                         width = 1400,
                         height = 1400)


}

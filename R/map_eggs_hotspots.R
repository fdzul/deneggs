#' map_eggs_hotspots
#'
#' The function generates a map per year of the number of weeks that each ovitrap was hotspots.
#'
#' @param betas is the betas of inla spde model.
#' @param locality is the target locality.
#' @param cve_edo is the id of state.
#' @param palette is the palette name package and function. example  rcartocolor::carto_pal.
#' @param name is the name of palette.
#' @param static_map is logical value (TRUE o FALSE). if the value es TRUE the map is static, else the map es interactive.
#' @return a ggplot map.
#' @export
#' @details \link[INLA]{inla}, \link[deneggs]{eggs_hotspots_week}
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#' @examples 1+1
map_eggs_hotspots <- function(betas,
                              locality,
                              cve_edo,
                              palette,
                              name,
                              static_map){

    # Step 1. extract the locality
    locality <- rgeomex::extract_locality(cve_edo = cve_edo,
                                          locality = locality)

    # step 2. extract the eggs hotspots of locality ####

    # Step 2.1 convert the df to sf object
    x <- betas |>
        dplyr::mutate(long = x,
                      lat = y) |>
        sf::st_as_sf(coords = c("long", "lat"),
                     crs = 4326)

    # Step 2.2 extract the eggs hotspots of locality
    x <- x[locality, ] |>
        sf::st_drop_geometry()

    # Step 3. calculate the intensity
    intensity_function <- function(x){
        x |>
            dplyr::mutate(hotspots_binary = ifelse(hotspots == "Hotspots", 1, 0)) |>
            dplyr::select(x, y, week, hotspots_binary) |>
            #dplyr::distinct(x, y, .keep_all = TRUE) |>
            tidyr::pivot_wider(id_cols = c(x, y),
                               names_from = "week",
                               names_prefix = "week_",
                               values_from = "hotspots_binary") |>
            dplyr::mutate(intensity = rowSums(dplyr::across(dplyr::starts_with("week_")), na.rm = TRUE)) |>
            dplyr::mutate(n_week = length(dplyr::across(dplyr::starts_with("week_")))) |>
            dplyr::mutate(per_intensity = round(intensity/n_week, digits = 1)) |>
            dplyr::select(x, y, intensity,n_week, per_intensity) |>
            as.data.frame()
    }

    x <- x |>
        dplyr::group_by(year) |>
        tidyr::nest() |>
        dplyr::mutate(intensity = purrr::map(data,intensity_function)) |>
        dplyr::select(-data) |>
        tidyr::unnest(cols = c(intensity))


    # step 4 plot the map ####
    p <- ggplot2::ggplot() +
        ggplot2::geom_tile(data = x,
                           ggplot2::aes(x = x,
                                        y = y,
                                        fill = intensity)) +
        ggplot2::scale_color_gradientn("Intensidad",
                                       colors = c("gray100", palette(n = max(x$intensity),
                                                                     name = name)),
                                       breaks = seq(0, max(x$intensity), 2),
                                       aesthetics = c("fill")) +
        ggplot2::geom_sf(data = locality,
                         alpha = 1,
                         fill = NA,
                         col = "black",
                         lwd = 0.5) +
        ggplot2::facet_wrap(facets = "year") +
        ggplot2::theme_void() +
        ggplot2::theme(legend.position = "bottom") +
        ggplot2::theme(legend.key.size = ggplot2::unit(.4, "cm"),
                       legend.key.width = ggplot2::unit(.6,"cm"),
                       legend.margin= ggplot2::margin(0,0,0,0),
                       legend.box.margin= ggplot2::margin(1,0,0,0)) +
        ggplot2::theme(legend.text = ggplot2::element_text(colour = "black",
                                                           face  = "bold"),
                       legend.title = ggplot2::element_text(colour = "darkred",
                                                            face  = "bold")) +
        ggplot2::theme(strip.text = ggplot2::element_text(size = 11,
                                                          face = "bold"))

    if(static_map == TRUE){
        p
    } else {
        plotly::ggplotly(p) |>
            plotly::layout(legend = list(orientation = 'h'))
    }


}

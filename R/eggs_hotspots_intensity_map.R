#' eggs_hotspots_intensity_map
#'
#' @param spde_betas is the betas of spde model by year.
#' @param locality is the target locality.
#' @param cve_ent is the id of state.
#' @param palette is the palette name package and function. example  rcartocolor::carto_pal.
#' @param years is the target year.
#' @param name is the name of palette.
#'
#' @return a ggplot map.
#' @export
#' @details \link[INLA]{inla}, \link[deneggs]{eggs_hotspots_week}
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#' @examples 1+1
eggs_hotspots_intensity_map <- function(spde_betas,
                                        locality,
                                        cve_ent,
                                        palette,
                                        years,
                                        name){

    y <- spde_betas |>
        dplyr::filter(year == years) |>
        #dplyr::mutate(hotspots_binary = ifelse(hotspots == "Hotspots", 1, 0)) |>
        dplyr::mutate(hotspots_binary = dplyr::case_when(hotspots == "Hotspots" ~ 1,
                                                         hotspots == "No Hotspots" ~ 0)) |>
        dplyr::select(x, y, week, hotspots_binary) |>
        tidyr::pivot_wider(id_cols = c(x, y),
                           names_from = week,
                           values_from = hotspots_binary) |>
        as.data.frame()


    y$intensity <- rowSums(y |> dplyr::select(-x, -y), na.rm = TRUE)

    #################
    #z <- rgeomex::loc_inegi19_mx  |>
    #   dplyr::filter(NOMGEO %in% c(similiars::find_most_similar_string(locality, unique(NOMGEO))) &
    #                    CVE_ENT %in% c(cve_ent))
    extract_locality <- function(cve_edo, locality){
        rgeomex::loc_inegi19_mx |>
            dplyr::filter(CVE_ENT %in% c(cve_edo)) |>
            dplyr::filter(NOMGEO %in% c(rgeomex::find_most_similar_string(locality, unique(NOMGEO)))) |>
            sf::st_make_valid()
    }

    z <- extract_locality(locality = locality,
                          cve_edo = cve_ent)


    #z <- rgeomex::extract_ageb(locality = locality,cve_geo = cve_ent)


    ggplot2::ggplot() +
        ggplot2::geom_tile(data = y,
                           ggplot2::aes(x = x,
                                        y = y,
                                        fill = intensity),
                           col = "white") +
        ggplot2::scale_color_gradientn("Intensidad",
                                       colors = c("gray100", palette(n = max(y$intensity),
                                                                     name = name)),
                                       breaks = seq(0, max(y$intensity), 2),
                                       aesthetics = c("fill")) +
        #ggplot2::scale_fill_viridis_c("Intensidad", option = "magma") +
        ggplot2::geom_sf(data = z,
                         fill = NA,
                         alpha = 1,
                         col = "gray",
                         lwd = 1) +
        ggplot2::theme_void() +
        ggplot2::theme(legend.position = "bottom") +
        ggplot2::theme(legend.key.size = ggplot2::unit(.4, "cm"),
                       legend.key.width = ggplot2::unit(2.5,"cm"),
                       legend.margin= ggplot2::margin(0,0,0,0),
                       legend.box.margin= ggplot2::margin(-20,0,0,0)) +
        ggplot2::theme(legend.text = ggplot2::element_text(colour = "gray",
                                                           face  = "bold"),
                       legend.title = ggplot2::element_text(colour = "darkred",
                                                            face  = "bold"))
}

#' eggs_risk
#'
#' @param path_vect is the directory of the ovitrampas dataset.
#' @param path_coord is the directory of the coordinates dataset.
#' @param weeks is the week.
#' @param locality is the name of locality
#' @param risk is logical value for define the risk or map the eggs.
#'
#' @return a mapview object
#' @export
#'
#' @examples 1+1
eggs_risk <- function(path_vect,
                      path_coord,
                      weeks,
                      locality,
                      risk){

    # Step 1. load the ovitrap dataset ####
    x <- deneggs::ovitraps_read(path = path_vect,
                                current_year = TRUE,
                                year = NULL) |>
        janitor::clean_names()|>
        dplyr::filter(localidad %in% c(locality)) |>
        dplyr::filter(week %in% c(weeks))


    # Step 2. load the ovitraps coordinates dataset ####
    y <- data.table::fread(path_coord,
                           colClasses= list(character= c(1:10, 11:15)),
                           stringsAsFactors= FALSE) |>
        janitor::clean_names()|>
        dplyr::rename(ovitrap = ovitrampa) |>
        dplyr::select(-localidad, -clave)



    # Step 3. joint the coordinates and ovitraps ####
    xy <- dplyr::left_join(x = x,
                           y = y,
                           by = "ovitrap") |>
        dplyr::filter(!is.na(eggs)) |>
        dplyr::filter(!is.na(entidad)) |>
        dplyr::group_by(week) |>
        tidyr::nest() |>
        dplyr::mutate(risk = purrr::map(data,
                                        .risk_percentil,
                                        var = "eggs",
                                        en = TRUE)) |>
        dplyr::select(-data) |>
        tidyr::unnest(cols = c(risk)) |>
        janitor::clean_names() |>
        sf::st_as_sf(coords = c("pocision_x",
                                "pocision_y"),
                     crs = 4326) |>
        dplyr::mutate(popup = paste0("<b>Ovitrampa:</b> ", ovitrap,
                                     "<br><b>Semana:</b> ", week,
                                     "<br><b>Huevos:</b> ", eggs,
                                     "<br><b>Riesgo:</b> ", risk))

    # Step 4. plot the results.
    if(risk == TRUE){
        xy |>
            mapview::mapview(layer.name = "Riesgo Entomol\u00f3gico",
                             color = "white",
                             alpha = .3,
                             col.regions = c("#36C5F0", "#2EB67D",
                                             "#ECB22E", "#E01E5A"),
                             cex = "eggs",
                             zcol = "risk")
    } else {
        xy |>
            mapview::mapview(layer.name = "N\u00famero de Huevos",
                             color = "white",
                             alpha = .3,
                             col.regions = c("#36C5F0", "#2EB67D",
                                             "#ECB22E", "#E01E5A"),
                             cex = "eggs",
                             zcol = "eggs")
    }

}

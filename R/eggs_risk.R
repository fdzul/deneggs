#' eggs_risk
#'
#' @param path_vect is the directory of the ovitrampas dataset.
#' @param path_coord is the directory of the coordinates dataset.
#' @param weeks is the week.
#' @param locality is the name of locality
#' @param risk is logical value for define the risk or map the eggs.
#'
#' @return
#' @export
#'
#' @examples
eggs_risk <- function(path_vect,
                      path_coord,
                      weeks,
                      locality,
                      risk){

    # Step 1. load the ovitrap dataset ####
    x <- boldenr::read_dataset_bol(path = path_vect,
                                   dataset = "vectores",
                                   inf = "Lecturas") |>
        dplyr::filter(Localidad %in% c(locality)) |>
        dplyr::filter(Semana.Epidemiologica %in% c(weeks))

    # Step 2. load the ovitraps coordinates dataset ####

    y <- read.table(file = path_coord,
                    sep = "\t",
                    header = TRUE,
                    stringsAsFactors = FALSE,
                    fileEncoding = "UCS-2LE")


    # Step 3. joint the coordinates and ovitraps ####
    x$Ovitrampa <- as.numeric(x$Ovitrampa)
    y$Ovitrampa <- as.numeric(y$Ovitrampa)

    xy <- dplyr::left_join(x = x,
                           y = y,
                           by = "Ovitrampa") |>
        dplyr::filter(!is.na(Huevecillos)) |>
        as.data.frame() |>
        dplyr::group_by(Semana.Epidemiologica) |>
        tidyr::nest() |>
        dplyr::mutate(risk = purrr::map(data,
                                        boldenr::risk_percentil,
                                        var = "Huevecillos",
                                        en = TRUE)) |>
        dplyr::select(-data) |>
        tidyr::unnest(cols = c(risk))

    # Step 4. plot the results.
    if(risk == TRUE){
        xy |>
            sf::st_as_sf(coords = c("Pocision_X",
                                    "Pocision_Y"),
                         crs = 4326) |>
            mapview::mapview(layer.name = "Riesgo Entomológico",
                             color = "white",
                             alpha = .3,
                             col.regions = c("#36C5F0", "#2EB67D",
                                             "#ECB22E", "#E01E5A"),
                             cex = "Huevecillos",
                             zcol = "risk")
    } else {
        xy |>
            sf::st_as_sf(coords = c("Pocision_X",
                                    "Pocision_Y"),
                         crs = 4326) |>
            mapview::mapview(layer.name = "Número de Huevos",
                             color = "white",
                             alpha = .3,
                             col.regions = c("#36C5F0", "#2EB67D",
                                             "#ECB22E", "#E01E5A"),
                             cex = "Huevecillos",
                             zcol = "Huevecillos")
    }

}

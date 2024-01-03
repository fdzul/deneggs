#' read_ovitraps_coordinates
#'
#' @param path_ovitraps path of ovitraps folder
#' @param path_coord path of coordinates folder
#' @param cve_edo id of state
#' @param locality locality target
#' @param sf is a logical value, if true return a sf object else a dataframe
#'
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @return a sf o dataframe.
#' @export
#'
#' @examples 1+1
read_ovitraps_coordinates <- function(path_ovitraps,
                                      path_coord,
                                      cve_edo,
                                      locality,
                                      sf){

    # Step 1. read the ovitraps ####
    x <- deneggs::ovitraps_read(path = path_ovitraps,
                                current_year = TRUE) |>
        dplyr::mutate(Ovitrampa = as.numeric(ovitrap),
                      clave = as.numeric(clave))

    ## Step 3 load the coordinates dataset ####
    y <- read.table(file = path_coord,
                    sep = "\t",
                    header = TRUE,
                    stringsAsFactors = FALSE,
                    fileEncoding = "UCS-2LE")  |>
        dplyr::mutate(Municipio = stringr::str_trim(Municipio, side = "both"))  |>
        dplyr::mutate(Entidad = stringr::str_sub(Entidad, start = 4, end = -1),
                      Municipio = stringr::str_sub(Municipio, start = 5, end = -1),
                      Localidad = stringr::str_sub(Localidad, start = 6, end = -1))  |>
        dplyr::mutate(Localidad = stringr::str_to_title(Localidad)) |>
        dplyr::mutate(Ovitrampa = as.numeric(Ovitrampa),
                      clave = as.numeric(Clave))


    # Step 4 joint the datasets ####
    xy <- dplyr::left_join(x = x,
                           y = y,
                           by = c("Ovitrampa",
                                  "clave"))  |>
        dplyr::mutate(long = Pocision_X,
                      lat = Pocision_Y)  |>
        dplyr::filter(!is.na(long))  |>
        dplyr::filter(!is.na(eggs))  |>
        sf::st_as_sf(coords = c("long", "lat"),
                     crs = 4326)

    # Step 5. load the locality ####
    loc <- rgeomex::extract_locality(cve_edo = cve_edo,
                                     locality = locality)

    if(sf == TRUE){
        xy[loc,]
    } else{
        xy[loc, ]  |>
            sf::st_drop_geometry()  |>
            as.data.frame()
    }

}

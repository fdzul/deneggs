#' blocks_surveillance
#'
#'  this function generate the map of block surveillance
#'
#' @param locality is the locality target.
#' @param cve_edo is the numeric id of state.
#' @return
#' @export
#'
#' @examples 1+1
blocks_surveillance <- function(locality,
                                cve_edo){

    # Step 1. load the locality target ####
    loc <- rgeomex::extract_locality(locality = locality,
                                     cve_edo = cve_edo)


    # Step 2. load the blocks ine 2020 ####
    if(cve_edo %in% c(rep(26:32))){
        blocks_ine <- rgeomex::blocks_ine20_mx_e |>
            sf::st_make_valid()

    } else if(cve_edo %in% c(rep(20:25))){
        blocks_ine <- rgeomex::blocks_ine20_mx_d |>
            sf::st_make_valid()

    } else if(cve_edo %in% c(rep(15:19))){
        blocks_ine <- rgeomex::blocks_ine20_mx_c |>
            sf::st_make_valid()

    } else if(cve_edo %in% c(rep(11:14))){
        blocks_ine <- rgeomex::blocks_ine20_mx_b |>
            sf::st_make_valid()

    } else if(cve_edo %in% c("01", "02", "03", "04", "05",
                             "06", "07", "08", "09", "10")){
        blocks_ine <- rgeomex::blocks_ine20_mx_a |>
            sf::st_make_valid()

    } else{

    }

    # Step 2. extract blocks ####
    blocks <- blocks_ine[loc,]

    # Step 3 load the sectores ####

    if(cve_edo %in% c("01", "02", "03", "04", "05",
                      "06", "07", "08", "09", "10")){
        sectores <-  rgeomex::sectores_ine20_mx_a |>
            sf::st_make_valid()
    } else if(cve_edo %in% c(11:20)){
        sectores <-  rgeomex::sectores_ine20_mx_b |>
            sf::st_make_valid()
    } else if(cve_edo %in% c(21:32)){
        sectores <-  rgeomex::sectores_ine20_mx_c |>
            sf::st_make_valid()
    }


    # Step 4. extract the sectors of locality
    sectores <- sectores[loc,]

    # Step 3. load the coordinates of ovitraps of veracruz ####

    #coord <- read.table(file = path_coords,
    #                    sep = "\t",
    #                    header = TRUE,
    #                    stringsAsFactors = FALSE,
    #                    fileEncoding = "UCS-2LE") |>
    #    sf::st_as_sf(coords = c("Pocision_X", "Pocision_Y"),
    #                 crs = 4326)
    coords <- deneggs::coords

    # step 4. extract the coords of locality
    coors_loc <- coords[loc,]


    # Step 5. extract the block with ovitraps ####

    blocks_ovitraps <- blocks[coors_loc,]

    sectores_ovitraps <- sectores[coors_loc,]

    # Step 6.
    mapview::mapview(sectores,
                     legend=TRUE,
                     layer.name = "Sectores",
                     alpha.regions = 0.7,
                     col.regions = "#36C5F0",
                     color = "#36C5F0") +
        mapview::mapview(sectores_ovitraps,
                         legend=TRUE,
                         layer.name = "Sectores con Ovitrampas",
                         alpha.regions = 0.7,
                         col.regions = "#36C5F0",
                         color = "#36C5F0") +
        mapview::mapview(blocks_ovitraps,
                         legend=TRUE,
                         layer.name = "Manzanas",
                         alpha.regions = 0.7,
                         col.regions = "#63C1A0",
                         color = "#63C1A0") +
        mapview::mapview(coors_loc,
                         legend = TRUE,
                         alpha.regions = 0.7,
                         layer.name = "Ovitrampas",
                         col.regions = "#E01E5A",
                         color = "#E01E5A")



}

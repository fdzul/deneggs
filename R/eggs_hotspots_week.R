#' eggs_hotspots_week
#'
#' this function predicts the number of eggs using a geostatistical analysis with INLA & calculates the hotspots of the eggs
#'
#' @param cve_mpo is the text id of the municipality.
#' @param cve_edo is the text id of the state.
#' @param locality locality is the locality target.
#' @param hist_dataset is a logical value for define the dataset, if TRUE is the ovitraps historical dataset and we neen define the year to analyze.
#' @param year is the year to analyze.
#' @param integration_strategy is the integration strategy. The options are "grid", "eb" & "ccd"
#' @param aproximation_method aproximation is the aproximation of the joint posterior of the marginals and hyperparameter. The options are "gaussian", "simplified.laplace" & "laplace"
#' @param fam_distribution is the name of the family of the distribution for modelling count data. The option can be  poisson, zeroinflatedpoisson0, zeroinflatedpoisson1, nbinomial, zeroinflatednbinomial0 and zeroinflatednbinomial1.
#' @param path_vect  is the directory of the ovitrampas dataset.
#' @param path_coord is the directory of the coordinates dataset.
#' @param palette.viridis is the palette of viridis. The options are plasma, viridis, inferno & magma.
#' @param plot is a logical value for the plot the mesh.
#' @param cell.size is the sample number per location for predictions.
#' @param alpha.value alpha The significance level, also denoted as alpha or α, is the probability of rejecting the null hypothesis when it is true.
#' @param kvalue is the parameter for define the triagulization of delauney in the inner and the outer area in the argument max.edge in the INLA:inla.mesh.2d.
#'
#' @return a list of two object (a df of betas & a list of spde of each week)
#' @export
#' @details \link[INLA]{inla}, \link[deneggs]{eggs_hotspots}
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#' @examples 1+1
eggs_hotspots_week <- function(cve_mpo,
                               cve_edo,
                               locality,
                               hist_dataset,
                               year,
                               integration_strategy,
                               aproximation_method,
                               fam_distribution,
                               path_vect, path_coord,
                               palette.viridis,
                               plot,
                               cell.size,
                               alpha.value,
                               kvalue){

    # Step 1. define the function ####
    eggs_hotspots_week <- function(x,
                                   hist_dataset,
                                   year,
                                   path_lect_ovitraps,
                                   ent,
                                   loc,
                                   path_coord_ovitrap,
                                   aprox,
                                   int,
                                   family,
                                   k_value,
                                   palette_viridis,
                                   title,
                                   plot,
                                   cell_size_b,
                                   alpha_value){
        deneggs::eggs_hotspots(path_lect = path_lect_ovitraps,
                               cve_ent = ent,
                               locality  = loc,
                               path_coord = path_coord_ovitrap,
                               longitude  = "Pocision_X",
                               latitude =  "Pocision_Y",
                               aproximation = aprox,
                               integration = int,
                               fam = family,
                               k = k_value,
                               palette_vir  = palette_viridis,
                               leg_title = title,
                               plot = plot,
                               hist_dataset = hist_dataset,
                               year = year,
                               sem = x,
                               var = "eggs",
                               cell_size = cell_size_b,
                               alpha = alpha_value)
    }

    # Step 2. make the list of week for iterate
    if(hist_dataset == FALSE){
        z <- deneggs::ovitraps_read(path = path_vect,
                                    current_year = TRUE,
                                    year = year)  |>
            dplyr::filter(mpo %in% c(cve_mpo)) |>
            dplyr::arrange(week)

    } else {
        z <- deneggs::ovitraps_read(path = path_vect,
                                    current_year = FALSE,
                                    year = c(year))  |>
            dplyr::filter(mpo %in% c(cve_mpo)) |>
            dplyr::arrange(week)
    }

    list_week <- as.list(c(unique(z$week)))

    # Step 3. run the spde model ####
    y <- collateral::map_peacefully(.x = list_week,
                                    .f = eggs_hotspots_week,
                                    hist_dataset = hist_dataset,
                                    year = year,
                                    path_lect_ovitrap = path_vect,
                                    ent = cve_edo,
                                    loc  = locality,
                                    path_coord_ovitrap = path_coord,
                                    aprox = aproximation_method,
                                    int = integration_strategy,
                                    family = fam_distribution,
                                    k_value = kvalue,
                                    palette_viridis  = palette.viridis,
                                    title = "Huevos",
                                    plot = plot,
                                    cell_size_b = cell.size,
                                    alpha_value = alpha.value) |>
        purrr::map("result")

    # Step 3.1 add the list week names of the list of spde
    names(y) <- list_week



    # Step 4. extract betas ####
    y_betas <- purrr::map_dfr(.x = y,
                              .f = function(x){x$hotspots})

    y_betas$year <- year



    ## Step 5. return the map and the prediction values ####
    multi_return <- function() {
        my_list <- list("spde" = y,
                        "betas" = y_betas)
        return(my_list)
    }
    multi_return()

}

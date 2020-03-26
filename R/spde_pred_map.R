#' spde_pred_map
#'
#' This function predicts the number of eggs in areas where it was not collected using geostatistical analysis at INLA
#'
#' @param path_lect is the directory of the ovitrampas readings file.
#' @param loc is the locality target.
#' @param path_coord is the directory of the ovitrampas coordinates file.
#' @param path_shp is the directory of shepefile dataset.
#' @param longitude is the name of the column of the longitude in the ovitrampas dataset.
#' @param latitude is the name of the column of the longitude in the ovitrampas dataset.
#' @param k is the parameter for define the triagulization of delauney.
#' @param fam is the name of the family of the distribution for modelling count data. The option can be  poisson, zeroinflatedpoisson0, zeroinflatedpoisson1, nbinomial, zeroinflatednbinomial0 and zeroinflatednbinomial1
#' @param week is the week target. proactive is the current week.
#' @param var is the name of variable target.
#' @param leg_title is title of legend.
#' @param cell_size is the parameter for define the grid of locality for prediction.
#' @param palette_vir is the palleta of viridis. The option can be magma, plasma, inferno, and viridis.
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @seealso \link[viridis]{viridis}, \link[viridis]{plasma}, \link[viridis]{inferno}, \link[viridis]{magma}
#' @seealso \link[INLA]{inla}
#' @return a ggmap with the prediction of the number of eggs.
#' @export
#'
#' @examples
#' @details \link[INLA]{inla}.
spde_pred_map <- function(path_lect,loc, path_coord, path_shp,
                          leg_title,
                          longitude, latitude, k, fam, week, var,
                          cell_size, palette_vir){

    ## Step 0.1 load the ovitrap dataset ####
    x <- boldenr::read_dataset_bol(path = path_lect,
                                   dataset = "vectores",
                                   inf = "Lecturas") %>%
        dplyr::filter(Localidad %in% c(loc))

    ## Step 0.2 load the coordinates dataset ####
    y <- read.table(file = path_coord,
                    sep = "\t",
                    header = TRUE,
                    stringsAsFactors = FALSE,
                    fileEncoding = "UCS-2LE")
    # Step 0.3 joint the coordinates ####
    x$Ovitrampa <- as.numeric(x$Ovitrampa)
    y$Ovitrampa <- as.numeric(y$Ovitrampa)
    x <- dplyr::left_join(x = x,
                           y = y,
                           by = "Ovitrampa") %>%
        dplyr::filter(Semana.Epidemiologica %in% c(week))

    ####################################################

    ## Step 1. make the mesh ####
    mesh <- mesh(x = x,
                 k = k,
                 long = longitude,
                 lat = latitude)
    print(mesh$n)

    ## Step 2. Define the SPDE ####
    spde <- INLA::inla.spde2.matern(mesh = mesh,
                                    alpha = 2,
                                    constr = TRUE)

    ## Step 3. Define the projector matrix (aik),    ####
    #          is also called weighting factors.
    #          aik for modellig and preditive datasets

    ## 3.1. this projector matrix we use for modelling ####
    A_mod <- INLA::inla.spde.make.A(mesh = mesh,
                              loc = cbind(x[, c(longitude)],
                                          x[, c(latitude)]))


    print(dim(A_mod))

    ## 3.2. this projector matrix we use for modelling ####

    # 3.2.1 load the locality limit ####
    loc <- sf::st_read(path_shp) %>%
      dplyr::filter(NOMBRE %in% c(loc)) %>%
      sf::st_transform(crs = 4326) %>%
      dplyr::select(1:4) %>%
      sf::st_union()


    # 3.2.2 extract the coordinates of grid point prediction #####

    p <- loc_grid_points(sf = loc, cell_size = cell_size)



    # 3.2.3 make the projector matrix for use for modelling ####
    A_pred <- INLA::inla.spde.make.A(mesh = mesh,
                                     loc = sf::st_coordinates(p))
    print(dim(A_pred))

    ## Step 4. Define the Spatial Field (w) ####
    w.index <- INLA::inla.spde.make.index(name = "w",
                                    n.spde = spde$n.spde,
                                    n.group = 1,
                                    n.repl = 1)
    ## Step 5. Define the stack ####

    ## Step 5.1 Define the stack for the modelling ####
    stack_mod <- INLA::inla.stack(tag  = "fit",
                        data   = list(y = unlist(x[, c(var)])),
                        A      = list(1, A_mod),
                        effect = list(Intercept = rep(1, nrow(x)),
                                      #X         = x$hotspots,
                                      w         = w.index))

    ## Step 5.2 Define the stack for the prediction ####
    stack_pred <- INLA::inla.stack(tag  = "pred",
                                   data   = list(y = NA),
                                   A      = list(1, A_pred),
                                   effect = list(Intercept = rep(1, nrow(p)),
                                          #X         = x$hotspots,
                                          w         = w.index))
    ## Step 5.3 bind the each stack ####
    stack_full <- INLA::inla.stack(stack_mod, stack_pred)

    ## Step 6. Define the formula
    hyper1 = list(theta = list(prior="pc.prec", param=c(1, 0.01)))
    formula <- y ~ 0 + Intercept +  f(w,
                                      model = spde,
                                      hyper = hyper1)


    ## Step 7.1. Run inla with with all distribution families
    l_fam <- list("poisson",
                  "zeroinflatedpoisson0",
                  "zeroinflatedpoisson1",
                  "zeroinflatedpoisson2",
                  "nbinomial",
                  "nbinomial2",
                  "zeroinflatednbinomial0",
                  "zeroinflatednbinomial1",
                  "zeroinflatednbinomial1",
                  "nmixnb",
                  "lognormal")
    fun_mod_inla <- function(x){
        INLA::inla(formula,
             family = x,
             data  = INLA::inla.stack.data(stack_full),
             control.compute = list(dic = TRUE, waic = TRUE),
             control.predictor = list(A = INLA::inla.stack.A(stack_full),
                                      link = 1,
                                      compute = TRUE))
    }
    mod_fam <- purrr::map(.x = l_fam, .f = fun_mod_inla)
    fun_extrac_dic <- function(x){
        data.frame(dic = round(x$dic$dic, digits = 2))
    }
    purrr::map_df(mod_fam, fun_extrac_dic)
    print(cbind(purrr::map_df(mod_fam, fun_extrac_dic),
                data.frame(fam = c("poisson",
                                   "zeroinflatedpoisson0",
                                   "zeroinflatedpoisson1",
                                   "zeroinflatedpoisson2",
                                   "nbinomial",
                                   "nbinomial2",
                                   "zeroinflatednbinomial0",
                                   "zeroinflatednbinomial2",
                                   "zeroinflatednbinomial1",
                                   "nmixnb",
                                   "lognormal"))))

    ## Step 7.2. Run inla with best family
    mod <- INLA::inla(formula,
                  family = fam,
                  data  = INLA::inla.stack.data(stack_full, spde = spde),
                  control.compute = list(dic = TRUE, waic = TRUE),
                  control.predictor = list(A = INLA::inla.stack.A(stack_full),
                                           link = 1,
                                           compute = TRUE))
    print(summary(mod))

    ## Step 8.2 Make the predictions ####
    index <- INLA::inla.stack.index(stack = stack_full, tag = "pred")$data

    ## Step 2. extract the prediction ####
    p <- data.frame(sf::st_coordinates(p))
    names(p) <- c("x", "y")
    p$pred_mean <- mod$summary.fitted.values[index, "mean"]
    p$pred_ll <- mod$summary.fitted.values[index, "0.025quant"]
    p$pred_ul <- mod$summary.fitted.values[index, "0.025quant"]
    print(names(p))

    ggplot2::ggplot(data = loc) +
      ggplot2::geom_sf() +
      ggplot2::coord_sf(datum = NULL) +
      ggplot2::geom_tile(data = p,
                         ggplot2::aes(x = x,
                                      y = y,
                                      fill = pred_mean)) +
      ggplot2::labs(x = "", y ="") +
      ggplot2::scale_fill_viridis_c(leg_title,
                                    option = palette_vir) +
      ggplot2::theme_bw()
    p
    }



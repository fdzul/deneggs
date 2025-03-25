#' eggs prediction hotspots
#'
#' this function predicts the number of eggs using a geostatistical analysis with INLA and later calculates the hotspots of the eggs
#'
#' @param path_lect is the directory of the ovitrampas readings file.
#' @param year is the year to analyze
#' @param locality is the locality target.
#' @param cve_ent is the text id of the state.
#' @param path_coord is the directory of the ovitrampas coordinates file.
#' @param leg_title is title of legend.
#' @param fam is the name of the family of the distribution for modelling count data. The option can be  poisson, zeroinflatedpoisson0, zeroinflatedpoisson1, nbinomial, zeroinflatednbinomial0 and zeroinflatednbinomial1
#' @param alpha alpha The significance level, also denoted as alpha or α, is the probability of rejecting the null hypothesis when it is true.
#' @param plot is a logical value for the plot the mesh.
#' @param aproximation aproximation is the aproximation of the joint posterior of the marginals and hyperparameter. The options are "gaussian", "simplified.laplace" & "laplace".
#' @param integration integration is the integration strategy. The options are "grid", "eb" & "ccd".
#' @param longitude is the name of the column of the longitude in the ovitrampas dataset.
#' @param latitude is the name of the column of the latitude in the ovitrampas dataset.
#' @param k is the parameter for define the triagulization of delauney in the inner and the outer area in the argument max.edge in the INLA:inla.mesh.2d.
#' @param sem is the week you want to analyze
#' @param var is the name of column where is the variable target (eggs count).
#' @param cell_size is the sample number per location (area of locality/n)
#' @param palette_vir is the palette.
#' @param hist_dataset is a logical value for define the dataset, if TRUE is the ovitraps historical dataset and we neen define the year to analyze.
#'
#' @return a list of object (data, map, loc, dics, hotspots). data is original dataset (ovitraps + coordinates). The map is the map of eggs prediction. Loc is the sf objecto of locality limit. dics is the Deviancie Information Criterio of the model. the hotspots object is the dataset with the eggs prediction and the hotspots.
#' @export
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @seealso \link[viridis]{viridis}, \link[viridis]{plasma}, \link[viridis]{inferno}, \link[viridis]{magma}
#' @seealso \link[INLA]{inla}
#'
#' @examples 1+1
#' @details \link[INLA]{inla}.
eggs_hotspots <- function(path_lect, year = NULL, locality, path_coord,cve_ent,
                         leg_title, fam, alpha, plot = NULL,
                         aproximation, integration,
                         longitude, latitude, k, sem, var,
                         cell_size, palette_vir, hist_dataset){


    ## Step 0.1 load the ovitrap dataset ####

    if(hist_dataset == FALSE){
        x <- deneggs::ovitraps_read(path = path_lect,
                                    current_year = TRUE)  |>
            dplyr::arrange(week)  |>
            dplyr::filter(week %in% c(sem)) |>
            dplyr::mutate(ovitrap = as.numeric(ovitrap)) |>
            dplyr::mutate(clave = as.numeric(clave))

    } else {
        x <- deneggs::ovitraps_read(path = path_lect,
                                    current_year = FALSE,
                                    year = c(year))  |>
            dplyr::arrange(week)  |>
            dplyr::filter(week %in% c(sem)) |>
            dplyr::mutate(ovitrap = as.numeric(ovitrap)) |>
            dplyr::mutate(clave = as.numeric(clave))
    }


    # Step 0. 2 load the locality limit ####
    loc <- rgeomex::extract_locality(cve_edo = cve_ent,
                                     locality = locality)
    #loc <- rgeomex::loc_inegi19_mx  |>
    #    dplyr::filter(NOMGEO %in% c(similiars::find_most_similar_string(locality, unique(NOMGEO))) &
    #                      CVE_ENT %in% c(cve_ent))

    if(nrow(loc) > 1){
        loc <- loc  |>  sf::st_union()
    } else {
        loc
    }

    loc_sp <- sf::as_Spatial(from = sf::st_geometry(loc), cast = TRUE)

    ## Step 0.2 load the coordinates dataset ####
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
        dplyr::rename(clave = Clave) |>
        dplyr::rename(ovitrap = Ovitrampa)


    # Step 0.3 joint the coordinates ####
    #x$ovitrap <- as.numeric(x$ovitrap)
    #y$clave <- as.numeric(y$clave)


    x <- dplyr::left_join(x = x,
                          y = y,
                          by = "ovitrap")  |>
        dplyr::mutate(long = Pocision_X,
                      lat = Pocision_Y)  |>
        dplyr::filter(!is.na(long))  |>
        dplyr::filter(!is.na(eggs))  |>
        sf::st_as_sf(coords = c("long", "lat"),
                     crs = 4326)
    x <- x[loc, ]  |>
        sf::st_drop_geometry()  |>
        as.data.frame()

    ####################################################

    ## Step 1. make the mesh ####
    mesh <- deneggs::mesh(x = x,
                          k = k,
                          loc_limit = loc_sp,
                          plot = plot,
                          long = longitude,
                          lat = latitude)
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

    # 3.2.2 extract the coordinates of grid point prediction #####

    #p <- deneggs::loc_grid_points(sf = loc, cell_size = cell_size)
    set.seed(123456)
    #p <- sf::st_sample(x = loc, size = cell_size, type = "regular") |>
    #    sf::st_as_sf()

    # Step 2. load the raster ####
    if(cve_ent == "01"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_01.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "02"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_02.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "03"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_03.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "04"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_04.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "05"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_05.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "06"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_06.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "07"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_07.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "08"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_08.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "09"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_09.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "10"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_10.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "11"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_11.tif",
                                       package = "deneggs"))
    }


    if(cve_ent == "12"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_12.tif",
                                       package = "deneggs"))
    }


    if(cve_ent == "13"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_13.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "14"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_14.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "15"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_15.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "16"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_16.tif",
                                       package = "deneggs"))
    }


    if(cve_ent == "17"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_17.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "18"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_18.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "19"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_19.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "20"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_20.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "21"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_21.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "22"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_22.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "23"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_23.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "24"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_24.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "25"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_25.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "26"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_26.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "27"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_27.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "28"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_28.tif",
                                       package = "deneggs"))
    }


    if(cve_ent == "29"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_29.tif",
                                       package = "deneggs"))
    }

    if(cve_ent == "30"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_30.tif",
                                       package = "deneggs"))
    }
    if(cve_ent == "31"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_31.tif",
                                       package = "deneggs"))
    }
    if(cve_ent == "32"){
        lyr <- terra::rast(system.file("extdata",
                                       "lyr_32.tif",
                                       package = "deneggs"))
    }

    extract_coord <- function(raster,
                              loc){
        terra::crop(x = raster,
                    y = loc,
                    mask = TRUE) |>
            terra::as.data.frame(xy = TRUE) |>
            dplyr::select(x, y) |>
            sf::st_as_sf(coords = c("x", "y"),
                         crs = 4326)

    }

    rast_loc <- terra::crop(x = lyr,
                            y = loc,
                            mask = TRUE)

    p <- rast_loc |>
        terra::as.data.frame(xy = TRUE) |>
        dplyr::select(x, y) |>
        sf::st_as_sf(coords = c("x", "y"),
                     crs = 4326)

    p <- p[loc,]


    # 3.2.3 make the projector matrix for use prediction ####
    A_pred <- INLA::inla.spde.make.A(mesh = mesh,
                                     loc = sf::st_coordinates(p))

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
    hyper1 = list(theta = list(prior = "pc.prec",
                               param = c(1, 0.01)))
    formula <- y ~ 0 + Intercept +  f(w,
                                      #hyper = hyper1,
                                      model = spde)

    ## Step 7.2. Run inla with best family
    mod <- INLA::inla(formula,
                      family = fam,
                      #verbose = TRUE,
                      data  = INLA::inla.stack.data(stack_full, spde = spde),
                      control.compute = list(dic = TRUE,
                                             #openmp.strategy = "huge",
                                             waic = TRUE),
                      control.inla = list(strategy = aproximation,
                                          int.strategy = integration),
                      control.predictor = list(A = INLA::inla.stack.A(stack_full),
                                               link = 1,
                                               compute = TRUE))


    ## Step 8. Make the predictions ####

    ## Step 8.1 extract the index of predictions ####
    index <- INLA::inla.stack.index(stack = stack_full, tag = "pred")$data

    ## Step 8.2. extract the predictions ####
    p <- data.frame(sf::st_coordinates(p))
    names(p) <- c("x", "y")
    p$pred_mean <- mod$summary.fitted.values[index, "mean"]
    p$pred_sd <- mod$summary.fitted.values[index, "sd"]
    p$pred_ll <- mod$summary.fitted.values[index, "0.025quant"]
    p$pred_ul <- mod$summary.fitted.values[index, "0.975quant"]
    p$week <- sem
    p$fam <- fam
    p$dic <- mod$dic$dic

    ## Step 8.3. map the predictions ####
    map <- ggplot2::ggplot() +
        ggplot2::geom_tile(data = p,
                           ggplot2::aes(x = x,
                                        y = y,
                                        fill = pred_mean)) +
        ggplot2::scale_fill_viridis_c(leg_title,
                                      option = palette_vir) +
        ggplot2::geom_sf(data = loc,
                         fill = NA,
                         col = "black", lwd = 1.5) +
        ggplot2::theme_void()

    hotspots_eggs <- function(x, var, alpha){

        vtess <- deldir::deldir(x$x, x$y)


        voronoipolygons = function(thiess) {
            w = deldir::tile.list(thiess)
            polys = vector(mode='list', length=length(w))
            for (i in seq(along=polys)) {
                pcrds = cbind(w[[i]]$x, w[[i]]$y)
                pcrds = rbind(pcrds, pcrds[1,])
                polys[[i]] = sp::Polygons(list(sp::Polygon(pcrds)), ID=as.character(i))
            }
            SP = sp::SpatialPolygons(polys)
            voronoi = sp::SpatialPolygonsDataFrame(SP, data=data.frame(dummy = seq(length(SP)), row.names=sapply(slot(SP, 'polygons'),
                                                                                                                 function(x) slot(x, 'ID'))))
        }


        v <- voronoipolygons(vtess)

        vtess.sf <- sf::st_as_sf(v)

        # Contiguity weights for Thiessen polygons ####
        st_queen <- function(a, b = a) sf::st_relate(a, b, pattern = "F***T****")
        queen.sgbp <- st_queen(vtess.sf)

        as.nb.sgbp <- function(x, ...) {
            attrs <- attributes(x)
            x <- lapply(x, function(i) { if(length(i) == 0L) 0L else i } )
            attributes(x) <- attrs
            class(x) <- "nb"
            x
        }

        queen.nb <- as.nb.sgbp(queen.sgbp)

        ###
        swm_gi <- spdep::nb2listw(queen.nb, style = "B", zero.policy = TRUE)


        getis_ord <- function(x, var){
            x[is.na(x)] <- 0
            y <- spdep::localG(x  = (unlist(x[, c(var)]) - mean(unlist(x[, c(var)]),
                                                                na.rm = TRUE))/sd(unlist(x[,c(var)]),
                                                                                  na.rm = TRUE),
                               listw = swm_gi,
                               zero.policy = TRUE)
            attributes(y) <- NULL

            y
        }


        x$z_score <- getis_ord(x, var = var)


        # The critical values for cutt off of Getis values ####
        ## Bonferroni-corrected z-value (Getis & Ord, 1995)
        getis_ord_umbral <- function(n, alpha){
            round(qnorm(p = -((1-alpha)/n) + 1, mean = 0, sd = 1), digits = 4)
        }
        cutt_off <- getis_ord_umbral(n = nrow(x), alpha = alpha)

        # detect the hotspot based in the cutt_off of benferroni ####

        x <- x  |>
            dplyr::mutate(hotspots = ifelse(z_score >= cutt_off,
                                            "Hotspots",
                                            "No Hotspots"))
        #names(x) <- c("x", "y", "pred_mean", "pred_sd","pred_ll","pred_ul",
        #              "week","fam","dic","z_score","hotspots")
        x  |>  as.data.frame()

    }

    ## Step 9. return the map and the prediction values ####
    multi_return <- function() {
        my_list <- list("data" = x,
                        "map" = map,
                        "loc" = loc,
                        "rast_loc" = rast_loc,
                        "mod" = mod,
                        "mesh" = mesh,
                        "dics" = mod$dic$dic,
                        "hotspots" =  hotspots_eggs(x = p,
                                                    var = "pred_mean",
                                                    alpha = alpha))
        return(my_list)
    }
    multi_return()

}

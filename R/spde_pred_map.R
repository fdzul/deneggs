#' spde_pred_map
#'
#' This function predicts the number of eggs in areas where it was not collected using geostatistical analysis with INLA
#'
#' @param path_lect is the directory of the ovitrampas readings file.
#' @param locality is the locality target.
#' @param cve_ent is the text id of the state.
#' @param path_coord is the directory of the ovitrampas coordinates file.
#' @param longitude is the name of the column of the longitude in the ovitrampas dataset.
#' @param latitude is the name of the column of the longitude in the ovitrampas dataset.
#' @param k is the parameter for define the triagulization of delauney.
#' @param week is the week target. proactive is the current week.
#' @param var is the name of variable target.
#' @param leg_title is title of legend.
#' @param cell_size is the parameter for define the grid of locality for prediction.
#' @param palette_vir is the palette of viridis. The option can be magma, plasma, inferno, and viridis.
#' @param plot is a logical argument. if TRUE plot the mesh else no plot the mesh.
#' @param alpha The significance level, also denoted as alpha or α, is the probability of rejecting the null hypothesis when it is true.
#' @param aproximation is the aproximation of the joint posterior of the marginals and hyperparameter. The options are "gaussian", "simplified.laplace" & "laplace".
#' @param integration is the integration strategy. The options are "grid", "eb" & "ccd".
#'
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @seealso \link[viridis]{viridis}, \link[viridis]{plasma}, \link[viridis]{inferno}, \link[viridis]{magma}
#' @seealso \link[INLA]{inla}
#' @return a list with the gmap with the prediction of the number of eggs, the prediction of number of eggs, the mesh.
#' @export
#'
#' @importFrom methods slot
#' @importFrom stats qnorm
#' @importFrom stats sd
#'
#' @examples 1+ 1
#' @details \link[INLA]{inla}.
spde_pred_map <- function(path_lect,locality, path_coord,cve_ent,
                          leg_title, alpha, plot = NULL,
                          aproximation, integration,
                          longitude, latitude, k, week, var,
                          cell_size, palette_vir){

    ## Step 0.1 load the ovitrap dataset ####
    x <- boldenr::read_dataset_bol(path = path_lect,
                                   dataset = "vectores",
                                   inf = "Lecturas")


    # Step 0. 2 load the locality limit ####
    loc <- rgeomex::loc_inegi19_mx |>
      dplyr::filter(NOMGEO %in% c(similiars::find_most_similar_string(locality, unique(NOMGEO))) &
                      CVE_ENT %in% c(cve_ent))

    if(nrow(loc) > 1){
      loc <- loc |> sf::st_union()
    } else {

    }

    loc_sp <- sf::as_Spatial(from = sf::st_geometry(loc), cast = TRUE)

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
                          by = "Ovitrampa") |>
      dplyr::filter(Semana.Epidemiologica %in% c(week)) |>
      dplyr::mutate(long = Pocision_X,
                    lat = Pocision_Y) |>
      dplyr::filter(!is.na(long)) |>
      sf::st_as_sf(coords = c("long", "lat"),
                   crs = 4326)
    x <- x[loc, ] |>
      sf::st_drop_geometry() |>
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
    p <- sf::st_sample(x = loc, size = cell_size, type = "regular") |>
        sf::st_as_sf()



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
                                      model = spde,
                                      hyper = hyper1)


    ## Step 7.1. Run inla with with all distribution families
    l_fam <- list("poisson",
                  "zeroinflatedpoisson0",
                  "zeroinflatedpoisson1",
                  #"zeroinflatedpoisson2",
                  #"nmixnb",
                  #"lognormal",
                  "nbinomial",
                  "nbinomial2",
                  "zeroinflatednbinomial0",
                  #"zeroinflatednbinomial2",
                  "zeroinflatednbinomial1")
    fun_mod_inla <- function(x){
        INLA::inla(formula,
             family = x,
             data  = INLA::inla.stack.data(stack_full),
             control.compute = list(dic = TRUE, waic = TRUE,
                                    openmp.strategy="huge"),
             control.predictor = list(A = INLA::inla.stack.A(stack_full),
                                      link = 1,
                                      compute = TRUE))
    }
    mod_fam <- purrr::map(.x = l_fam, .f = fun_mod_inla)
    fun_extrac_dic <- function(x){
        data.frame(dic = round(x$dic$dic, digits = 2))
    }
    dics <- cbind(purrr::map_df(mod_fam, fun_extrac_dic),
                  data.frame(fam = c("poisson",
                                     "zeroinflatedpoisson0",
                                     "zeroinflatedpoisson1",
                                     #"zeroinflatedpoisson2",
                                     #"nmixnb",
                                     #"lognormal",
                                     "nbinomial",
                                     "nbinomial2",
                                     "zeroinflatednbinomial0",
                                     #"zeroinflatednbinomial2",
                                     "zeroinflatednbinomial1")))

    ###

    if(nrow(dics[dics$dic == min(dics$dic),]) == 2){
      fam <- dics[dics$dic == min(dics$dic),][2,2]
    } else {
      fam <- dics[dics$dic == min(dics$dic),][,2]
    }

    ## Step 7.2. Run inla with best family
    mod <- INLA::inla(formula,
                  family = fam,
                  data  = INLA::inla.stack.data(stack_full, spde = spde),
                  control.compute = list(dic = TRUE, waic = TRUE,
                                         openmp.strategy="huge"),
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
    p$pred_ul <- mod$summary.fitted.values[index, "0.095quant"]
    p$week <- week
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

    ##
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
        y <- as.data.frame(y)
        y
      }

      #y2 <- getis_ord(x, var = var)

      x$z_score <- getis_ord(x, var = var)
      x

      # The critical values for cutt off of Getis values ####
      ## Bonferroni-corrected z-value (Getis & Ord, 1995)
      getis_ord_umbral <- function(n, alpha){
        round(qnorm(p = -((1-alpha)/n) + 1, mean = 0, sd = 1), digits = 4)
      }
      cutt_off <- getis_ord_umbral(n = nrow(x), alpha = alpha)

      # detect the hotspot based in the cutt_off of benferroni ####
      hotspots_gi <- function(x){
        as.numeric(ifelse(x >= cutt_off, 1, 0))
      }

      x |>
        dplyr::mutate(hotspots = ifelse(z_score >= cutt_off, "Hotspots", "No Hotspots"))


    }




    ## Step 9. return the map and the prediction values ####
    multi_return <- function() {
      my_list <- list("data" = x,
                      "mesh" = mesh,
                      "map" = map,
                      "loc" = loc,
                      "dics" = dics,
                      "hotspots" =  hotspots_eggs(x = p, var = "pred_mean", alpha = alpha))
      return(my_list)
    }
    multi_return()
    }

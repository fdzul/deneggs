#' fm_mesh
#'
#' This function create the mesh for modelling with INLA framework
#'
#' @param x is the sf object and the target variable.
#' @param k is the parameter for defining the delaunay triagulization.
#' @param loc is the locality (sf).
#' @param plot is a logical argument. if TRUE plot the mesh else no plot the mesh.
#'
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @return a mesh and plot of the mesh.
#' @export
#' @seealso \link[INLA]{inla.mesh.2d} & \link[fmesher]{fm_mesh_2d_inla}
#' @details this function use \link[INLA]{inla} & \link[fmesher]{fmesher}
#' @examples 1+1
fm_mesh <- function(x, k, loc, plot = NULL){

    mesh <- fmesher::fm_mesh_2d_inla(loc = sf::st_coordinates(x),
                                     boundary = loc,
                                     max.edge = c(0.3/k, 2/k), ## mandatory
                                     cutoff= 0.1/k,
                                     crs = fmesher::fm_CRS("longlat_globe"))

    if(plot == TRUE){
        ggplot2::ggplot() +
            inlabru::gg(mesh) +
            ggplot2::geom_sf(data = x,
                             fill = "red",
                             alpha = 0.5,
                             shape = 21,
                             col = "white") +
            ggspatial::annotation_scale(style = "ticks")
    } else {

    }

    mesh
}

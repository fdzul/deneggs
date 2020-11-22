#' mesh
#'
#' This function create the mesh for modelling with INLA framework
#'
#' @param x is the dataset with the coordinates and the target variable.
#' @param k is the parameter for defining the delaunay triagulization.
#' @param long is the longitude.
#' @param lat is the latitude.
#' @param loc_limit is the locality limit.
#' @param plot is a logical argument. if TRUE plot the mesh else no plot the mesh.
#'
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @return a mesh and plot of the mesh.
#' @export
#' @seealso \link[INLA]{inla.mesh.2d}
#' @details this function use \link[INLA]{inla}.
#' @examples
mesh <- function(x, k, long, lat, loc_limit, plot = NULL){
    #x$X <- x$long
    #x$Y <- x$lat
    coor <- cbind(x[,c(long)], x[, c(lat)])
    #coor <- cbind(x$Pocision_X, x$Pocision_Y)
    mesh <- INLA::inla.mesh.2d(coor, ## provide locations or domain #
                               boundary = loc_limit,
                               max.edge = c(0.3/k, 2/k), ## mandatory
                               cutoff= 0.1/k) ## good to have >0
    if(plot == TRUE){
        plot(mesh, asp=1, main = ""); points(coor, col= "red")
    } else {

    }

    mesh
}

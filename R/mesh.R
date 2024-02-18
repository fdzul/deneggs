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
#' @examples 1+1
mesh <- function(x, k, long, lat, loc_limit, plot = NULL){
    coor <- cbind(x[,c(long)], x[, c(lat)])
    #mesh <- INLA::inla.mesh.2d(coor, ## provide locations or domain #
    #                           boundary = loc_limit,
    #                           max.edge = c(0.3/k, 2/k), ## mandatory
    #                           cutoff= 0.1/k,
    #                           crs = "+proj=longlat +datum=WGS84") ## good to have >0

    mesh <- fmesher::fm_mesh_2d_inla(loc = coor,
                                     boundary = loc_limit,
                                     max.edge = c(0.3/k, 2/k), ## mandatory
                                     cutoff= 0.1/k,
                                     crs = fmesher::fm_CRS("longlat_globe"))

    if(plot == TRUE){
        #plot(mesh, asp=1, main = ""); points(coor, col= "red")
        ggplot2::ggplot() +
            inlabru::gg(mesh) +
            ggplot2::geom_point(data = as.data.frame(coor),
                                ggplot2::aes(x = Pocision_X,
                                             y = Pocision_Y),
                                col = "red")
    } else {

    }

    mesh
}

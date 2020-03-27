#' loc_grid_points
#'
#' this function make the prediction grid for spde modelling
#'
#' @param sf the sf locality.
#' @param cell_size  number of cell.
#'
#' @return a points
#' @export
#'
#' @examples
loc_grid_points <- function(sf, cell_size){
    sf <- sf::st_transform(sf, crs = 4326)
    bb <- sf::st_bbox(sf)
    x <- seq(bb$xmin -1, bb$xmax + 1, length.out = cell_size)
    y <- seq(bb$ymin -1, bb$ymax + 1, length.out = cell_size)
    p <- as.matrix(expand.grid(x, y))
    #plot(p, asp = 1)
    p <- sf::st_as_sf(data.frame(x = p[,1], y = p[,2]),
                      coords = c("x", "y"),
                      crs = 4326)
    ind <- sf::st_intersects(sf, p)
    p <- p[ind[[1]],]
    plot(p, asp = 1)
    p
}

#' Cluster analysis for egg hotspot intensity and entomological risk
#'
#' @param x is the eggs hotspots dataset
#'
#' @return a sf object
#' @export
#'
#' @examples 1+1
cluster_risk <- function(x){
    # Step 1. calculate the intensity
    intensity_function <- function(x){
        x |>
            dplyr::mutate(hotspots_binary = ifelse(hotspots == "Hotspots", 1, 0)) |>
            dplyr::select(x, y, week, hotspots_binary) |>
            #dplyr::distinct(x, y, .keep_all = TRUE) |>
            tidyr::pivot_wider(id_cols = c(x, y),
                               names_from = "week",
                               names_prefix = "week_",
                               values_from = "hotspots_binary") |>
            dplyr::mutate(intensity = rowSums(dplyr::across(dplyr::starts_with("week_")), na.rm = TRUE)) |>
            dplyr::mutate(n_week = length(dplyr::across(dplyr::starts_with("week_")))) |>
            dplyr::mutate(per_intensity = round(intensity/n_week, digits = 1)) |>
            dplyr::select(x, y, intensity,n_week, per_intensity) |>
            as.data.frame()
    }

    x <- x |>
        dplyr::group_by(year) |>
        tidyr::nest() |>
        dplyr::mutate(intensity = purrr::map(data,intensity_function)) |>
        dplyr::select(-data) |>
        tidyr::unnest(cols = c(intensity)) |>
        tidyr::pivot_wider(id_cols = c("x", "y"),
                           names_from = year,
                           values_from = intensity)
    # Step 2. make the clustering of intensity ####
    set.seed(12345)
    res_mediods <- cluster::pam(x |> dplyr::select(-x, -y),
                                metric = "euclidean",
                                k = 5)

    # Step 3. add the cluster in the hotspots datasets ####
    x |>
        dplyr::mutate(cluster = res_mediods$cluster) |>
        dplyr::mutate(risk = dplyr::case_when(cluster == 1 ~ "Muy Bajo",
                                              cluster == 2 ~ "Bajo",
                                              cluster == 3 ~ "Alto",
                                              cluster == 4 ~ "Medio",
                                              cluster == 5 ~ "Muy Alto")) |>
        dplyr::mutate(risk = factor(risk,
                                    levels = c("Muy Bajo","Bajo", "Medio",
                                               "Alto",  "Muy Alto"),
                                    labels = c("Muy Bajo","Bajo", "Medio",
                                               "Alto",  "Muy Alto"))) |>
        dplyr::mutate(long = x,
                      lat = y) |>
        sf::st_as_sf(coords = c("long", "lat"),
                     crs = 4326)
}

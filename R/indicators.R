#' The function provides entomological indicators for entomological surveillance with ovitraps.
#'
#' @param path_ovitraps is the path of the folder where the data is located.
#' @param scale is the resolution of the analysis (ovitrap for house/ovitraps and block for blocks).
#' @param locality is the location of interest.
#' @param fac_axes is a numeric value to control the height of the secondary axis
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @returns a ggplot object
#' @export
#'
#' @examples 1+1
indicators <- function(path_ovitraps, scale, locality,fac_axes){
    if(scale == "ovitrap"){
        # Step 1. Load the ovitrap dataset ####
        z <- deneggs::ovitraps_read(path = path_ovitraps,
                                    current_year = TRUE) |>
            dplyr::mutate(sec_manz = paste(sector, manzana, sep = "")) |>
            dplyr::group_by(week, Localidad) |>
            dplyr::summarise(n_blocks = data.table::uniqueN(sec_manz),
                             n_block_positive = data.table::uniqueN(sec_manz[eggs > 0]),
                             n_ovitraps_install = length(unique(ovitrap)),
                             n_ovitraps_positive = sum(eggs > 0, na.rm = TRUE),
                             n_ovitraps_negative = sum(eggs <= 0, na.rm = TRUE),
                             n_ovitraps_lectura = n_ovitraps_positive + n_ovitraps_negative,
                             sum_ovitrap_positive = sum(eggs, na.rm = TRUE),
                             perc_lectura =  round(n_ovitraps_lectura/n_ovitraps_install, 2)*100,
                             perc_OP = round(n_ovitraps_positive/n_ovitraps_lectura, 2)*100,
                             perc_MP = round(n_block_positive/n_blocks, 2),
                             avg_HOP = round(sum_ovitrap_positive/n_ovitraps_positive,1),
                             avg_HMP = round(sum_ovitrap_positive/n_block_positive,1),
                             .groups = "drop") |>
            #dplyr::rename(locality = Localidad) |>
            dplyr::select(week, Localidad, avg_HOP, avg_HMP, perc_OP, perc_MP, perc_lectura) |>
            tidyr::pivot_longer(cols =  c("avg_HOP", "avg_HMP",
                                          "perc_OP", "perc_MP",
                                          "perc_lectura"),
                                names_to = "indicador") |>
            dplyr::mutate(scale = dplyr::case_when(indicador %in% c("avg_HOP", "perc_OP") ~ "ovitrap",
                                                   indicador %in% c("avg_HMP", "perc_MP") ~ "block",
                                                   T ~ "Ambos")) |>
            tidyr::separate(col = "indicador", into = c("indicador", NA)) |>
            dplyr::mutate(indicador = dplyr::case_when(indicador == "avg" ~ "abundancy",
                                                       indicador == "perc" ~ "ocupancy")) |>
            dplyr::filter(Localidad %in% c(locality))

        y <- z |>
            dplyr::filter(indicador == "abundancy") |>
            dplyr::filter(scale == "ovitrap")

        x <- z |>
            dplyr::filter(indicador == "ocupancy") |>
            dplyr::filter(scale == "ovitrap")

        ########
        ggplot2::ggplot(data = x) +
            ggplot2::geom_col(ggplot2::aes(x = week,
                                           y = value),
                              linewidth = 2,
                              fill = "#2EB67D") +
            ggplot2::geom_col(ggplot2::aes(x = week,
                                           y = value),
                              size = 5,
                              fill = "#2EB67D") +
            ggplot2::geom_line(data = y,
                               ggplot2::aes(x = week,
                                            y = value/fac_axes),
                               linewidth = 2,
                               col = "#E01A59") +
            ggplot2::geom_point(data = y,
                                ggplot2::aes(x = week,
                                             y = value/fac_axes),
                                size = 5,
                                shape = 21,
                                col = "white",
                                stroke = 0.7,
                                fill = "#E01A59") +
            #ggplot2::facet_wrap("DES_MPO_RES",
            #                    scales = "free_y") +
            ggplot2::theme(legend.position.inside = c(.1, .9),
                           legend.background = ggplot2::element_blank()) +
            ggplot2::scale_x_continuous(breaks = seq(from = 0,
                                                     to = lubridate::epiweek(Sys.Date()),
                                                     by = 2)) +
            ggplot2::xlab("Semanas Epidemiológicas") +
            ggplot2::theme(strip.text = ggplot2::element_text(size = 12)) +
            ggplot2::scale_y_continuous(name = "Porcentaje de Positividad por Ovitrampa",
                                        # Add a second axis and specify its features
                                        sec.axis = ggplot2::sec_axis(~.*fac_axes,
                                                                     name="Promedio de Huevos por Ovitrampa")) +
            ggplot2::theme(axis.title.y = ggplot2::element_text(color = "#2EB67D",
                                                                size=13),
                           axis.title.y.right = ggplot2::element_text(color = "#E01A59",
                                                                      size=13),
                           axis.text.y.right = ggplot2::element_text(color = "#E01A59",
                                                                     size=10),
                           axis.text.y = ggplot2::element_text(color = "#2EB67D",
                                                               size=10))
    } else {
        # Step 1. Load the ovitrap dataset ####
        z <- deneggs::ovitraps_read(path = path_ovitraps,
                                    current_year = TRUE) |>
            dplyr::mutate(sec_manz = paste(sector,
                                           manzana,
                                           sep = "")) |>
            dplyr::group_by(week, Localidad) |>
            dplyr::summarise(n_blocks = data.table::uniqueN(sec_manz),
                             n_block_positive = data.table::uniqueN(sec_manz[eggs > 0]),
                             n_ovitraps_install = length(unique(ovitrap)),
                             n_ovitraps_positive = sum(eggs > 0, na.rm = TRUE),
                             n_ovitraps_negative = sum(eggs <= 0, na.rm = TRUE),
                             n_ovitraps_lectura = n_ovitraps_positive + n_ovitraps_negative,
                             sum_ovitrap_positive = sum(eggs, na.rm = TRUE),
                             perc_lectura =  round(n_ovitraps_lectura/n_ovitraps_install, 2)*100,
                             perc_OP = round(n_ovitraps_positive/n_ovitraps_lectura, 2)*100,
                             perc_MP = round(n_block_positive/n_blocks, 2),
                             avg_HOP = round(sum_ovitrap_positive/n_ovitraps_positive,1),
                             avg_HMP = round(sum_ovitrap_positive/n_block_positive,1),
                             .groups = "drop") |>
            #dplyr::rename(locality = Localidad) |>
            dplyr::select(week, Localidad, avg_HOP, avg_HMP, perc_OP, perc_MP, perc_lectura) |>
            tidyr::pivot_longer(cols =  c("avg_HOP", "avg_HMP",
                                          "perc_OP", "perc_MP",
                                          "perc_lectura"),
                                names_to = "indicador") |>
            dplyr::mutate(scale = dplyr::case_when(indicador %in% c("avg_HOP", "perc_OP") ~ "ovitrap",
                                                   indicador %in% c("avg_HMP", "perc_MP") ~ "block",
                                                   T ~ "Ambos")) |>
            tidyr::separate(col = "indicador", into = c("indicador", NA)) |>
            dplyr::mutate(indicador = dplyr::case_when(indicador == "avg" ~ "abundancy",
                                                       indicador == "perc" ~ "ocupancy")) |>
            dplyr::filter(Localidad %in% c(locality))

        y <- z |>
            dplyr::filter(indicador == "abundancy") |>
            dplyr::filter(scale == "block")

        x <- z |>
            dplyr::filter(indicador == "ocupancy") |>
            dplyr::filter(scale == "block")

        ########
        ggplot2::ggplot(data = x) +
            ggplot2::geom_col(ggplot2::aes(x = week,
                                           y = value),
                              linewidth = 2,
                              fill = "#2EB67D") +
            ggplot2::geom_col(ggplot2::aes(x = week,
                                           y = value),
                              size = 5,
                              fill = "#2EB67D") +
            ggplot2::geom_line(data = y,
                               ggplot2::aes(x = week,
                                            y = value/fac_axes),
                               linewidth = 2,
                               col = "#E01A59") +
            ggplot2::geom_point(data = y,
                                ggplot2::aes(x = week,
                                             y = value/fac_axes),
                                size = 5,
                                shape = 21,
                                col = "white",
                                stroke = 0.7,
                                fill = "#E01A59") +
            #ggplot2::facet_wrap("DES_MPO_RES",
            #                    scales = "free_y") +
            ggplot2::theme(legend.position.inside = c(.1, .9),
                           legend.background = ggplot2::element_blank()) +
            ggplot2::scale_x_continuous(breaks = seq(from = 0,
                                                     to = lubridate::epiweek(Sys.Date()),
                                                     by = 2)) +
            ggplot2::xlab("Semanas Epidemiológicas") +
            ggplot2::theme(strip.text = ggplot2::element_text(size = 12)) +
            ggplot2::scale_y_continuous(name = "Porcentaje de Positividad por Manzana",
                                        # Add a second axis and specify its features
                                        sec.axis = ggplot2::sec_axis(~.*fac_axes,
                                                                     name="Promedio de Huevos por Manzana")) +
            ggplot2::theme(axis.title.y = ggplot2::element_text(color = "#2EB67D",
                                                                size=13),
                           axis.title.y.right = ggplot2::element_text(color = "#E01A59",
                                                                      size=13),
                           axis.text.y.right = ggplot2::element_text(color = "#E01A59",
                                                                     size=10),
                           axis.text.y = ggplot2::element_text(color = "#2EB67D",
                                                               size=10))
    }
}

#' ovitraps_occupancy_abundancy
#'
#' @param path_ovitraps is the path  of the ovitrap file.
#' @param scale is a string that define the scale, there are two options ovitraps & blocks
#'
#' @return
#' @export
#'
#' @examples
ovitraps_occupancy_abundancy <- function(path_ovitraps
                                         scale){

    # Step 1. Load the ovitrap dataset ####
    y <- boldenr::read_dataset_bol(path = path_ovitraps,
                                   dataset = "vectores",
                                   inf = "Lecturas") |>
        dplyr::mutate(sec_manz = paste(Sector, Manzana, sep = "")) |>
        dplyr::group_by(Semana.Epidemiologica, Localidad) |>
        dplyr::summarise(n_blocks = data.table::uniqueN(sec_manz),
                         n_block_positive = data.table::uniqueN(sec_manz[Huevecillos > 0]),
                         n_ovitraps_install = length(unique(Ovitrampa)),
                         n_ovitraps_positive = sum(Huevecillos > 0, na.rm = TRUE),
                         n_ovitraps_negative = sum(Huevecillos <= 0, na.rm = TRUE),
                         n_ovitraps_lectura = n_ovitraps_positive + n_ovitraps_negative,
                         sum_ovitrap_positive = sum(Huevecillos, na.rm = TRUE),
                         perc_lectura =  round(n_ovitraps_lectura/n_ovitraps_install, 2)*100,
                         perc_OP = round(n_ovitraps_positive/n_ovitraps_lectura, 2)*100,
                         perc_MP = round(n_block_positive/n_blocks, 2),
                         avg_HOP = round(sum_ovitrap_positive/n_ovitraps_positive,1),
                         avg_HMP = round(sum_ovitrap_positive/n_block_positive,1),
                         .groups = "drop") |>
        dplyr::mutate(week = Semana.Epidemiologica,
                      locality = Localidad) |>
        dplyr::select(week, locality, avg_HOP, avg_HMP, perc_OP, perc_MP, perc_lectura) |>
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
        as.data.frame()

    #
    ######
    #titleLab <- unique(y[,c("locality"),])
    titleLab <- unique(y$locality)
    nORI <- length(titleLab)
    choiceP <- vector("list", nORI)
    for (i in 1:nORI){
        choiceP[[i]] <- list(method="restyle",
                             args = list("transforms[0].value",
                                         unique(y$locality)[i]),
                             label= titleLab[i])
    }

    #####
    trans <- list(list(type ='filter',
                       target = ~locality,
                       operation ="=",
                       value = unique(y$locality[1])))


    #####
    if(scale == "ovitraps"){
        plotly::plot_ly() |>
            plotly::add_trace(data = y |>
                                  dplyr::filter(indicador == "ocupancy") |>
                                  dplyr::filter(scale == "ovitrap"),
                              x = ~week,
                              y = ~value,
                              name = "yaxis data",
                              showlegend=FALSE,
                              color = I("#2EB67D"),
                              type='bar',
                              transforms = trans,
                              labels = ~scale) |>
            # plotly::add_trace(data = y |>
            #                      dplyr::filter(indicador == "ocupancy") |>
            #                      dplyr::filter(scale == "Ambos"),
            #                  x = ~week,
            #                  y = ~value,
            #                  name = "yaxis data",
            #                  showlegend=FALSE,
            #                  color = I("#ECB32D"),
            #                  type= 'scatter',
            #                  mode = "lines+markers",
            #                  transforms = trans,
        #                  labels = ~scale) |>
        plotly::add_trace(data = y |>
                              dplyr:: filter(indicador == "abundancy")|>
                              dplyr::filter(scale == "ovitrap"),
                          x = ~week,
                          y = ~value,
                          #name = "yaxis 2 data",
                          yaxis = "y2",
                          color = I("#E01E5A"),
                          type = 'scatter',
                          line = list( width = 5),
                          mode = "lines+markers",
                          transforms = trans,
                          labels = ~scale) |>
            plotly::layout(title = "Indicador de Ovitrampas por Casa",
                           # secondary axis
                           yaxis2 = list(tickfont = list(color = "#E01E5A"),
                                         overlaying = "y",
                                         side = "right",
                                         title = "<b>Abundancia</b>",
                                         color = "#E01E5A"),
                           xaxis = list(title="Semanas Epidemiológicas"),
                           # primary axis
                           yaxis = list(title="<b>Porcentaje</b>",
                                        color = "#2EB67D",
                                        tickfont = list(color = "#2EB67D"))) |>
            plotly::layout(plot_bgcolor = '#e5ecf6',
                           margin = 1,
                           xaxis = list(
                               zerolinecolor = '#ffff',
                               zerolinewidth = 0,
                               gridcolor = 'ffff'),
                           yaxis = list(zerolinecolor = '#ffff',
                                        zerolinewidth = 0,
                                        gridcolor = 'ffff')) |>
            plotly::layout(xaxis = list(rangeslider = list(visible = T)),
                           updatemenus= list(list(type='dropdown',
                                                  active = 1,
                                                  buttons=choiceP)))
    } else if(scale == "blocks"){
        plotly::plot_ly() |>
            plotly::add_trace(data = y |>
                                  dplyr::filter(indicador == "ocupancy") |>
                                  dplyr::filter(scale == "block"),
                              x = ~week,
                              y = ~value,
                              name = "yaxis data",
                              showlegend=FALSE,
                              color = I("#2EB67D"),
                              type='bar',
                              transforms = trans,
                              labels = ~scale) |>
            plotly::add_trace(data = y |>
                                  dplyr:: filter(indicador == "abundancy")|>
                                  dplyr::filter(scale == "block"),
                              x = ~week,
                              y = ~value,
                              #name = "yaxis 2 data",
                              yaxis = "y2",
                              color = I("#E01E5A"),
                              type = 'scatter',
                              line = list( width = 5),
                              mode = "lines+markers",
                              transforms = trans,
                              labels = ~scale) |>
            plotly::layout(title = "Indicador de Ovitrampas por Manzana",
                           # secondary axis
                           yaxis2 = list(tickfont = list(color = "#E01E5A"),
                                         overlaying = "y",
                                         side = "right",
                                         title = "<b>Abundancia</b>",
                                         color = "#E01E5A"),
                           xaxis = list(title="Semanas Epidemiológicas"),
                           # primary axis
                           yaxis = list(title="<b>Porcentaje</b>",
                                        color = "#2EB67D",
                                        tickfont = list(color = "#2EB67D"))) |>
            plotly::layout(plot_bgcolor = '#e5ecf6',
                           margin = 1,
                           xaxis = list(
                               zerolinecolor = '#ffff',
                               zerolinewidth = 0,
                               gridcolor = 'ffff'),
                           yaxis = list(zerolinecolor = '#ffff',
                                        zerolinewidth = 0,
                                        gridcolor = 'ffff'))  |>
            plotly::layout(xaxis = list(rangeslider = list(visible = T)),
                           updatemenus= list(list(type='dropdown',
                                                  active = 1,
                                                  buttons=choiceP)))

    } else{

    }




}

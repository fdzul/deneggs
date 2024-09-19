#' Read the ovitrap dataset
#'
#' This function has been designed for read the ovitrap datasets (historic and current year).
#'
#' @param path is the directory where the files are located. The files for the current year is in txt (currente_year = TRUE), the historic dataset is a zip file (currente_year = FALSE).
#' @param current_year is a logical value. The current_year = TRUE is for current year dataset (2020), else is for historic dataset (2011 to 2019).
#' @param year is a string value. When the current_year is FALSE, we need define the year. When current_year is TRUE the value for year is NULL.
#'
#' @author Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
#'
#' @return a dataframe.
#' @export
#'
#' @examples 1+1
#' @references xxxxx
#'
#' @seealso \link[boldenr]{read_dataset_bol}
#'
#' @details the current and historic ovitrap dataset is download of the homepage of \href{http://kin.insp.mx/aplicaciones/SisMV}{**Sistema Integral de Monitoreo de Vectores**}.
ovitraps_read <- function(path, current_year, year = NULL){

    ## Step 0.1 load the ovitrap dataset ####

    if(current_year == TRUE){
        # Step 2. txt ##
        l_files <- purrr::map(list.dirs(path = path,
                                        full.names = TRUE),
                              list.files, pattern = "txt", full.names = TRUE)
        l <- unlist(purrr::map(l_files, stringr::str_subset, c("Lectura")))
        y <- purrr::map_dfr(l, utils::read.table,
                            sep = "\t",
                            header = TRUE,
                            skipNul = TRUE,
                            stringsAsFactors = FALSE,
                            fill = TRUE,
                            colClasses = "character",
                            fileEncoding = "UCS-2LE")  |>
            dplyr::select(Clave, Ovitrampa, Huevecillos, Fecha.Lectura, Sector, Manzana) |>
            dplyr::rename(clave = Clave,
                          ovitrap = Ovitrampa,
                          eggs = Huevecillos,
                          fecha_lectura = Fecha.Lectura,
                          sector = Sector,
                          manzana = Manzana) |>
            dplyr::mutate(clave = as.character(clave),
                          ovitrap = as.character(ovitrap)) |>
            dplyr::mutate(clave = ifelse(stringr::str_length(clave) == 17,
                                         clave,  stringr::str_pad(clave, width = 17,
                                                                  side = "left",
                                                                  pad = "0")),
                          ovitrap = ifelse(stringr::str_length(ovitrap) == 9,
                                           ovitrap,  stringr::str_pad(ovitrap, width = 9,
                                                                      side = "left",
                                                                      pad = "0"))) |>
            dplyr::mutate(eggs = as.numeric(eggs),
                          edo = stringr::str_sub(clave, 1, 2),
                          mpo = stringr::str_sub(clave, 3, 5),
                          loc = stringr::str_sub(clave, 6, 9),
                          date = lubridate::dmy(fecha_lectura),
                          year = lubridate::year(date),
                          week =  lubridate::epiweek(date),
                          fecha_lectura = NULL,
                          clave = as.numeric(clave),
                          ovitrap = stringr::str_trim(ovitrap, side = "both"))



        # Step 2. csv ##
        l_files <- purrr::map(list.dirs(path = path,
                                        full.names = TRUE),
                              list.files, pattern = "csv", full.names = TRUE)
        l <- unlist(purrr::map(l_files, stringr::str_subset, c("Lectura")))

        z <- purrr::map_dfr(l, data.table::fread) |>
            dplyr::select(Clave, Ovitrampa, Huevecillos, "Fecha Lectura", Sector, Manzana) |>
            dplyr::rename(clave = Clave,
                          ovitrap = Ovitrampa,
                          eggs = Huevecillos,
                          fecha_lectura = "Fecha Lectura",
                          sector = Sector,
                          manzana = Manzana) |>
            dplyr::mutate(clave = as.character(clave),
                          ovitrap = as.character(ovitrap)) |>
            dplyr::mutate(clave = ifelse(stringr::str_length(clave) == 17,
                                         clave,  stringr::str_pad(clave,
                                                                  width = 17,
                                                                  side = "left",
                                                                  pad = "0")),
                          ovitrap = ifelse(stringr::str_length(ovitrap) == 9,
                                           ovitrap,  stringr::str_pad(ovitrap,
                                                                      width = 9,
                                                                      side = "left",
                                                                      pad = "0"))) |>
            dplyr::mutate(sector = stringr::str_pad(sector,
                                                    width = 4,
                                                    side = "left",
                                                    pad = "0"),
                          manzana = stringr::str_pad(manzana,
                                                     width = 4,
                                                     side = "left",
                                                     pad = "0")) |>
            dplyr::mutate(eggs = as.numeric(eggs),
                          edo = stringr::str_sub(clave, 1, 2),
                          mpo = stringr::str_sub(clave, 3, 5),
                          loc = stringr::str_sub(clave, 6, 9),
                          date = lubridate::dmy(fecha_lectura),
                          year = lubridate::year(date),
                          week =  lubridate::epiweek(date),
                          fecha_lectura = NULL,
                          clave = as.numeric(clave),
                          ovitrap = stringr::str_trim(ovitrap, side = "both"))

        dplyr::bind_rows(y, z)


    } else {

        l <- list.files(path = path,
                        full.names = TRUE,
                        pattern = "zip")

        ## Step 2. select list files of ovitraps of 2012 to 2017
        #l1 <- unlist(purrr::map(l, stringr::str_subset, c("2010", "2011")))
        l2 <- unlist(purrr::map(l, stringr::str_subset, year))

        ##  Step 3. define the function for read the files
        unzip_read <- function(x){
            y <- data.table::fread(unzip(x), header = TRUE, select = c(2:4, 6))
            #y[,V11:= NULL]
            names(y) <- c("clave", "ovitrap",
                          "eggs", "fecha_lectura")
            #y$id <- as.character(y$id)
            y$clave <- as.character(y$clave)
            y$clave <- ifelse(stringr::str_length(y$clave) == 17,
                              y$clave,  stringr::str_pad(y$clave, width = 17,
                                                         side = "left",
                                                         pad = "0"))
            y$ovitrap <- as.character(y$ovitrap)
            y$ovitrap <- ifelse(stringr::str_length(y$ovitrap) == 9,
                                y$ovitrap,  stringr::str_pad(y$ovitrap, width = 9,
                                                             side = "left",
                                                             pad = "0"))

            y$eggs <- as.numeric(y$eggs)
            y$edo <- stringr::str_sub(y$clave, 1, 2)
            y$mpo <- stringr::str_sub(y$clave, 3, 5)
            y$loc <- stringr::str_sub(y$clave, 6, 9)
            y$sector <- stringr::str_sub(y$clave, 10, 13)
            y$manzana <- stringr::str_sub(y$clave, 14, 17)
            y$date <- lubridate::ymd(y$fecha_lectura)
            y$year <- lubridate::year(y$date)
            y$week <-  lubridate::epiweek(y$date)
            y$fecha_lectura <- NULL
            y$clave <- as.numeric(y$clave)
            y$ovitrap <- stringr::str_trim(y$ovitrap, side = "both")
            y
        }
        ## Step 4. apply the function for each file and row bind
        purrr::map_dfr(l2, unzip_read)
    }

}

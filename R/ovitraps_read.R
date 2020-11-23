ovitraps_read <- function(path, current_year, year = NULL){

    ## Step 0.1 load the ovitrap dataset ####

    if(current_year == TRUE){
        l_files <- purrr::map(list.dirs(path = path,
                                        full.names = TRUE),
                              list.files, pattern = "txt", full.names = TRUE)
        l <- unlist(purrr::map(l_files, stringr::str_subset, c("Lecturas")))
        y <- purrr::map_dfr(l, utils::read.table,
                            sep = "\t",
                            header = TRUE,
                            skipNul = TRUE,
                            stringsAsFactors = FALSE,
                            colClasses = "character",
                            fileEncoding = "UCS-2LE") %>%
            dplyr::select(Clave, Ovitrampa, Huevecillos, Fecha.Lectura)
        names(y) <- c("clave", "ovitrap",
                      "eggs", "fecha_lectura")
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
        y$date <- lubridate::dmy(y$fecha_lectura)
        y$year <- lubridate::year(y$date)
        y$week <-  lubridate::epiweek(y$date)
        y$fecha_lectura <- NULL
        y

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
            y$date <- lubridate::ymd_hms(y$fecha_lectura)
            y$year <- lubridate::year(y$date)
            y$week <-  lubridate::epiweek(y$date)
            y$fecha_lectura <- NULL
            y
        }
        ## Step 4. apply the function for each file and row bind
        purrr::map_dfr(l2, unzip_read)
    }

}

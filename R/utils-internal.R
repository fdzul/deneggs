# Internal helpers. They were taken from boldenr (read_dataset_bol() with
# inf = "Lecturas", and risk_percentil()) so that deneggs does not depend on
# boldenr, which is being replaced by densnv.

# Read the ovitrap readings ("Lecturas") of the SisMV, txt files in UCS-2LE.
.read_lecturas <- function(path){
    l_files <- purrr::map(list.dirs(path = path, full.names = TRUE),
                          list.files, pattern = "txt", full.names = TRUE)
    l <- unlist(purrr::map(l_files, stringr::str_subset, "Lecturas"))
    x <- purrr::map_dfr(l, utils::read.table,
                        sep = "\t",
                        header = TRUE,
                        stringsAsFactors = FALSE,
                        colClasses = "character",
                        fileEncoding = "UCS-2LE") |>
        tidyr::separate(Municipio, into = c(NA, "Municipio"), extra = "merge") |>
        tidyr::separate(Localidad, into = c(NA, "Localidad"), extra = "merge") |>
        dplyr::mutate(Localidad = stringr::str_to_title(Localidad))
    x$Municipio <- stringr::str_trim(x$Municipio, side = "both")
    x$Huevecillos <- as.numeric(x$Huevecillos)
    x$Semana.Epidemiologica <- as.numeric(x$Semana.Epidemiologica)
    x$Sector <- as.numeric(x$Sector)
    x$Manzana <- as.numeric(x$Manzana)
    x
}

# Risk categories from the deciles of a variable.
.risk_percentil <- function(x, var, en){
    cuts <- stats::quantile(unlist(x[, c(var)]),
                            probs = seq(from = .1, to = 1, by = 0.1),
                            na.rm = TRUE, names = FALSE)
    x$percentil <- findInterval(unlist(x[, c(var)]), vec = sort(cuts))
    if (isTRUE(en)) {
        x$risk <- ifelse(x$percentil <= 4, "Low Risk",
                  ifelse(x$percentil > 4 & x$percentil < 8, "Moderate Risk",
                  ifelse(x$percentil >= 8 & x$percentil < 9, "High Risk",
                  ifelse(x$percentil >= 9, "Very High Risk", NA))))
        x$risk <- factor(x$risk, levels = c("Low Risk", "Moderate Risk",
                                            "High Risk", "Very High Risk"))
    } else {
        x$risk <- ifelse(x$percentil <= 4, "Riesgo Bajo",
                  ifelse(x$percentil > 4 & x$percentil < 8, "Riesgo Moderado",
                  ifelse(x$percentil >= 8 & x$percentil < 9, "Riesgo Alto",
                  ifelse(x$percentil >= 9, "Riesgo Muy Alto", NA))))
        x$risk <- factor(x$risk, levels = c("Riesgo Muy Alto", "Riesgo Alto",
                                            "Riesgo Moderado", "Riesgo Bajo"))
    }
    x
}

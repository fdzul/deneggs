% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spde_inla.R
\name{spde_inla}
\alias{spde_inla}
\title{spde_inla}
\usage{
spde_inla(
  path_lect,
  year = NULL,
  locality,
  path_coord,
  cve_edo,
  leg_title,
  fam,
  alpha,
  plot = NULL,
  aproximation,
  integration,
  k,
  weeks,
  cell_size,
  palette_vir,
  hist_dataset
)
}
\arguments{
\item{path_lect}{is the directory of the ovitrampas readings file.}

\item{year}{is the year to analyze}

\item{locality}{is the locality target.}

\item{path_coord}{is the directory of the ovitrampas coordinates file.}

\item{cve_edo}{is the text id of the state.}

\item{leg_title}{is title of legend.}

\item{fam}{is the name of the family of the distribution for modelling count data. The option can be  poisson, zeroinflatedpoisson0, zeroinflatedpoisson1, nbinomial, zeroinflatednbinomial0 and zeroinflatednbinomial1}

\item{alpha}{alpha The significance level, also denoted as alpha or α, is the probability of rejecting the null hypothesis when it is true.}

\item{plot}{is a logical value for the plot the mesh.}

\item{aproximation}{aproximation is the aproximation of the joint posterior of the marginals and hyperparameter. The options are "gaussian", "simplified.laplace" & "laplace".}

\item{integration}{integration is the integration strategy. The options are "grid", "eb" & "ccd".}

\item{k}{is the parameter for define the triagulization of delauney in the inner and the outer area in the argument max.edge in the INLA:inla.mesh.2d.}

\item{weeks}{is the week you want to analyze}

\item{cell_size}{is the sample number per location (area of locality/n)}

\item{palette_vir}{is the palette.}

\item{hist_dataset}{is a logical value for define the dataset, if TRUE is the ovitraps historical dataset and we neen define the year to analyze.}
}
\value{
a list of object (data, map, loc, dics, hotspots). data is original dataset (ovitraps + coordinates). The map is the map of eggs prediction. Loc is the sf objecto of locality limit. dics is the Deviancie Information Criterio of the model. the hotspots object is the dataset with the eggs prediction and the hotspots.
}
\description{
this function predicts the number of eggs using a geostatistical analysis with INLA and later calculates the hotspots of the eggs
}
\details{
\link[INLA]{inla}.
}
\examples{
1+1
}
\seealso{
\link[viridis]{viridis}, \link[viridis]{plasma}, \link[viridis]{inferno}, \link[viridis]{magma}

\link[INLA]{inla}
}
\author{
Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/animap_vector_hotblocks.R
\name{animap_vector_hotblocks}
\alias{animap_vector_hotblocks}
\title{animap_vector_hotblocks: a function for create the animated map of hotblocks of eggs.}
\usage{
animap_vector_hotblocks(
  path_vector,
  locality,
  cve_edo,
  dir,
  name,
  vel,
  xleg,
  yleg
)
}
\arguments{
\item{path_vector}{is the directory of ovitrap datasets.}

\item{locality}{is the locality target with the ovitraps.}

\item{cve_edo}{is the text id of the state.}

\item{dir}{is the directory where the animation will be saved.}

\item{name}{is the name of the gif file.}

\item{vel}{is the delay time between images. See also \link[tmap]{tmap_animation}.}

\item{xleg}{x_leg is the x position of legend. The value is in 0 to 1.}

\item{yleg}{y_leg is the y position of legend. The value is in 0 to 1.}
}
\value{
a gif file of animation.
}
\description{
animap_vector_hotblocks: a function for create the animated map of hotblocks of eggs.
}
\examples{
1+1
}
\seealso{
\link[tmap]{tmap_animation}
}
\author{
Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
}

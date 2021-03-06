% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mesh.R
\name{mesh}
\alias{mesh}
\title{mesh}
\usage{
mesh(x, k, long, lat, loc_limit, plot = NULL)
}
\arguments{
\item{x}{is the dataset with the coordinates and the target variable.}

\item{k}{is the parameter for defining the delaunay triagulization.}

\item{long}{is the longitude.}

\item{lat}{is the latitude.}

\item{loc_limit}{is the locality limit.}

\item{plot}{is a logical argument. if TRUE plot the mesh else no plot the mesh.}
}
\value{
a mesh and plot of the mesh.
}
\description{
This function create the mesh for modelling with INLA framework
}
\details{
this function use \link[INLA]{inla}.
}
\examples{
1+1
}
\seealso{
\link[INLA]{inla.mesh.2d}
}
\author{
Felipe Antonio Dzul Manzanilla \email{felipe.dzul.m@gmail.com}
}

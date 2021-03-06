\name{GSDF.regrid.2d}
\alias{GSDF.regrid.2d}
\title{Regrid a 2d field to match another 2d field}
\usage{
  GSDF.regrid.2d(g, g.grid, full = NULL)
}
\arguments{
  \item{g}{2d GSDF field}

  \item{g.grid}{2d GSDF field with same set of dimensions}

  \item{full}{- TRUE => apply appropriate boundary
  conditions for full global lat:lon field (wrap longitudes
  and extrapolate near poles if required, FALSE => just
  interpolate (removes data outside range of g.grid), NULL
  (default) => Guess which to do (is field ll and covering
  most of globe?).}
}
\value{
  GSDF field with data from g on grid of g.grid
}
\description{
  Makes the first field have the same grid as the second
}
\details{
  Both fields must have exactly 2 extended dimensions, and
  those dimensions must have the same labels (e.g. both
  lat,long, or both lat,height).
}


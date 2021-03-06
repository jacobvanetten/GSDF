\name{GSDF.interpolate.ll}
\alias{GSDF.interpolate.ll}
\title{Interpolate lat:lon points in a 2d field}
\usage{
  GSDF.interpolate.ll(g, lat, lon, full = NULL)
}
\arguments{
  \item{g}{GSDF data structure (must have lat and lon as
  dimensions)}

  \item{lat}{latitudes to interpolate to}

  \item{lon}{longitude values to interpolate to}

  \item{full}{- TRUE => apply appropriate boundary
  conditions for full global lat:lon field (wrap longitudes
  and extrapolate near poles if required, FALSE => just
  interpolate (removes data outside range of g), NULL
  (default) => Guess which to do (is field ll and covering
  most of globe?).}
}
\value{
  numeric vector of interpolated values
}
\description{
  2d bilinear interpolation (uses fields package)
}
\details{
  Basically the same as \code{\link{GSDF.interpolate.2d}}
  except that we check that the field has lat and lon as
  dimensions and arrange them in the right order.
}


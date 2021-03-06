\name{GSDF.roll.dimensions}
\alias{GSDF.roll.dimensions}
\title{Roll-out a pair of dimensions}
\usage{
  GSDF.roll.dimensions(g, d1, d2)
}
\arguments{
  \item{g}{GSDF data structure}

  \item{d1}{integer index of first dimension}

  \item{d2}{integer index of second dimension}
}
\value{
  numeric vector of first dimension values
}
\description{
  Get (for example) lat for each point in a 2d slice
}
\details{
  If g has 2 dimensions, 'lat' and 'lon', each of length
  10, \code{GSDF.roll.dimensions(g,1,2)} will return the
  latitude for each of the 100 points in the slice; and
  \code{GSDF.roll.dimensions(g,2,1)} will return the
  longitude similarly.
}


\name{GSDF.interpolate.2d}
\alias{GSDF.interpolate.2d}
\title{Interpolate points in a 2d field}
\usage{
  GSDF.interpolate.2d(g, x, y)
}
\arguments{
  \item{g}{GSDF data structure}

  \item{x}{values to interpolate to in 1st dimension}

  \item{y}{values to interpolate to in 2nd dimension}
}
\value{
  numeric vector of interpolated values
}
\description{
  2d bilinear interpolation (uses fields package)
}
\details{
  Interpolate values at a set of x,y points in a 2d field.
  Note that x is the first dimension in the field and y the
  second dimension whatever the names of those dimensions.
  The field must have exactly 2 extended dimensions.
}
\seealso{
  \code{\link{GSDF.regrid.2d}} regrid 1 field to match
  another
}


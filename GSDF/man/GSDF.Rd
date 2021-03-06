\name{GSDF}
\alias{GSDF}
\title{GeoSpatial Data Field}
\usage{
  GSDF()
}
\value{
  A list as described (all components empty)
}
\description{
  A data structure to hold geospatial fields
}
\details{
  Fundamentally just a list with particular components:
  \describe{ \item{$data} {multidimensional array of
  numeric (may contain NAs)} \item{$dimensions} {a list:
  one element for each dimension} \item{$dimensions[[1]]}
  {details of the first dimension, contains:}
  \item{$dimensions[[1]]$type} {'lat', 'lon', 'height',
  'time' or 'custom'} \item{$dimensions[[1]]$values}
  {lat/lon in degrees, height in hPa, time as chron.
  Length must equal length of $data in that dimension,
  order of dimensions is the same as in $data.}
  \item{$dimensions[[1]]$meta} {anything else (list -
  key-value pairs)} \item{$meta} {any other info (list -
  key-value pairs)} Notably: pole.lat - latitude of the
  pole used (assume 90 if unspecified) pole.lon - longitude
  of the pole used (assume 180 if unspecified) }
}
\seealso{
  \code{\link{GSDF.print}} Print such a field

  \code{\link{GSDF.ncdf.load}} Create a field from data
  file or openDAP URL

  \code{\link{GSDF.plot.2d}} Plot the field (if it's
  2-dimensional)

  \code{\link{GSDF.interpolate.2d}} Bilinear interpolation
  in the field (if it's 2-dimensional

  \code{\link{GSDF.regrid.2d}} Regrid a field to match
  another (if both are 2-dimensional))
}


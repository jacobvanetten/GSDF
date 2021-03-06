\name{GSDF.ll.to.rg}
\alias{GSDF.ll.to.rg}
\title{Rotate lats and lons}
\usage{
  GSDF.ll.to.rg(lat, lon, pole.lat, pole.lon)
}
\arguments{
  \item{lat}{vector of latitudes in standard pole
  (degrees).}

  \item{lon}{vector of longitudes in standard pole
  (degrees).}

  \item{pole.lat}{latitude of pole to rotate to (degrees).}

  \item{pole.lon}{longitude of pole to rotate to
  (degrees).}
}
\value{
  list with components 'lat' and 'lon' - vectors of rotated
  lat and lon (in degrees).
}
\description{
  From standard pole to same positions in a rotated pole.
}
\details{
  Convert latitudes and longitudes to the equivalents with
  a rotated pole. (Formulae from UMDP S1).
}


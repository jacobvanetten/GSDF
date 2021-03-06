\name{GSDF.wind.to.pole}
\alias{GSDF.wind.to.pole}
\title{Rotate winds}
\usage{
  GSDF.wind.to.pole(u, v, pole.lat, pole.lon = 180)
}
\arguments{
  \item{u}{field of zonal wind speeds in source pole.}

  \item{v}{field of meridional wind speeds in source pole.}

  \item{pole.lat}{latitude of pole to rotate to (degrees).}

  \item{pole.lon}{longitude of pole to rotate to
  (degrees).}
}
\value{
  list with components 'u' and 'v' - fields of rotated
  zonal and meridional wind speeds.
}
\description{
  From u & v one pole to same in a different pole.
}
\details{
  (Formulae from UMDP S1). Works for any vector field, not
  just winds.
}


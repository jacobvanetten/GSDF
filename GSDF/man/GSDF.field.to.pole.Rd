\name{GSDF.field.to.pole}
\alias{GSDF.field.to.pole}
\title{Rotate a field}
\usage{
  GSDF.field.to.pole(g, pole.lat, pole.lon)
}
\arguments{
  \item{g}{field to be rotated}

  \item{pole.lat}{latitude of pole to rotate to (degrees).}

  \item{pole.lon}{longitude of pole to rotate to
  (degrees).}
}
\value{
  input field but with the rotated pole.
}
\description{
  Keeps the same grid but moves the North pole to a
  different place.
}
\details{
  Effectively allows you to move the centre of the lat-lon
  grid (where distortion is low) to any position.
}
\seealso{
  \code{\link{GSDF.ll.to.rg}} and
  \code{\link{GSDF.rg.to.ll}}.
}


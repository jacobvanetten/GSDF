\name{GSDF.grow}
\alias{GSDF.grow}
\title{Grow field}
\usage{
  GSDF.grow(g)
}
\arguments{
  \item{field}{GSDF field}
}
\value{
  grown field.
}
\description{
  Given a spatially incomplete GSDF field, extrapolate the
  field into missing regions by adding one grid point round
  the boundary of all non-missing sections.
}
\details{
  Mostly useful for sea-ice - because rotating and
  regridding only interpolates, grid-boxes which are
  adjacent to missing data are removed by either process.
  This is a hack - but it mostly repairs the damage.
}


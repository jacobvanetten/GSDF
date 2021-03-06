\name{TWCR.get.slice.at.month}
\alias{TWCR.get.slice.at.month}
\title{Get slice at month.}
\usage{
  TWCR.get.slice.at.month(variable, year, month,
    height = NULL, opendap = TRUE, version = 2,
    type = "mean")
}
\arguments{
  \item{variable}{'prmsl', 'prate', 'air.2m', 'uwnd.10m' or
  'vwnd.10m' - or any 20CR variable}

  \item{type}{- 'mean', 'spread', 'normal', or
  'standard.deviation'.  Note that standard deviations are
  not available over opendap.}

  \item{height}{Height in hPa - leave NULL for monolevel}

  \item{opendap}{TRUE for network retrieval, FALSE for
  local files (faster, if you have them).}
}
\value{
  A GSDF field with lat and long as extended dimensions
}
\description{
  Get a 2D horizontal slice of a selected variable (as a
  GSDF field) for a given month.
}
\details{
  Interpolates to the selected height when the selected
  height is not that of a 20RC level.
}


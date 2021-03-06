\name{TWCR.hourly.get.file.name}
\alias{TWCR.hourly.get.file.name}
\title{TWCR get file name (hourly)}
\usage{
  TWCR.hourly.get.file.name(variable, year, month, day,
    hour, opendap = NULL, version = 2, type = "mean")
}
\arguments{
  \item{variable}{'prmsl', 'prate', 'air.2m', 'uwnd.10m' or
  'vwnd.10m' - or any 20CR variable}

  \item{type}{- 'mean', 'spread', 'normal', or
  'standard.deviation'.  Note that standard deviations are
  not available over opendap.}

  \item{opendap}{TRUE for network retrieval, FALSE for
  local files (faster, if you have them), NULL (default)
  will use local files if available, and network if not.}
}
\value{
  File name or URL for netCDF file containing the requested
  data
}
\description{
  Get the file name (or URL) for selected variable and date
  (hourly data)
}
\details{
  Called internally by \code{TWCR.get.slice.at.hour} but
  also useful called directly - you can then access the
  data with another tool.
}


\name{TWCR.monthly.get.file.name}
\alias{TWCR.monthly.get.file.name}
\title{TWCR get file name (monthly)}
\usage{
  TWCR.monthly.get.file.name(variable, year, month,
    opendap = NULL, version = 2, type = "mean")
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
  (monthly data)
}
\details{
  Called internally by \code{TWCR.get.slice.at.month} but
  also useful called directly - you can then access the
  data with another tool.
}


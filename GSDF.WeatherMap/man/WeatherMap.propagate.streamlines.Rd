\name{WeatherMap.propagate.streamlines}
\alias{WeatherMap.propagate.streamlines}
\title{Propagate streamlines}
\usage{
  WeatherMap.propagate.streamlines(lat, lon, status, u, v,
    t, t.c, Options)
}
\arguments{
  \item{lat}{vector of latitudes}

  \item{lon}{vector of longitudes}

  \item{status}{vector of status (see
  \code{WeatherMap.make.streamlines})}

  \item{u}{GSDF field of zonal wind (m/s)}

  \item{v}{GSDF field of meridional wind (m/s)}

  \item{t}{GSDF field of air temperature (K)}

  \item{t.c}{GSDF field of air temperature normal (K)}

  \item{Options}{list of options - see
  \code{WeatherMap.set.option}}
}
\value{
  streamlines data structure (see
  \code{WeatherMap.make.streamlines})
}
\description{
  Propagate out streamlines from start positions
}
\details{
  A streamline is the locus of a point moving with the
  wind. This function moves a set of points out with the
  wind. For details of the streamline data structure, see
  \code{WeatherMap.make.streamlines}
}


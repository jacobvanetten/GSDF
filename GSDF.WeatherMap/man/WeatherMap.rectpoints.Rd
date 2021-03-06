\name{WeatherMap.rectpoints}
\alias{WeatherMap.rectpoints}
\title{Rectpoints}
\usage{
  WeatherMap.rectpoints(n, Options)
}
\arguments{
  \item{n}{(approximate) number of points.}

  \item{Options}{list of options - see
  \code{WeatherMap.set.option}}
}
\value{
  list with components 'lat' and 'lon'.
}
\description{
  Create a set of uniformly distributed points on which to
  plot.
}
\details{
  Generate a set of (approximately) N lat,long points that
  are uniformly distributed in latitude and longitude.
}


\name{WeatherMap.draw.land}
\alias{WeatherMap.draw.land}
\title{Draw land mask}
\usage{
  WeatherMap.draw.land(land, Options)
}
\arguments{
  \item{land}{list with components 'x' and 'y' - the
  coordinates of a set of polygons bounding land regions.
  Suitable for drawing with \code{grid.polygon}. If NULL,
  will be obtained from \code{WeatherMap.get.land}.}

  \item{Options}{list of options - see
  \code{WeatherMap.set.option}.}
}
\value{
  nothing - side effect only.
}
\description{
  Draw the land (probably onto a pre-existing background of
  sea) Also draws Antarctic ice shelves.
}
\details{
  Uses maps/mapdata land polygons if none provided See
  \code{WeatherMap.get.land}
}


\name{WeatherMap.get.land}
\alias{WeatherMap.get.land}
\title{Land-mask}
\usage{
  WeatherMap.get.land(Options)
}
\arguments{
  \item{Options}{list of options - see
  \code{WeatherMap.set.option} background.resolution is the
  relevant one, 'low' or 'high'.}
}
\value{
  a set of land-mask polygons for
  \code{WeatherMap.draw.land}.
}
\description{
  Make the land-mask polygons on the selected pole.
}
\details{
  Mostly can use medium-resolution polygons from the
  MapData package Alternatively have a high-resolution
  land-mask gridded field, but that's a lot of polygons -
  so slow.
}


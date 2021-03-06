\name{TWCR.relative.entropy}
\alias{TWCR.relative.entropy}
\title{Relative Entropy}
\usage{
  TWCR.relative.entropy(old.mean, old.sd, new.mean, new.sd)
}
\arguments{
  \item{old.mean}{Field of best estimates from climatology}

  \item{old.sd}{Field of climatological standard
  deviations}

  \item{new.mean}{Field of best estimates from TWCR}

  \item{new.sd}{Field of standard deviations from TWCR}
}
\value{
  Field of relative entropy
}
\description{
  Estimates the Relative Entropy (Kullback-Liebler
  divergence) between two fields, given the mean and
  standard deviation) or each.
}
\details{
  This is a useful metric for 20CR - typical comparison is
  between climatological and TWCR distributions. In
  principle we could extend this to do multivariate
  comparisons (sets of fields) but this function doesn't
  currently allow this.
}


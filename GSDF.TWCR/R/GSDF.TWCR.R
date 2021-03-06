# Functions for getting data from the 20th Century Reanalysis

# names and classes of variables
TWCR.monolevel<-c('air.sig995','air.tropo','cape','cin','cldwtr.eatm','hgt.tropo',
                  'omega.sig995','pottmp.sig995','pr_wtr.eatm','pres.sfc','pres.tropo',
                  'prmsl','rhum.sig995','tco3.eatm','uwnd.sig995','uwnd.tropo',
                  'vwnd.sig995','vwnd.tropo')
TWCR.gaussian.monolevel<-c('air.2m','air.sfc','albedo','cprat','cwork.eatm','dlwrf.sfc',
                           'dswrf.sfc','gflux','hpbl','icec','icet','lhtfl','pevpr',
                           'pr_wtr.eatm','prate','press.sfc','runoff','shtfl','shum',
                           'snod','snowc','soilm','ssrunoff','tcdc.bndrylyr','tcdc.convcld',
                           'tcdc.eatm','tcdc.lowcld','tcdc.midcld','tcdc.topcld','tmax.2m',
                           'tmin.2m','trans','uflx','ugwd','ulwrf.ntat','ulwrf.sfc','uswrf.ntat',
                           'uswf.sfc','uwnd.10m','vflx','vgwd','vwnd.10m','weasd')
TWCR.pressure.level<-c('air','hgt','omega','rhum','shum','uwnd','vwnd')
# Also subsurface soil - not currently supported

# Height of each level in hPa
TWCR.heights<-c(1000,950,900,850,800,750,700,650,600,550,500,450,400,350,300,
                 250,200,150,100,70,50,30,20,10)

#' TWCR show variables
#'
#' List the variables available from 20CR
#'
#' 3 Different grids: 'Monolevel' and 'Gaussian' are both
#' Lat x Lon x Time but with different grids, 'Pressure level'
#' is  Lat x Lon x Height x Time. No parameters or return value
#' prints out a list of available variables.
#' @export
TWCR.show.variables<-function() {
  print('Monolevel')
  print(TWCR.monolevel)
  print('Gaussian')
  print(TWCR.gaussian.monolevel)
  print('Pressure level')
  print(TWCR.pressure.level)
}

#' TWCR get data directory
#'
#' Find local data directory - different for different systems
#'
#' It's much faster to read data from local disc than over openDAP,
#'  also observations and standard deviations are currently only
#'  available locally. But the various different systems on which I run this code all have
#'  different places to keep large data files. This function returns
#'  the right base directory for the system (if there is one).
#'
#' @export
#' @return Base directory name (or NULL is no local files)
TWCR.get.data.dir<-function(version=2) {
    if(file.exists(sprintf("/Volumes/DataDir/20CR/version_%s/",version))) {
            return(sprintf("/Volumes/DataDir/20CR/version_%s/",version))
    }	
    if(file.exists(sprintf("/data/cr2/hadpb/20CR/version_%s/",version))) {
            return(sprintf("/data/cr2/hadpb/20CR/version_%s/",version))
    }	
    if(file.exists(sprintf("/project/projectdirs/incite11/brohan/netCDF.data/20CR_v%s/",version))) {
            return(sprintf("/project/projectdirs/incite11/brohan/netCDF.data/20CR_v%s/",version))
    }	
    return(NULL)
}

# Get class of variable: monolevel, pressure-level, gaussian
#  They have different locations on the openDAP server.
TWCR.get.variable.group<-function(variable) {
  if(length(which(TWCR.monolevel==variable))>0) return('monolevel')
  if(length(which(TWCR.gaussian.monolevel==variable))>0) return('gaussian')
  if(length(which(TWCR.pressure.level==variable))>0) return('pressure')
  stop(sprintf("Unrecognised variable: %s",variable))
}

#' TWCR get file name (hourly)
#'
#' Get the file name (or URL) for selected variable and date (hourly data)
#'
#' Called internally by \code{TWCR.get.slice.at.hour} but also useful
#'  called directly - you can then access the data with another tool.
#'
#' @export
#' @param variable 'prmsl', 'prate', 'air.2m', 'uwnd.10m' or 'vwnd.10m' - or any 20CR variable
#' @param type - 'mean', 'spread', 'normal', or 'standard.deviation'. 
#'  Note that standard deviations are not available over opendap.
#' @param opendap TRUE for network retrieval, FALSE for local files (faster, if you have them),
#'  NULL (default) will use local files if available, and network if not.
#' @return File name or URL for netCDF file containing the requested data 
TWCR.hourly.get.file.name<-function(variable,year,month,day,hour,opendap=NULL,version=2,type='mean') {
   if(is.null(opendap) || opendap==FALSE) {
        base.dir<-TWCR.get.data.dir(version)
        if(!is.null(base.dir)) {
            name<-NULL
            if(type=='normal') {
                    name<-sprintf("%s/hourly/normals/%s.nc",base.dir,variable)
            }
            if(type=='standard.deviation') {
                    if(month==2 && day==29) day=28
                    name<-sprintf("%s/hourly/standard.deviations/%s/sd.%02d.%02d.%02d.rdata",
                                   base.dir,variable,month,day,hour)
            }
            if(type=='mean') {
               name<-sprintf("%s/hourly/%s/%s.%04d.nc",base.dir,
                           variable,variable,year)
            }
            if(type=='spread') {
               name<-sprintf("%s/hourly/%s/%s.%04d.spread.nc",base.dir,
                           variable,variable,year)
            }
            if(is.null(name)) stop(sprintf("Unsupported data type %s",type))
            if(file.exists(name)) return(name)
            if(!is.null(opendap) && opendap==FALSE) stop(sprintf("No local file %s",name))
          }
      }
    if(version!=2 && version!='3.2.1') stop('Opendap only available for version 2')
    base.dir<-'http://www.esrl.noaa.gov/psd/thredds/dodsC/Datasets/20thC_ReanV2/'
    if(type=='mean') {
        if(TWCR.get.variable.group(variable)=='monolevel') {
          base.dir<-sprintf("%s/monolevel/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='gaussian') {
          base.dir<-sprintf("%s/gaussian/monolevel/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='pressure') {
          base.dir<-sprintf("%s/pressure/",base.dir)
        }
       return(sprintf("%s/%s.%04d.nc",base.dir,
                   variable,year))
    }
    if(type=='spread') {
        if(TWCR.get.variable.group(variable)=='monolevel') {
          base.dir<-sprintf("%s/monolevel_sprd/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='gaussian') {
          base.dir<-sprintf("%s/gaussian_sprd/monolevel/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='pressure') {
          base.dir<-sprintf("%s/pressure_sprd/",base.dir)
        }
        return(sprintf("%s/%s.%04d.nc",base.dir,
                   variable,year))
    }
    if(type=='normal') {
        if(TWCR.get.variable.group(variable)=='monolevel') {
          return(sprintf("%s/Derived/4Xdailies/monolevel/%s.4Xday.1981-2010.ltm.nc",base.dir,variable))
        } 
        if(TWCR.get.variable.group(variable)=='gaussian') {
          return(sprintf("%s/Derived/8Xdailies/gaussian/monolevel/%s.8Xday.1981-2010.ltm.nc",base.dir,variable))
        }
        if(TWCR.get.variable.group(variable)=='pressure') {
          return(sprintf("%s/Derived/4Xdailies/pressure/%s.4Xday.1981-2010.ltm.nc",base.dir,variable))
        } 
    }
    if(type=='standard.deviation') {
      if(version==2) version<-'3.2.1'
      if(month==2 && day==29) day<-28
      return(sprintf("http://s3.amazonaws.com/philip.brohan.org.20CR/version_%s/hourly/standard.deviations/%s/sd.%02d.%02d.%02d.rdata",
                    version,variable,month,day,hour))
    }
    stop(sprintf("Unsupported opendap data type %s",type))      
}

#' TWCR get file name (monthly)
#'
#' Get the file name (or URL) for selected variable and date (monthly data)
#'
#' Called internally by \code{TWCR.get.slice.at.month} but also useful
#'  called directly - you can then access the data with another tool.
#'
#' @export
#' @param variable 'prmsl', 'prate', 'air.2m', 'uwnd.10m' or 'vwnd.10m' - or any 20CR variable
#' @param type - 'mean', 'spread', 'normal', or 'standard.deviation'. 
#'  Note that standard deviations are not available over opendap.
#' @param opendap TRUE for network retrieval, FALSE for local files (faster, if you have them),
#'  NULL (default) will use local files if available, and network if not.
#' @return File name or URL for netCDF file containing the requested data 
TWCR.monthly.get.file.name<-function(variable,year,month,opendap=NULL,version=2,type='mean') {
   if(is.null(opendap) || opendap==FALSE) {
        base.dir<-TWCR.get.data.dir(version)
        if(!is.null(base.dir)) {
            name<-NULL
            if(type=='normal') {
                    name<-sprintf("%s/monthly/normals/%s.pp",base.dir,variable)
            }
            if(type=='standard.deviation') {
                    name<-sprintf("%s/monthly/standard.deviations/%s.pp",base.dir,variable)
            }
            if(type=='mean') {
               name<-sprintf("%s/monthly/variables/%s.mean.nc",base.dir,
                           variable)
            }
            if(type=='spread') {
               name<-sprintf("%s/monthly/variables/%s.spread.nc",base.dir,
                           variable)
             }
            if(is.null(name)) stop(sprintf("Unsupported data type %s",type))
            if(file.exists(name)) return(name)
            if(!is.null(opendap) && opendap==FALSE) stop(sprintf("No local file %s",name))
          }
      }
    if(version!=2 && version!='3.2.1') stop('Opendap only available for version 2')
    base.dir<-'http://www.esrl.noaa.gov/psd/thredds/dodsC/Datasets/20thC_ReanV2/'
    if(type=='mean') {
        if(TWCR.get.variable.group(variable)=='monolevel') {
          base.dir<-sprintf("%s/Monthlies/monolevel/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='gaussian') {
          base.dir<-sprintf("%s/Monthlies/gaussian/monolevel/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='pressure') {
          base.dir<-sprintf("%s/Monthlies/pressure/",base.dir)
        }
       return(sprintf("%s/%s.%04d.nc",base.dir,
                   variable,year))
    }
    if(type=='spread') {
        if(TWCR.get.variable.group(variable)=='monolevel') {
          base.dir<-sprintf("%s/Monthlies/monolevel_sprd/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='gaussian') {
          base.dir<-sprintf("%s/Monthlies/gaussian_sprd/monolevel/",base.dir)
        }
        if(TWCR.get.variable.group(variable)=='pressure') {
          base.dir<-sprintf("%s/Monthlies/pressure_sprd/",base.dir)
        }
        return(sprintf("%s/%s.%04d.nc",base.dir,
                   variable,year))
    }
    if(type=='normal') {
        if(TWCR.get.variable.group(variable)=='monolevel') {
          return(sprintf("%s/Derived/Monthlies/monolevel/%s.1981-2010.ltm.nc",base.dir,variable))
        } 
        if(TWCR.get.variable.group(variable)=='gaussian') {
          return(sprintf("%s/Derived/Monthlies/gaussian/monolevel/%s.1981-2010.ltm.nc",base.dir,variable))
        }
        if(TWCR.get.variable.group(variable)=='pressure') {
          return(sprintf("%s/Derived/Monthlies/pressure/%s.1981-2010.ltm.nc",base.dir,variable))
        } 
    }
    stop(sprintf("Unsupported opendap data type %s",type))      
}

#' Get the observations from 1 prepbufr file
#'
#' All the observations used in one analysis run
#'  (0,6,12,18 hours each day).
#'
#' Specification of obs format is at
#' http://rda.ucar.edu/datasets/ds131.1/docs/ISPD_quick_assimilated_ascii_format.pdf
#' file access only - the observations feedback files are not online.
#' 
#' @export
#' @return A data frame - one row for each observation.
TWCR.get.obs.1file<-function(year,month,day,hour,version=2) {
    base.dir<-TWCR.get.data.dir(version)
    if(is.null(base.dir)) stop("No local TWCR files on this system")
    of.name<-sprintf(
                "%s/observations/%04d/prepbufrobs_assim_%04d%02d%02d%02d.txt",base.dir,
                year,year,month,day,hour)
    if(!file.exists(of.name)) stop("No obs file for given version and date")
    o<-read.fwf(file=of.name,na.strings=c('NA','*','***','*****','*******','**********',
                                          '-99','9999','-999','9999.99','10000.0',
                                          '-9.99','999999999999999999999999999999',
                                          '999999999999','9'),
                widths=c(19,-1,3,-1,1,-1,7,-1,6,-1,5,-1,5,-1,6,-1,7,-1,7,-1,7,
                         -1,10,-1,5,-1,5,-1,1,-1,1,-1,1,-1,1,-1,1,-1,10,-1,10,
                         -1,10,-1,10,-1,30,-1,14),
                col.names=c('UID','NCEP.Type','Variable','Longitude','Latitude',
                            'Elevation','Model.Elevation','Time.Offset',
                            'Pressure.after.bias.correction',
                            'Pressure.after.vertical.interpolation',
                            'SLP','Bias',
                            'Error.in.surface.pressure',
                            'Error.in.vertically.interpolated.pressure',
                            'Assimilation.indicator',
                            'Usability.check',
                            'QC.flag',
                            'Background.check',
                            'Buddy.check',
                            'Mean.first.guess.pressure.difference',
                            'First.guess.pressure.spread',
                            'Mean.analysis.pressure.difference',
                            'Analysis.pressure.spread',
                            'Name','ID'),
                  header=F,stringsAsFactors=F,
                  colClasses=c('character','integer','character',
                               rep('numeric',2),
                               rep('integer',2),
                               rep('numeric',7),
                               rep('integer',5),
                               rep('numeric',4),
                               rep('character',2)),
                  comment.char="")

    return(o)
}

#' TWCR get observations
#'
#' Retrieves observations from the obs. feedback (prepbufr) files
#' Gets all obs in +-range days around specified date
#'
#' Specification of obs format is at
#' http://rda.ucar.edu/datasets/ds131.1/docs/ISPD_quick_assimilated_ascii_format.pdf
#' File access only - the observations feedback files are not online.
#'
#' @seealso \code{TWCR.get.obs.1file} get the observations for a specific
#'  analysis run.
#' @export
#' @param range Date range (in days) to retrieve observations from - period is
#'  specified time +- range days (default is 0.5 - giving 1 day's obs).
#' @return A data frame - one row for each observation.
TWCR.get.obs<-function(year,month,day,hour,version=2,range=0.5) {
    base.dir<-TWCR.get.data.dir(version)
    if(is.null(base.dir)) stop("No local TWCR files on this system")
    today<-chron(dates=sprintf("%04d/%02d/%02d",year,month,day),
          times=sprintf("%02d:00:00",hour),
          format=c(dates='y/m/d',times='h:m:s'))
    result<-NULL
    for(hour2 in seq(today-range,today+range,1/24)) {
       of.name<-sprintf(
                "%s/observations/%04d/prepbufrobs_assim_%04d%02d%02d%02d.txt",base.dir,
                 as.integer(as.character(years(hour2))),
                 as.integer(as.character(years(hour2))),
                 months(hour2),days(hour2),hours(hour2))
        if(!file.exists(of.name)) next
        o<-TWCR.get.obs.1file(as.integer(as.character(years(hour2))),
                               months(hour2),days(hour2),hours(hour2),version)
        odates<-chron(dates=sprintf("%04d/%02d/%02d",as.integer(substr(o$UID,1,4)),
                                                     as.integer(substr(o$UID,5,6)),
                                                     as.integer(substr(o$UID,7,8))),
                      times=sprintf("%02d:00:00",as.integer(substr(o$UID,9,10))),
                      format=c(dates='y/m/d',times='h:m:s'))
         o<-o[abs(today-odates)<=range,]
        if(is.null(result)) result<-o
        else result<-rbind(result,o)
     }
    return(result)
}

TWCR.is.in.file<-function(variable,year,month,day,hour,type='mean') {
		if(hour%%6==0) return(TRUE)
		return(FALSE)
}

# Go backward and forward in hours to find previous and subsequent
#  hours at an analysis time.
# Could do this directly, but it's vital to keep get.interpolation.times
# and is.in.file consistent.
TWCR.get.interpolation.times<-function(variable,year,month,day,hour,type='mean') {
	if(TWCR.is.in.file(variable,year,month,day,hour,type=type)) {
		stop("Internal interpolation failure")
	}
	ct<-chron(dates=sprintf("%04d/%02d/%02d",year,month,day),
	          times=sprintf("%02d:00:00",hour),
	          format=c(dates='y/m/d',times='h:m:s'))
	t.previous<-list()
        back.hours=1
	while(back.hours<24) {
		p.hour<-hour-back.hours
                p.year<-year
                p.month<-month
                p.day<-day
                if(p.hour<0) {
                  p.year<-as.numeric(as.character(years(ct-1)))
                  p.month<-as.integer(months(ct-1))
                  p.day<-as.integer(days(ct-1))
                  p.hour<-p.hour+24
                }
		if(TWCR.is.in.file(variable,p.year,p.month,p.day,p.hour,type=type)) {
			t.previous$year<-p.year
			t.previous$month<-p.month
			t.previous$day<-p.day
			t.previous$hour<-p.hour
			break
		}
                back.hours<-back.hours+1
	}
	if(length(t.previous)<4) {
		stop("Interpolation failure, too far back")
	}
	t.next<-list()
	forward.hours<-1
	while(forward.hours<24) {
		n.hour<-hour+forward.hours
                n.year<-year
                n.month<-month
                n.day<-day
                if(n.hour>23) {
                  n.year<-as.numeric(as.character(years(ct+1)))
                  n.month<-as.integer(months(ct+1))
                  n.day<-as.integer(days(ct+1))
                  n.hour<-n.hour-24
                }
		if(TWCR.is.in.file(variable,n.year,n.month,n.day,n.hour,type=type)) {
			t.next$year<-n.year
			t.next$month<-n.month
			t.next$day<-n.day
			t.next$hour<-n.hour
			break
		}
                forward.hours<-forward.hours+1
	}
	if(length(t.next)<4) {
		stop("Interpolation failure, too far forward")
	}
	return(list(t.previous,t.next))
}

# This is the function users will call.
#' Get slice at hour.
#'
#' Get a 2D horizontal slice of a selected variable (as a GSDF field) for a given hour.
#'
#' Interpolates to the selected hour when the data available are less than hourly.
#' Interpolates to the selected height when the selected height is not that of a 20RC level.
#'
#' @export
#' @param variable 'prmsl', 'prate', 'air.2m', 'uwnd.10m' or 'vwnd.10m' - or any 20CR variable
#' @param type - 'mean' (default), 'spread', 'normal', or 'standard.deviation'. 
#'  Note that standard deviations are not available over opendap.
#' @param height Height in hPa - leave NULL for monolevel
#' @param opendap TRUE for network retrieval, FALSE for local files (faster, if you have them), NULL (default)
#'  will use local files if available and network otherwise.
#' @return A GSDF field with lat and long as extended dimensions
TWCR.get.slice.at.hour<-function(variable,year,month,day,hour,height=NULL,opendap=NULL,version=2,type='mean') {
  if(TWCR.get.variable.group(variable)=='monolevel' ||
     TWCR.get.variable.group(variable)=='gaussian') {
    if(!is.null(height)) warning("Ignoring height specification for monolevel variable")
    return(TWCR.get.slice.at.level.at.hour(variable,year,month,day,hour,opendap=opendap,version=version,type=type))
  }
  # Find levels above and below selected height, and interpolate between them
  if(is.null(height)) stop(sprintf("No height specified for pressure variable %s",variable))
  if(height>1000 || height<10) stop("Height must be between 10 and 1000 hPa")
  level.below<-max(which(TWCR.heights>=height))
  if(height==TWCR.heights[level.below]) {
    return(TWCR.get.slice.at.level.at.hour(variable,year,month,day,hour,height=TWCR.heights[level.below],
                                         opendap=opendap,version=version,type=type))
  }
  below<-TWCR.get.slice.at.level.at.hour(variable,year,month,day,hour,height=TWCR.heights[level.below],
                                         opendap=opendap,version=version,type=type)
  above<-TWCR.get.slice.at.level.at.hour(variable,year,month,day,hour,height=TWCR.heights[level.below+1],
                                         opendap=opendap,version=version,type=type)
  above.weight<-(TWCR.heights[level.below]-height)/(TWCR.heights[level.below]-TWCR.heights[level.below+1])
  below$data[]<-below$data*(1-above.weight)+above$data*above.weight
  idx.h<-GSDF.find.dimension(below,'height')
  below$dimensions[[idx.h]]$value<-height
  return(below)
}

TWCR.get.slice.at.level.at.hour<-function(variable,year,month,day,hour,height=NULL,opendap=NULL,version=2,type='mean') {
	dstring<-sprintf("%04d-%02d-%02d:%02d",year,month,day,hour)
	# Is it from an analysis time (no need to interpolate)?
	if(TWCR.is.in.file(variable,year,month,day,hour,type=type)) {
        file.name<-TWCR.hourly.get.file.name(variable,year,month,day,hour,opendap=opendap,version=version,type=type)
           if(type=='standard.deviation') { # sd's are a special case
              if(grepl('://',file.name)) { # Is it a URL?
                u<-url(file.name)
                load(u)
                close(u)
              } else {
                 load(file.name)
              }
              return(twcr.sd)
           }   
           t<-chron(sprintf("%04d/%02d/%02d",year,month,day),sprintf("%02d:00:00",hour),
                    format=c(dates='y/m/d',times='h:m:s'))
           if(type=='normal') { # Normals are for year 1, which chron can't handle, and have no Feb 29
               month<-as.integer(month) # Sometimes still a factor, why?
               day<-as.integer(day)
               if(month==2 && day==29) day<-28
              t<-chron(sprintf("%04d/%02d/%02d",-1,month,day),sprintf("%02d:00:00",hour),
                       format=c(dates='y/m/d',times='h:m:s'))
              t<-chron(as.numeric(t)+729)
           }
           v<-GSDF.ncdf.load(file.name,variable,lat.range=c(-90,90),lon.range=c(0,360),
                             height.range=rep(height,2),time.range=c(t,t))
	   return(v)
	}
	# Interpolate from the previous and subsequent analysis times
	interpolation.times<-TWCR.get.interpolation.times(variable,year,month,day,hour,type=type)
	v1<-TWCR.get.slice.at.level.at.hour(variable,interpolation.times[[1]]$year,interpolation.times[[1]]$month,
		                               interpolation.times[[1]]$day,interpolation.times[[1]]$hour,
                                               height=height,opendap=opendap,version=version,type=type)
	v2<-TWCR.get.slice.at.level.at.hour(variable,interpolation.times[[2]]$year,interpolation.times[[2]]$month,
		                               interpolation.times[[2]]$day,interpolation.times[[2]]$hour,
                                               height=height,opendap=opendap,version=version,type=type)
	c1<-chron(dates=sprintf("%04d/%02d/%02d",interpolation.times[[1]]$year,
	                                         interpolation.times[[1]]$month,
	                                         interpolation.times[[1]]$day),
	          times=sprintf("%02d:00:00",interpolation.times[[1]]$hour),
	          format=c(dates='y/m/d',times='h:m:s'))
	c2<-chron(dates=sprintf("%04d/%02d/%02d",interpolation.times[[2]]$year,
	                                         interpolation.times[[2]]$month,
	                                         interpolation.times[[2]]$day),
	          times=sprintf("%02d:00:00",interpolation.times[[2]]$hour),
	          format=c(dates='y/m/d',times='h:m:s'))
	c3<-chron(dates=sprintf("%04d/%02d/%02d",year,month,day),
	          times=sprintf("%02d:00:00",hour),
	          format=c(dates='y/m/d',times='h:m:s'))
    if(c2==c1) stop("Zero interval in time interpolation")
    weight<-as.numeric((c2-c3)/(c2-c1))
    v<-v1
    idx.t<-GSDF.find.dimension(v,'time')
    v$dimensions[[idx.t]]$value<-v1$dimensions[[idx.t]]$value+
                                 as.numeric(v2$dimensions[[idx.t]]$value-v1$dimensions[[idx.t]]$value)*(1-weight)
    v$data[]<-v1$data*weight+v2$data*(1-weight)
        return(v)
}

# Same, but for monthly data
#' Get slice at month.
#'
#' Get a 2D horizontal slice of a selected variable (as a GSDF field) for a given month.
#'
#' Interpolates to the selected height when the selected height is not that of a 20RC level.
#'
#' @export
#' @param variable 'prmsl', 'prate', 'air.2m', 'uwnd.10m' or 'vwnd.10m' - or any 20CR variable
#' @param type - 'mean', 'spread', 'normal', or 'standard.deviation'. 
#'  Note that standard deviations are not available over opendap.
#' @param height Height in hPa - leave NULL for monolevel
#' @param opendap TRUE for network retrieval, FALSE for local files (faster, if you have them).
#' @return A GSDF field with lat and long as extended dimensions
TWCR.get.slice.at.month<-function(variable,year,month,height=NULL,opendap=TRUE,version=2,type='mean') {
  if(TWCR.get.variable.group(variable)=='monolevel' ||
     TWCR.get.variable.group(variable)=='gaussian') {
    if(!is.null(height)) warning("Ignoring height specification for monolevel variable")
    return(TWCR.get.slice.at.level.at.month(variable,year,month,opendap=opendap,version=version,type=type))
  }
  # Find levels above and below selected height, and interpolate between them
  if(is.null(height)) stop(sprintf("No height specified for pressure variable %s",variable))
  if(height>1000 || height<10) stop("Height must be between 10 and 1000 hPa")
  level.below<-max(which(TWCR.heights>=height))
  if(height==TWCR.heights[level.below]) {
    return(TWCR.get.slice.at.level.at.month(variable,year,month,height=TWCR.heights[level.below],
                                         opendap=opendap,version=version,type=type))
  }
  below<-TWCR.get.slice.at.level.at.month(variable,year,month,height=TWCR.heights[level.below],
                                         opendap=opendap,version=version,type=type)
  above<-TWCR.get.slice.at.level.at.month(variable,year,month,height=TWCR.heights[level.below+1],
                                         opendap=opendap,version=version,type=type)
  above.weight<-(TWCR.heights[level.below]-height)/(TWCR.heights[level.below]-TWCR.heights[level.below+1])
  below$data[]<-below$data*(1-above.weight)+above$data*above.weight
  idx.h<-GSDF.find.dimension(below,'height')
  below$dimensions[[idx.h]]$value<-height
  return(below)
}
TWCR.get.slice.at.level.at.month<-function(variable,year,month,height=NULL,opendap=FALSE,version=2,type='mean') {
    file.name<-TWCR.monthly.get.file.name(variable,year,month,opendap=opendap,version=version,type=type)
           t1<-chron(sprintf("%04d/%02d/%02d",year,month,1),"00:00:00",
                    format=c(dates='y/m/d',times='h:m:s'))
           if(opendap && type=='normal') { # Online normals are for year 1, which chron can't handle, and have no Feb 29
              t<-chron(sprintf("%04d/%02d/%02d",-1,month,1),"00:00:00",
                       format=c(dates='y/m/d',times='h:m:s'))
              t<-chron(as.numeric(t)+729)
           }
           if(!opendap && (type=='normal' || type=='standard.deviation')) { # Local mean and sd files are for 1964
              t<-chron(sprintf("%04d/%02d/%02d",1964,month,day),"00:00:00",
                       format=c(dates='y/m/d',times='h:m:s'))
           }   
           v<-GSDF.ncdf.load(file.name,variable,lat.range=c(-90,90),lon.range=c(0,360),
                             height.range=rep(height,2),time.range=c(t,t+27))
     return(v)
}

#' Relative Entropy
#'
#' Estimates the Relative Entropy (Kullback-Liebler divergence)
#' between two fields, given the mean and standard deviation) or
#' each.
#'
#' This is a useful metric for 20CR - typical comparison is between
#' climatological and TWCR distributions. In principle we could extend
#' this to do multivariate comparisons (sets of fields) but this function
#' doesn't currently allow this.
#'
#' @export
#' @param old.mean Field of best estimates from climatology
#' @param old.sd Field of climatological standard deviations
#' @param new.mean Field of best estimates from TWCR
#' @param new.sd Field of standard deviations from TWCR
#' @return Field of relative entropy
TWCR.relative.entropy<-function(old.mean,old.sd,new.mean,
                                 new.sd) {
  result<-new.mean
  result$data[]<-(log((new.sd$data**2)/(old.sd$data**2)) +
                 (old.sd$data**2)/(new.sd$data**2) +
                 ((new.mean$data-old.mean$data)**2)/(new.sd$data**2) 
                   -1)*0.5
  return(result)
}

#' Relative Entropy spread.
#'
#' We only estimate the relative entropy, because we only have
#' estimates of the means and standard deviations. This
#' function estimates the spread of the relative entropy.
#'
#' Calculating a standard error for RE is hard, and it's an asymetric
#'  distribution so an exact sigma is of limited use anyway. This function
#'  estimates the value by perturbing the input means and standard
#'  deviations and combining the results in quadrature.
#'
#' @export
#' @param old.mean Field of best estimates from climatology
#' @param old.sd Field of climatological standard deviations
#' @param new.mean Field of best estimates from TWCR
#' @param new.sd Field of standard deviations from TWCR
#' @param new.n number of ensembles making up TWCR (default=56).
#' @return list with components upper (field of RE+n*sigma) and
#'   lower (field of RE-n*sigma).
TWCR.relative.entropy.spread<-function(old.mean,old.sd,new.mean,
                                       new.sd,new.n=56,
                                       perturbed.mean=NULL,
                                       perturbed.sd=NULL) {
  base.re<-TWCR.relative.entropy(old.mean,old.sd,new.mean,new.sd)
  if(is.null(perturbed.mean)) {
     perturbed.mean<-new.mean
     perturbed.mean$data[]<-new.mean$data*1.05
   }
  perturbed.mean.re<-TWCR.relative.entropy(old.mean,old.sd,perturbed.mean,new.sd)
  perturbed.mean$data[]<-perturbed.mean$data-new.mean$data
  perturbed.mean.re$data[]<-perturbed.mean.re$data-base.re$data
  if(is.null(perturbed.sd)) {
     perturbed.sd<-new.sd
     perturbed.sd$data[]<-new.sd$data*1.05
   }
  perturbed.sd.re<-TWCR.relative.entropy(old.mean,old.sd,new.mean,perturbed.sd)
  perturbed.sd$data[]<-perturbed.sd$data-new.sd$data
  perturbed.sd.re$data[]<-perturbed.sd.re$data-base.re$data
  mean.sd<-new.sd$data/sqrt(new.n)
  sd.sd<-TWCR.sds(new.sd$data,new.n)
  spread<-new.mean
  spread$data[]<-sqrt(((perturbed.mean.re$data/perturbed.mean$data)**2)*mean.sd**2+
                      ((perturbed.sd.re$data/perturbed.sd$data)**2)*sd.sd**2)
  return(spread)
}

# Estimate the standard deviation of the standard deviation
#  of a sample of n observations (assuming the distribution is normal).
TWCR.sds<-function(s,n){
  v1<-gamma(n/2)/gamma((n-1)/2)
  v2<-sqrt((n-1)/2 - v1**2)
  return(s*v2/v1)
}


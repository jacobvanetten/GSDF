#' GeoSpatial Data Field
#' 
#' A data structure to hold geospatial fields
#'
#' Fundamentally just a list with particular components:
#' \describe{
#'  \item{$data} {multidimensional array of numeric (may contain NAs)}
#'  \item{$dimensions} {a list: one element for each dimension}
#'  \item{$dimensions[[1]]} {details of the first dimension, contains:}
#'  \item{$dimensions[[1]]$type} {'lat', 'lon', 'height', 'time' or 'custom'}
#'  \item{$dimensions[[1]]$values} {lat/lon in degrees, height in hPa, time as chron.
#'       Length must equal length of $data in that dimension,
#'       order of dimensions is the same as in $data.}
#'  \item{$dimensions[[1]]$meta} {anything else (list - key-value pairs)}
#'  \item{$meta} {any other info (list - key-value pairs)} Notably:
#'       pole.lat - latitude of the pole used (assume 90 if unspecified)
#'       pole.lon - longitude of the pole used (assume 180 if unspecified)
#' }
#'
#' @export
#' @return A list as described (all components empty)
#' @seealso \code{\link{GSDF.print}} Print such a field
#' @seealso \code{\link{GSDF.ncdf.load}} Create a field from data file or openDAP URL
#' @seealso \code{\link{GSDF.plot.2d}} Plot the field (if it's 2-dimensional)
#' @seealso \code{\link{GSDF.interpolate.2d}} Bilinear interpolation in the field (if it's 2-dimensional
#' @seealso \code{\link{GSDF.regrid.2d}} Regrid a field to match another (if both are 2-dimensional))
GSDF<-function() {
   result<-list()
   result$data<-numeric(0)
   result$dimensions<-list()
   result$meta<-list()
   return(result)
}

#' Print a GSDF structure
#' 
#' \code{GSDF.print} prints a condensed version of the structure
#'  provided as its first argument.
#'
#' @export
#' @param g GSDF structure to print
GSDF.print<-function(g) {
   for(i in seq_along(g$dimensions)) {
      print(sprintf("%s %d",g$dimensions[[i]]$type,
                        length(g$dimensions[[i]]$values)))
      print(g$dimensions[[i]]$values)
      if(length(g$dimensions[[i]]$meta)>0) {
          print(g$dimensions[[i]]$meta)
      }
   }
   if(length(g$meta)>0) print(g$meta)
}

#' Find the index of a named dimension
#'
#' Identify the dimension that contains 'lat', 'time' etc.
#' 
#' If the first dimension in g is 'lat', the second 'time', and 
#' the third 'lon', \code{GSDF.find.dimensions(g,'lon')} will
#' return 3.
#'
#' @export
#' @param g GSDF structure
#' @param label text string, 'lat','lon', or 'time'
#' @return Integer number of requested dimension, or NULL if not present.
GSDF.find.dimension<-function(g,label) {
  for(d in seq_along(g$dimensions)) {
     if(g$dimensions[[d]]$type==label) return(d)
  }
  return(NULL)
}  

#' Roll-out a pair of dimensions
#'
#' Get (for example) lat for each point in a 2d slice
#'
#' If g has 2 dimensions, 'lat' and 'lon', each of length 10, 
#' \code{GSDF.roll.dimensions(g,1,2)} will return the latitude
#' for each of the 100 points in the slice; and
#' \code{GSDF.roll.dimensions(g,2,1)} will return the longitude
#' similarly.
#'
#' @export
#' @param g GSDF data structure
#' @param d1 integer index of first dimension
#' @param d2 integer index of second dimension
#' @return numeric vector of first dimension values 
GSDF.roll.dimensions<-function(g,d1,d2) {
  results<-list()
  if(d1<=d2) {
     return(rep(g$dimensions[[d1]]$values,
                  length(g$dimensions[[d2]]$values)))
  } else {
     return(as.vector(matrix(data=rep(g$dimensions[[d1]]$values,
                                   length(g$dimensions[[d2]]$values)),
                            nrow=length(g$dimensions[[d2]]$values),
                            ncol=length(g$dimensions[[d1]]$values),
                            byrow=T)))
  }
}

#' Interpolate points in a 2d field
#'
#' 2d bilinear interpolation (uses fields package)
#'
#' Interpolate values at a set of x,y points in a
#' 2d field. Note that x is the first dimension in the field
#' and y the second dimension whatever the names of those dimensions.
#' The field must have exactly 2 extended dimensions.
#'
#' @export
#' @param g GSDF data structure
#' @param x values to interpolate to in 1st dimension
#' @param y values to interpolate to in 2nd dimension
#' @return numeric vector of interpolated values
#' @seealso \code{\link{GSDF.regrid.2d}} regrid 1 field to match another
GSDF.interpolate.2d<-function(g,x,y) {
   if(length(x) != length(y)) stop("Mismatch in interpolation points")
   # Must have exactly 2 extended dimensions
   dims<-GSDF.get.extended.dimensions(g)
   if(length(dims)!=2) {
      stop('Must have exactly 2 extended dimensions')
   }
   grid<-array(data=g$data,dim=c(length(g$dimensions[[dims[1]]]$values),
                                 length(g$dimensions[[dims[2]]]$values)))
   interp<-interp.surface(list(x=g$dimensions[[dims[1]]]$values,
                               y=g$dimensions[[dims[2]]]$values,z=grid),
                          cbind(x,y))
   return(interp)
}

#' Interpolate lat:lon points in a 2d field
#'
#' 2d bilinear interpolation (uses fields package)
#'
#' Basically the same as \code{\link{GSDF.interpolate.2d}} except
#' that we check that the field has lat and lon as dimensions
#' and arrange them in the right order.
#'
#' @export
#' @param g GSDF data structure (must have lat and lon as dimensions)
#' @param lat latitudes to interpolate to
#' @param lon longitude values to interpolate to
#' @param full - TRUE => apply appropriate boundary conditions for full
#'   global lat:lon field (wrap longitudes and extrapolate near poles if required,
#'   FALSE => just interpolate (removes data outside range of g),
#'   NULL (default) => Guess which to do (is field ll and covering most of globe?).
#' @return numeric vector of interpolated values
GSDF.interpolate.ll<-function(g,lat,lon,full=NULL) {
   dims<-GSDF.get.extended.dimensions(g)
   if(length(dims)!=2) {
      stop('Must have exactly 2 extended dimensions')
   }
   if(is.null(full)) full<-GSDF.is.full(g)
   if(g$dimensions[[dims[1]]]$type=='lat') {
     if(g$dimensions[[dims[2]]]$type=='lon') {
       if(full) {
        lat<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[1]]]$values,
                                                  lat,g$dimensions[[dims[1]]]$type)
        lon<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[2]]]$values,
                                                  lon,g$dimensions[[dims[2]]]$type)
        g<-GSDF.pad.longitude(g)
      }
       return(GSDF.interpolate.2d(g,lat,lon))
     } else stop("Field has no longitudes")
   }
   if(g$dimensions[[dims[1]]]$type=='lon') {
     if(g$dimensions[[dims[2]]]$type=='lat') {
       if(full) {
        lat<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[2]]]$values,
                                                  lat,g$dimensions[[dims[2]]]$type)
        lon<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[1]]]$values,
                                                  lon,g$dimensions[[dims[1]]]$type)
        g<-GSDF.pad.longitude(g)
      }
       return(GSDF.interpolate.2d(g,lon,lat))
     } else stop("Field has no latitudes")
   }
   stop("Field is not lat:lon")
 }

#' Regrid a 2d field to match another 2d field
#'
#' Makes the first field  have the same grid as the second
#'
#' Both fields must have exactly 2 extended dimensions, and those dimensions
#' must have the same labels (e.g. both lat,long, or both lat,height).
#'
#' @export
#' @param g 2d GSDF field
#' @param g.grid 2d GSDF field with same set of dimensions
#' @param full - TRUE => apply appropriate boundary conditions for full
#'   global lat:lon field (wrap longitudes and extrapolate near poles if required,
#'   FALSE => just interpolate (removes data outside range of g.grid),
#'   NULL (default) => Guess which to do (is field ll and covering most of globe?).
#' @return GSDF field with data from g on grid of g.grid
GSDF.regrid.2d<-function(g,g.grid,full=NULL) {
   dims<-GSDF.get.extended.dimensions(g)
   if(length(dims)!=2) {
      stop('Field must have exactly 2 extended dimensions')
   }
   dims.grid<-GSDF.get.extended.dimensions(g.grid)
   if(length(dims.grid)!=2) {
      stop('Grid field must have exactly 2 extended dimensions')
   }
   if(is.null(full)) full<-GSDF.is.full(g.grid)
   g.pole.lat<-90
   if(!is.null(g$meta$pole.lat)) g.pole.lat<-g$meta$pole.lat
   g.pole.lon<-180
   if(!is.null(g$meta$pole.lon)) g.pole.lon<-g$meta$pole.lon
   g.grid.pole.lat<-90
   if(!is.null(g.grid$meta$pole.lat)) g.grid.pole.lat<-g.grid$meta$pole.lat
   g.grid.pole.lon<-180
   if(!is.null(g.grid$meta$pole.lon)) g.grid.pole.lon<-g.grid$meta$pole.lon
   result<-g
   result$dimensions<-g.grid$dimensions
   if(g$dimensions[[dims[1]]]$type == g.grid$dimensions[[dims.grid[1]]]$type &&
      g$dimensions[[dims[2]]]$type == g.grid$dimensions[[dims.grid[2]]]$type) {
      new.x<-GSDF.roll.dimensions(g.grid,dims[1],dims[2])
      new.y<-GSDF.roll.dimensions(g.grid,dims[2],dims[1])
      if(g.pole.lat != g.grid.pole.lat || g.pole.lon != g.grid.pole.lon) {
        result$meta$pole.lat<-g.grid.pole.lat
        result$meta$pole.lon<-g.grid.pole.lon
        if(g$dimensions[[dims[1]]]$type=='lat' &&
           g$dimensions[[dims[2]]]$type=='lon') {
           unrotated<-GSDF.rg.to.ll(new.x,new.y,
                                    g.grid.pole.lat,g.grid.pole.lon)
           rerotated<-GSDF.ll.to.rg(unrotated$lat,unrotated$lon,
                                    g.pole.lat,g.pole.lon)
           new.x<-rerotated$lat
           new.y<-rerotated$lon
        }
        if(g$dimensions[[dims[1]]]$type=='lon' &&
           g$dimensions[[dims[2]]]$type=='lat') {
           unrotated<-GSDF.rg.to.ll(new.y,new.x,
                                    g.grid.pole.lat,g.grid.pole.lon)
           rerotated<-GSDF.ll.to.rg(unrotated$lat,unrotated$lon,
                                    g.pole.lat,g.pole.lon)
           new.x<-rerotated$lon
           new.y<-rerotated$lat
        }
        if(g$dimensions[[dims[1]]]$type!='lon' && g$dimensions[[dims[1]]]$type!='lat') {
          stop('Regriding non-lat-lon grids with duifferent poles is not supported')
        }
      }   
      if(full) {
        new.x<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[1]]]$values,
                                                  new.x,g$dimensions[[dims[1]]]$type)
        new.y<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[2]]]$values,
                                                  new.y,g$dimensions[[dims[2]]]$type)
        g<-GSDF.pad.longitude(g)
      }  
      result$data<-array(data=GSDF.interpolate.2d(g,new.x,new.y),
                         dim=dim(g.grid$data))
      return(result)
   }
   if(g$dimensions[[dims[1]]]$type == g.grid$dimensions[[dims.grid[2]]]$type &&
      g$dimensions[[dims[2]]]$type == g.grid$dimensions[[dims.grid[1]]]$type) {
      new.x<-GSDF.roll.dimensions(g.grid,dims[2],dims[1])
      new.y<-GSDF.roll.dimensions(g.grid,dims[1],dims[2])
      if(g.pole.lat != g.grid.pole.lat || g.pole.lon != g.grid.pole.lon) {
        result$meta$pole.lat<-g.grid.pole.lat
        result$meta$pole.lon<-g.grid.pole.lon
        if(g$dimensions[[dims[1]]]$type=='lon' &&
           g$dimensions[[dims[2]]]$type=='lat') {
           unrotated<-GSDF.rg.to.ll(new.y,new.x,
                                    g.grid.pole.lat,g.grid.pole.lon)
           rerotated<-GSDF.ll.to.rg(unrotated$lat,unrotated$lon,
                                    g.pole.lat,g.pole.lon)
           new.x<-rerotated$lat
           new.y<-rerotated$lon
        }
        if(g$dimensions[[dims[1]]]$type=='lat' &&
           g$dimensions[[dims[2]]]$type=='lon') {
           unrotated<-GSDF.rg.to.ll(new.x,new.y,
                                    g.grid.pole.lat,g.grid.pole.lon)
           rerotated<-GSDF.ll.to.rg(unrotated$lat,unrotated$lon,
                                    g.pole.lat,g.pole.lon)
           new.x<-rerotated$lon
           new.y<-rerotated$lat
        }
        if(g$dimensions[[dims[1]]]$type!='lon' && g$dimensions[[dims[1]]]$type!='lat') {
          stop('Regriding non-lat-lon grids with duifferent poles is not supported')
        }
      }
      if(full) {
        new.x<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[2]]]$values,
                                                  new.x,g$dimensions[[dims[1]]]$type)
        new.y<-GSDF.regrid.2d.boundary.conditions(g$dimensions[[dims[1]]]$values,
                                                  new.y,g$dimensions[[dims[2]]]$type)
        g<-GSDF.pad.longitude(g)
      }  
      result$data<-array(data=GSDF.interpolate.2d(g,new.x,new.y),
                        dim=dim(g.grid$data))
      return(result)
   }
   stop("Incompatable fields - different dimensions")
}

#' GSDF extended dimensions
#'
#' Get the extended dimensions (those with length>1) from a field
#'
#' @export
#' @param g Field to extract dimensions from
#' @return Integer vector with indices of extended dimensions
GSDF.get.extended.dimensions<-function(g) {
   dims<-integer(0)
   for(d in seq_along(g$dimensions)) {
      if(length(g$dimensions[[d]]$values)>1) dims<-c(dims,d)
   }
   return(dims)
 }

#' GSDF is full field
#'
#' Is field lat:lon and global in scope?
#'
#' Interpolation can shrink a field round the edges,
#' this is not OK for global fields - we want to preserve global coverage
#' so identify those and treat then specially.
#' Also this deals with wrap-arounds in longitude (0:360 v -180:180).
#'
#' @param g.grid Field to test
#' @return logical: TRUE if full, FALSE otherwise
GSDF.is.full<-function(g.grid) {
   dims.grid<-GSDF.get.extended.dimensions(g.grid)
   if(length(dims.grid)!=2) return(FALSE)
   if( (g.grid$dimensions[[dims.grid[1]]]$type=='lat' &&
          g.grid$dimensions[[dims.grid[2]]]$type=='lon' &&
          (max(g.grid$dimensions[[dims.grid[1]]]$values)-
          min(g.grid$dimensions[[dims.grid[1]]]$values)>160) &&
          (max(g.grid$dimensions[[dims.grid[2]]]$values)-
          min(g.grid$dimensions[[dims.grid[2]]]$values)>340)) ||
          (g.grid$dimensions[[dims.grid[1]]]$type=='lon' &&
          g.grid$dimensions[[dims.grid[2]]]$type=='lat' &&
          (max(g.grid$dimensions[[dims.grid[1]]]$values)-
          min(g.grid$dimensions[[dims.grid[1]]]$values)>340) &&
          (max(g.grid$dimensions[[dims.grid[2]]]$values)-
          min(g.grid$dimensions[[dims.grid[2]]]$values)>160))) return(TRUE)
      else return(FALSE)
 }   

#' Apply boundary conditions to a field for interpolation
#'
#' Makes regrid.2d work correctly for globaly complete fields
#'
#' When the 'to' grid has higher resolution than the 'from'
#' grid, some 'from' points will be outside the span of the 'to'
#' points. Tweak the 'to' points to put them inside - effectively
#' this does constant extrapolation outside the bounds.
#' Also fixes the -180-180 or 0-360 inconsistency in longitude
#'  if 'old' and 'new' are different in this respect.
#'
#' @param old - 'from' points in 1-dimension
#' @param new - 'to' points
#' @param type - 'lat', 'lon' or other, apply periodic bc if 'lon'
#' @return revised 'new' points
GSDF.regrid.2d.boundary.conditions<-function(old,new,type) {
   if(type=='lon') {
      w<-which(new > max(old) & new-360 > min(old))
      if(length(w)>0) new[w]<-new[w]-360
      w<-which(new < min(old) & new+360 < max(old))
      if(length(w)>0) new[w]<-new[w]+360
    } else {
       w<-which(new > max(old))
       if(length(w)>0) new[w]<-max(old)
       w<-which(new < min(old))
       if(length(w)>0) new[w]<-min(old)
     }
    return(new)
}

#' Rotate lats and lons
#'
#' From standard pole to same positions in a rotated pole.
#' 
#' Convert latitudes and longitudes to the equivalents
#'  with a rotated pole. (Formulae from UMDP S1).
#'
#' @export
#' @param lat vector of latitudes in standard pole (degrees).
#' @param lon vector of longitudes in standard pole (degrees).
#' @param pole.lat latitude of pole to rotate to (degrees).
#' @param pole.lon longitude of pole to rotate to (degrees).
#' @return list with components 'lat' and 'lon' - vectors of
#'   rotated lat and lon (in degrees).
GSDF.ll.to.rg<-function(lat,lon,pole.lat,pole.lon) {

   if(pole.lat==90 && pole.lon==180) {
     return(list(lat=lat,lon=lon))
   }
   while(pole.lon>180) pole.lon<-pole.lon-360
   l0<-pole.lon+180
   lon<-lon-l0
   w<-which(!is.na(lon) & lon>=180)
   lon[w]<-lon[w]-360
   w<-which(!is.na(lon) & lon< -180)
   lon[w]<-lon[w]+360

   dtr<-pi/180
   sin.pole.lat<-sin(pole.lat*dtr)
   cos.pole.lat<-cos(pole.lat*dtr)
   if(pole.lat<0) {
      sin.pole.lat<- -sin.pole.lat
      cos.pole.lat<- -cos.pole.lat
   }
   
   lat.rotated<-asin(pmax(-1,pmin(1,-cos.pole.lat*
                                   cos(lon*dtr)*
                                   cos(lat*dtr)+
                                   sin.pole.lat*
                                   sin(lat*dtr))))
                         
   lon.rotated<-lon*0
   w<-which(cos(lat.rotated)>1.0e-6)
   cos.rotated<-lon*0
   cos.rotated[w]<-pmax(-1,pmin(1,(cos.pole.lat*
                                     sin(lat[w]*dtr)+
                                     sin.pole.lat*
                                     cos(lon[w]*dtr)*
                                     cos(lat[w]*dtr))/
                                     cos(lat.rotated[w])))
   lon.rotated[w]<-acos(cos.rotated[w])
   lon.rotated<-lon.rotated*sign(lon)
   lat.rotated<-lat.rotated/dtr
   lon.rotated<-lon.rotated/dtr
   w<-which(!is.na(lon.rotated) & lon.rotated>180)
   lon.rotated[w]<-lon.rotated[w]-360
   w<-which(!is.na(lon.rotated) & lon.rotated< -180)
   lon.rotated[w]<-lon.rotated[w]+360
   return(list(lat=lat.rotated,lon=lon.rotated))
 }

#' Reverse rotate lats and lons
#'
#' From rotated pole to same positions in a standard pole.
#' 
#' Convert latitudes and longitudes to the equivalents
#'  with a un-rotated pole. (Formulae from UMDP S1).
#'
#' @export
#' @param lat vector of latitudes in rotated pole (degrees).
#' @param lon vector of longitudes in rotated pole (degrees).
#' @param pole.lat latitude of pole to rotate from (degrees).
#' @param pole.lon longitude of pole to rotate from (degrees).
#' @return list with components 'lat' and 'lon' - vectors of
#'   un-rotated lat and lon (in degrees).
GSDF.rg.to.ll<-function(lat,lon,pole.lat,pole.lon) {

   if(pole.lat==90 && pole.lon==180) {
     return(list(lat=lat,lon=lon))
   }
   l0<-pole.lon+180
   dtr<-pi/180
   sin.pole.lat<-sin(pole.lat*dtr)
   cos.pole.lat<-cos(pole.lat*dtr)
   if(pole.lat<0) {
      sin.pole.lat<- -sin.pole.lat
      cos.pole.lat<- -cos.pole.lat
   }
   w<-which(!is.na(lon) & lon>180)
   lon[w]<-lon[w]-360
   w<-which(!is.na(lon) & lon< -180)
   lon[w]<-lon[w]+360
   w<-which(!is.na(lon) & lon==0) # Why discontinuity here
   lon[w]<-0.001
   
   lat.rotated<-asin(pmax(-1,pmin(1,cos.pole.lat*
                                  cos(lon*dtr)*
                                  cos(lat*dtr)+
                                  sin.pole.lat*
                                  sin(lat*dtr))))

   lon.rotated<-lon*0
   w<-which(cos(lat.rotated)>1.0e-6)
   lon.rotated[w]<-acos(pmax(-1,pmin(1,(-cos.pole.lat*
                                     sin(lat[w]*dtr)+
                                     sin.pole.lat*
                                     cos(lon[w]*dtr)*
                                     cos(lat[w]*dtr))/
                                     cos(lat.rotated[w]))))
   
   lon.rotated<-lon.rotated*sign(lon)
   lon.rotated<-lon.rotated+l0*dtr
   lat.rotated<-lat.rotated/dtr
   lon.rotated<-lon.rotated/dtr
   w<-which(!is.na(lon.rotated) & lon.rotated>180)
   lon.rotated[w]<-lon.rotated[w]-360
   w<-which(!is.na(lon.rotated) & lon.rotated< -180)
   lon.rotated[w]<-lon.rotated[w]+360
   return(list(lat=lat.rotated,lon=lon.rotated))
 }

#' Rotate winds - internal detail
#'
#' From u & v one pole to same in a different pole.
#' 
#' (Formulae from UMDP S1). Works for any vector field, not just winds.
#'
#' @param u vector of zonal wind speeds in source pole.
#' @param v vector of meridional wind speeds in source pole.
#' @param lat.orig vector of latitudes of wind vectors in source pole (degrees).
#' @param lon.orig vector of longitudes of wind vectors in source pole (degrees).
#' @param lat.new vector of latitudes of wind vectors in target pole (degrees).
#' @param lon.new vector of longitudes of wind vectors in target pole (degrees).
#' @param pole.lat latitude of pole to rotate to (degrees).
#' @param pole.lon longitude of pole to rotate to (degrees).
#' @return list with components 'u' and 'v' - vectors of
#'   rotated zonal and meridional wind speeds.
#' @seealso \code{\link{GSDF.ll.to.rg}} and \code{\link{GSDF.rg.to.ll}}.
GSDF.wind.to.pole.internal <-function(u,v,lat.orig,lon.orig,
                               lat.new,lon.new,
                               pole.lat,pole.lon=180) {

   if(pole.lat==90 && pole.lon==180) {
     return(list(u=u,v=v))
   }
   l0<-pole.lon+180
   w<-which(!is.na(l0) && l0>180)	
   l0[w]<-l0[w]-360
   w<-which(!is.na(l0) && l0< -180)
   l0[w]<-l0[w]+360

   dtr<-pi/180
   c1<- sin((lon.orig-l0)*dtr)*sin(lon.new*dtr)*sin(pole.lat*dtr)+
           cos((lon.orig-l0)*dtr)*cos(lon.new*dtr)
   w<-which(lon.new<0)
   c2<-sqrt(1-c1*c1)
   if(pole.lat>180) pole.lat<-pole.lat-360
   if(pole.lat>=0 && pole.lat<=90) c2[w]<-c2[w]*-1
   else c2[-w]<-c2[-w]*-1
   return(list(u=c1*u-c2*v,v=c1*v+c2*u))
}

#' Rotate winds 
#'
#' From u & v one pole to same in a different pole.
#' 
#' (Formulae from UMDP S1). Works for any vector field, not just winds.
#'
#' @export
#' @param u field of zonal wind speeds in source pole.
#' @param v field of meridional wind speeds in source pole.
#' @param pole.lat latitude of pole to rotate to (degrees).
#' @param pole.lon longitude of pole to rotate to (degrees).
#' @return list with components 'u' and 'v' - fields of
#'   rotated zonal and meridional wind speeds.
GSDF.wind.to.pole <-function(u,v,pole.lat,pole.lon=180) {
      u2<-GSDF.field.to.pole(u,pole.lat,pole.lon)
      v2<-GSDF.field.to.pole(v,pole.lat,pole.lon)
      lat.new<-GSDF.roll.dimensions(u2,GSDF.find.dimension(u2,'lat'),
                                       GSDF.find.dimension(u2,'lon'))
      lon.new<-GSDF.roll.dimensions(u2,GSDF.find.dimension(u2,'lon'),
                                       GSDF.find.dimension(u2,'lat'))
      ll.orig<-GSDF.rg.to.ll(lat.new,lon.new,pole.lat,pole.lon)
      r.u.v<-GSDF.wind.to.pole.internal(u2$data,v2$data,ll.orig$lat,
                                        ll.orig$lon,lat.new,lon.new,
                                        pole.lat,pole.lon)
      u2$data[]<-r.u.v$u
      v2$data[]<-r.u.v$v
      return(list(u=u2,v=v2))
}     

#' Rotate a field
#'
#' Keeps the same grid but moves the North pole to a different place.
#'
#' Effectively allows you to move the centre of the lat-lon grid (where
#'  distortion is low) to any position.
#'
#' @export
#' @param g field to be rotated
#' @param pole.lat latitude of pole to rotate to (degrees).
#' @param pole.lon longitude of pole to rotate to (degrees).
#' @return input field but with the rotated pole.
#' @seealso \code{\link{GSDF.ll.to.rg}} and \code{\link{GSDF.rg.to.ll}}.
GSDF.field.to.pole<-function(g,pole.lat,pole.lon) {
  if(is.null(g$meta)) g$meta<-list()
  if(is.null(g$meta$pole.lat)) g$meta$pole.lat<-90
  if(is.null(g$meta$pole.lon)) g$meta$pole.lon<-180
  if(g$meta$pole.lat==pole.lat &&
     g$meta$pole.lon==pole.lon) return(g)
  result<-g
  if(is.null(result$meta)) result$meta<-list()
  result$meta$pole.lat<-pole.lat
  result$meta$pole.lon<-pole.lon
  result<-GSDF.regrid.2d(g,result)
  return(result)
}

#' Grow field
#'
#' Given a spatially incomplete GSDF field, extrapolate the field into
#'  missing regions by adding one grid point round the boundary of all
#'  non-missing sections.
#'
#' Mostly useful for sea-ice - because rotating and regridding only interpolates,
#'  grid-boxes which are adjacent to missing data are removed by either process.
#' This is a hack - but it mostly repairs the damage.
#'
#' @export
#' @param field GSDF field
#' @return grown field.
GSDF.grow<-function(g) {
  g2<-as.vector(g$data)
  dims<-GSDF.get.extended.dimensions(g)
  if(length(dims)!=2) {
      stop('Must have exactly 2 extended dimensions')
  }

  gr<-g2
  d1<-length(g$dimensions[[dims[1]]]$values)
  d2<-length(g$dimensions[[dims[2]]]$values)
  s<-seq_along(g2)
  r<-as.integer((s-1)/d2)+1 # row index
  c<-s-(r-1)*d2             # Column index
  # Test each of 9 neighbours
  for(dr in c(-1,0,1)) {
    for(dc in c(-1,0,1) ) {        
        neighbour<-(r+dr-1)*d2+c+dc
        is.na(neighbour[c+dc< 1])<-T
        is.na(neighbour[c+dc>d2])<-T
        is.na(neighbour[r+dr< 1])<-T
        is.na(neighbour[r+dr>d1])<-T
        w<-which(is.na(gr) & !is.na(g2[neighbour]))
        gr[w]<-g2[neighbour][w]
      }
  }
  g$data<-array(data=gr,dim=dim(g$data))
  return(g)
}

#' Remove a dimension from a field
#'
#' Convert a n-dimensional field to an (n-1) dimensional field
#' by applying a function over the selected dimension.
#'
#' If you have a 3-d field (say) lat*lon*ensemble member, convert it
#'  to a two d (lat*lon) field with the ensemble mean by running this with
#'  function 'mean' and dimension 'ensemble'. But you can use any function
#'  (that has a vector input and scalar output) over any dimension.
#'
#' @export
#' @param d GSDF field
#' @param dimn name (e.g. 'ensemble') or number (3) of dimension to reduce
#' @param fn function to do the reduction (often mean or sd).
#' @param ... additional arguments to fn (e.g. na.rm=T)
#' @return reduced field.
GSDF.reduce.1d<-function(d,dimn,fn,...) {
  idx.d<-NULL
  if(is.numeric(dimn)) {
    idx.d<-dimn
  } else idx.d<-GSDF.find.dimension(d,dimn)
  if(is.null(idx.d)) stop(sprintf("Field has no dimension %s",dimn))
  result<-d
  old.d<-seq_along(dim(d$data))
  result$data<-apply(d$data,old.d[-idx.d],fn,...)
  if(length(old.d)>idx.d) {
     for(i in seq(idx.d,length(old.d)-1)) {
       result$dimensions[[i]]<-d$dimensions[[i+1]]
     }
  }
  result$dimensions[[length(old.d)]]<-NULL
  return(result)
}

# Expand a field in longitude - copying the first column to the end
#  and the last column to the beginning (or rows, if apropriate)
# Allows correct interpolation of points beyond the last row or before
#  the first row.
# Internal function, needed by interpolate.ll
# Field to be expanded must have only 2 extended dimensions.
# Assumes longitudes are in ascending order.
GSDF.pad.longitude<-function(g) {
  result<-g
  d<-GSDF.get.extended.dimensions(g)
  if(length(d)!=2) stop('Wrong dimensions in pad.longitude')
  a<-array(data<-as.vector(g$data),dim=c(length(g$dimensions[[d[1]]]$values),
                                         length(g$dimensions[[d[2]]]$values)))
  if(g$dimensions[[d[1]]]$type=='lon') {
    l<-length(g$dimensions[[d[1]]]$values)
    a<-rbind(a[l,],a,a[1,])
    nd<-dim(g$data)
    nd[d]<-nd[d]+2
    result$data<-array(data<-as.vector(a),dim=nd)
    result$dimensions[[d[1]]]$values<-c(g$dimensions[[d[1]]]$values[l]-360,
                                        g$dimensions[[d[1]]]$values,
                                        g$dimensions[[d[1]]]$values[1]+360)
    return(result)
  }
  if(g$dimensions[[d[2]]]$type=='lon') {
    l<-length(g$dimensions[[d[2]]]$values)
    a<-cbind(a[,l],a,a[,1])
    nd<-dim(g$data)
    nd[d]<-nd[d]+2
    result$data<-array(data<-as.vector(a),dim=nd)
    result$dimensions[[d[2]]]$values<-c(g$dimensions[[d[2]]]$values[l]-360,
                                        g$dimensions[[d[2]]]$values,
                                        g$dimensions[[d[2]]]$values[1]+360)
    return(result)
  }
  stop('Field has no longitudes to pad')
}

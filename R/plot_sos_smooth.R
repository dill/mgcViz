#' Plotting smooths on the sphere
#' 
#' @description XXX
#' @name plot.sos.smooth
#' @examples 
#' library(mgcViz)
#' set.seed(0)
#' n <- 400
#' 
#' f <- function(la,lo) { ## a test function...
#'   sin(lo)*cos(la-.3)
#' }
#' 
#' ## generate with uniform density on sphere...  
#' lo <- runif(n)*2*pi-pi ## longitude
#' la <- runif(3*n)*pi-pi/2
#' ind <- runif(3*n)<=cos(la)
#' la <- la[ind];
#' la <- la[1:n]
#' 
#' ff <- f(la,lo)
#' y <- ff + rnorm(n)*.2 ## test data
#' 
#' ## generate data for plotting truth...
#' lam <- seq(-pi/2,pi/2,length=30)
#' lom <- seq(-pi,pi,length=60)
#' gr <- expand.grid(la=lam,lo=lom)
#' fz <- f(gr$la,gr$lo)
#' zm <- matrix(fz,30,60)
#' 
#' require(mgcv)
#' dat <- data.frame(la = la *180/pi,lo = lo *180/pi,y=y)
#' 
#' ## fit spline on sphere model...
#' bp <- gam(y~s(la,lo,bs="sos",k=60),data=dat)
#' sm <- getViz(bp)(1)
#' plot(sm, scheme=0)
#' plot(sm, scheme=1)
#' plot(sm, scheme=2)
#' @rdname plot.sos.smooth
#' @export plot.sos.smooth
plot.sos.smooth <- function(o, residuals=FALSE, rug=TRUE, se=TRUE, n=40,
                            pers=FALSE, theta=30, phi=30, xlab=NULL, ylab=NULL, main=NULL, 
                            ylim=NULL, xlim=NULL, too.far=0.1, se.mult=1, shift=0, trans=I, seWithMean=FALSE, 
                            unconditional=FALSE, by.resids=FALSE, scheme=0, hcolors=viridis(50, begin=0.2),
                            contour.col=1, pFun=zto1(0.05, 3, 0.2), ...)
{
  if (length(scheme)>1){ 
    scheme <- scheme[1]
    warning( "scheme should be a single number" )
  }
  
  o$smooth <- o$gObj$smooth[[o$ism]]
  
  # This creates/modifies variables in the environment.
  # INPUTS: unconditional, o, residuals, se, resDen 
  # NEW/MODIFIED VARIABLES: o, w.resid, partial.resids, se2.mult, se1.mult, se, fv.terms, order 
  resDen <- "none"
  fv.terms <- o$store$termsFit[ , o$store$np + o$ism]
  init <- .initializeXXX(o, unconditional, residuals, resDen, se, fv.terms)
  # affect initialize output
  o <- init$o
  w.resid <- init$w.resid
  partial.resids <- init$partial.resids
  se2.mult <- init$se2.mult
  se1.mult <- init$se1.mult
  se <- init$se
  fv.terms <- init$fv.terms
  order <- init$order
  # Prepare for plotting
  tmp <- .createP(sm=o$smooth, x=o$gObj, partial.resids=partial.resids,
                  rug=rug, se=se, scale=FALSE, n=NULL, n2=n,
                  pers=pers, theta=theta, phi=phi, jit=NULL, xlab=xlab, ylab=ylab, main=main, label=term.lab,
                  ylim=ylim, xlim=xlim, too.far=too.far, shade=NULL, shade.col=NULL,
                  se1.mult=se.mult, se2.mult=se.mult, shift=shift, trans=trans,
                  by.resids=by.resids, scheme=scheme, seWithMean=seWithMean, fitSmooth=fv.terms,
                  w.resid=w.resid, resDen=resDen, ...)
  pd <- tmp[["P"]]
  attr(o$smooth, "coefficients") <- tmp[["coef"]]
  rm(tmp)
  
  
  # Plotting
  .ggobj <- .plot.sos.smooth(x=o$smooth, P=pd, partial.resids=partial.resids, rug=rug, se=se, scale=FALSE, n2=n,
                             pers=pers, theta=theta, phi=phi, jit=jit, main=main, too.far=too.far, 
                             shift=shift, trans=trans, by.resids=by.resids, scheme=scheme, hcolors=hcolors,
                             contour.col=contour.col, pFun=pFun, ...)
  
  .ggobj <- .ggobj
  
  attr(.ggobj, "rawData") <- pd
  .ggobj
}

# Internal function
.plot.sos.smooth <- function(x, P=NULL, partial.resids=FALSE, rug=TRUE, se=TRUE, scale=FALSE, n2=40,
                             pers=FALSE, theta=30, phi=30, jit=FALSE, main=NULL, too.far=0.1,
                             shift=0, trans=I, by.resids=FALSE, scheme=0, hcolors=viridis(50, begin=0.2),
                             contour.col=1, pFun = zto1(0.05, 3, 0.2), 
                             # Useless arguments
                             data=NA, label=NA, se.mult=NA, xlab=NA, ylab=NA, n=NA,
                             shade=NA, shade.col=NA, xlim=NA, ylim=NA,
                             #
                             ...)
{
  if (scheme>1){ return( .plot.mgcv.smooth.2D(x=x, P=P, partial.resids=partial.resids, rug=rug, se=se, scale=scale, n2=n,
                                              pers=pers, theta=theta, phi=phi, jit=jit, main=main, too.far=too.far, 
                                              shift=shift, trans=trans, by.resids=by.resids, scheme=scheme, hcolors=hcolors,
                                              contour.col=contour.col, pFun=pFun, ...) ) }
  m <- length(P$xm); 
  zz <- lo <- la <- rep(NA,m*m)
  
  zz[P$ind] <- trans(P$fit+shift)
  lo[P$ind] <- P$lo
  la[P$ind] <- P$la
  
  .dat <- data.frame("x"=rep(P$xm, m), "y"=rep(P$ym, each=m), "z"=zz, "lo"=lo, "la=la")
  
  .pl <- ggplot(data=.dat, aes(x=x, y=y, z=z)) + labs(title = P$main, x = P$xlab, y = P$ylab) 
  
  if( scheme==0 ){ .pl <- .pl + geom_raster(aes(fill = z)) + scale_fill_gradientn(colours = hcolors, na.value="white") }
  
  .pl <- .pl + geom_contour(aes(x=x, y=y, z=z), colour = contour.col, na.rm=T) + 
               geom_contour(aes(x=x, y=y, z=lo), colour= contour.col, linetype=2, na.rm=T, breaks=c(-8:9*20)) + 
               geom_contour(aes(x=x, y=y, z=la), colour= contour.col, linetype=2, na.rm=T, breaks=c(-8:8*10))
  
  # Add residuals
  if (rug) { 
    .tmpF <- function(..., shape = '.', col = "black") # Alter default shape and col
    {
      geom_point(data=data.frame("resx"=P$raw$x, "resy"=P$raw$y), aes(x = resx, y = resy), 
                 inherit.aes = FALSE, shape = shape, col = col, ...)
    } 
    .pl <- .pl + .tmpF(...)
  }
  
  # Plot circle around the sphere
  if(scheme == 1){
    ncir <- 200
    theta <- seq(-pi/2,pi/2,length=ncir)
    x <- sin(theta); y <- cos(theta)
    .pl <- .pl + geom_path(aes(x=x, y=y), data = data.frame("x"=c(x, x[ncir:1]), "y" = c(y,-y[ncir:1])), 
                           inherit.aes = FALSE, colour = contour.col)
  }
  
  .pl <- .pl + coord_cartesian(expand=F) + theme(axis.line=element_blank(), axis.text.x=element_blank(),
                                                 axis.text.y=element_blank(), axis.ticks=element_blank(),
                                                 panel.grid.major = element_blank(),
                                                 panel.grid.minor = element_blank(),
                                                 panel.border = element_blank(),
                                                 panel.background = element_blank()) 
  
  return( .pl )
  
}
#' Plotting one dimensional smooth effects
#' 
#' @description XXX
#' @name plot.mgcv.smooth.1D
#' @examples 
#' library(mgcViz)
#' @rdname plot.mgcv.smooth.1D
#' @export plot.mgcv.smooth.1D
plot.mgcv.smooth.1D <- function(o, residuals=FALSE,rug=TRUE,se=TRUE,n=100,
                                jit=FALSE,xlab=NULL,ylab=NULL,main=NULL,
                                ylim=NULL,xlim=NULL,shade=FALSE,shade.col=I("gray80"),
                                shift=0,trans=I,seWithMean=FALSE,unconditional=FALSE,by.resids=FALSE,
                                scheme=0, ...)
{
  if (length(scheme)>1){ 
    scheme <- scheme[1]
    warning( "scheme should be a single number" )
  }
  
  o$smooth <- o$gObj$smooth[[o$ism]]
  
  # This creates/modifies variables in the environment.
  # INPUTS: unconditional, o, residuals, se
  # NEW/MODIFIED VARIABLES: o, w.resid, partial.resids, se2.mult, se1.mult, se, fv.terms, order  
  fv.terms <- o$store$termsFit[ , o$store$np + o$ism]
  eval( .initializeXXX )
  
  # Prepare for plotting
  tmp <- .createP(sm=o$smooth, x=o$gObj, partial.resids=partial.resids,
                  rug=rug, se=se, scale=FALSE, n=n, n2=NULL,
                  pers=NULL, theta=NULL, phi=NULL, jit=jit, xlab=xlab, ylab=ylab, main=main, label=term.lab,
                  ylim=ylim, xlim=xlim, too.far=NULL, shade=shade, shade.col=shade.col,
                  se1.mult=se1.mult, se2.mult=se2.mult, shift=shift, trans=trans,
                  by.resids=by.resids, scheme=scheme, seWithMean=seWithMean, fitSmooth=fv.terms,
                  w.resid=w.resid, ...)
  pd <- tmp[["P"]]
  attr(o$smooth, "coefficients") <- tmp[["coef"]]
  rm(tmp)
  
  # Plotting
  .ggobj <- .plot.mgcv.smooth.1D(x=o$smooth, P=pd, partial.resids=partial.resids, rug=rug, se=se, scale=FALSE, n=n,
                                 jit=jit, shade=shade||(scheme==1), shade.col=shade.col, ylim = ylim,
                                 shift=shift, trans=trans, by.resids=by.resids, ...)
  
  .ggobj <- .ggobj+theme_bw()

  attr(.ggobj, "rawData") <- pd
  .ggobj
}


# Internal function for plotting one dimensional smooths
.plot.mgcv.smooth.1D <- function(x, P, partial.resids=FALSE, rug=TRUE, se=TRUE, scale=TRUE, n=100,
                           jit=FALSE, shade=FALSE, shade.col=I("gray80"), ylim = NULL,
                           shift=0, trans=I, by.resids=FALSE, scheme=0, ...)
{
  if (scheme == 1){ shade <- TRUE }
  
  ul <- P$fit + P$se ## upper CL
  ll <- P$fit - P$se ## lower CL  
  
  if (scale==FALSE && is.null(ylim)) { # Calculate ylim of plot
    ylimit <- range(c(if(partial.resids){ P$p.resid } else { P$fit }, if(se){ c(ul, ll) } else { c() }), na.rm = TRUE) 
  }
  
  ylimit <- if (is.null(ylim)){ ylimit <- ylimit + shift } else { ylim }
  
  .pl <- ggplot(data=data.frame(x=P$x, y=trans(P$fit+shift), uci=trans(ul+shift), lci=trans(ll-shift)), aes(x=x, y=y)) + 
    xlim(P$xlim[1], P$xlim[2]) + ylim(trans(ylimit[1]), trans(ylimit[2])) + labs(title = P$main, x = P$xlab, y = P$ylab)
  
  # Add shade or lines for confidence bands
  if(se){
    if( shade ){ 
      .pl <- .pl + geom_polygon(data = data.frame("x"= c(P$x,P$x[n:1],P$x[1]), "y" = trans(c(ul,ll[n:1],ul[1])+shift)), 
                                aes(x = x, y = y, fill = shade.col), inherit.aes = F)
    } else {
      .tmpF <- function(pl, ..., linetype="dashed") # Alter default "linetype"
      {
        pl <- pl + geom_line(aes(x, uci), linetype=linetype, ...) + geom_line(aes(x, lci), linetype=linetype, ...)
      }
      .pl <- .tmpF(.pl, ...)
    }
  }
  
  # Add partial residuals
  if (partial.resids&&(by.resids||x$by=="NA")) { 
    if (length(P$raw)==length(P$p.resid)) {
      .tmpF <- function(..., shape = '.', col = "black") # Alter default shape and col
      {
        geom_point(data = data.frame(resx = P$raw, resy = trans(P$p.resid+shift)), aes(x = resx, y = resy),
                   shape = shape, col = col, ...)
      }
      .pl <- .pl + .tmpF(...)
    } else {
      warning("Partial residuals do not have a natural x-axis location for linear functional terms")
    }
  }
  
  # Add rug
  if (rug) { 
    .df <- data.frame(x = if(jit){ jitter(as.numeric(P$raw)) } else { as.numeric(P$raw) } )
    .tmpF <- function(pl, ..., size = 0.2) # Alter default "size"
    {
      geom_rug(data = .df, aes(x = x), inherit.aes = F, size = size, ...)
    }
    .pl <- .pl + .tmpF(.pl, ...)
  } 
  
  .pl <- .pl + geom_line(...)
  
  return( .pl )
} 
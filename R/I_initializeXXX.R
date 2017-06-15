
.initializeXXX <- expression({
  
  if (unconditional){ # Use Bayesian cov matrix including smoothing parameter uncertainty?
    if (is.null(x$Vc)){ 
      warning("Smoothness uncertainty corrected covariance not available") 
    } else { 
        x$Vp <- x$Vc 
        } 
  }
  
  w.resid <- NULL
  if ( length(residuals)>1 ){ # residuals supplied 
    if (length(residuals)==length(x$residuals)){ 
      w.resid <- residuals } else { warning("residuals argument to plot.gam is wrong length: ignored") }
    partial.resids <- TRUE
  } else { partial.resids <- residuals } # use working residuals or none
  
  if (partial.resids) { # Getting information needed for partial residuals
    if (is.null(w.resid)) { # produce working residuals if info available
      if (is.null(x$residuals)||is.null(x$weights)){ partial.resids <- FALSE } else {
        wr <- sqrt(x$weights)
        w.resid <- x$residuals*wr/mean(wr) # weighted working residuals
      }
    }
    if (partial.resids){ # get individual smooth effects
      if(is.null(fv.terms)) { fv.terms <- predict(x,type="terms") }
      }
  }
  
  if (se) { # Sort out CI widths for 1D and 2D smooths
    if (is.numeric(se)) { se2.mult <- se1.mult <- se } else { se1.mult <- 2; se2.mult <- 1} 
    if (se1.mult<0) { se1.mult<-0 }
    if (se2.mult < 0) { se2.mult <- 0 }
  } else { se1.mult <- se2.mult <-1 }
  
  if (se && x$Vp[1,1] < 0){  # Check that variances are actually available
    se <- FALSE
    warning("No variance estimates available")
  }
  
  ## Array giving the order of each parametric term
  order <- if (is.list(x$pterms)){ unlist(lapply(x$pterms,attr,"order")) } else { attr(x$pterms,"order") }
  
})

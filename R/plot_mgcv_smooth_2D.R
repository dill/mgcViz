#' Plotting two dimensional smooth effects
#' 
#' @description XXX
#' @name plot.mgcv.smooth.2D
#' @examples 
#' library(mgcv)
#' library(mgcViz)
#' library(viridis)
#' set.seed(2) ## simulate some data...
#' dat <- gamSim(1, n = 1000, dist = "normal", scale = 2)
#' b <- gam(y ~ s(x0) + s(x1, x2) + s(x3), data = dat, method = "REML")
#' mgcv::plot.gam(b, scheme = 0, select = 2, se = FALSE)
#' mgcv::plot.gam(b, scheme = 0, select = 2, se = TRUE)
#' mgcv::plot.gam(b, scheme = 1, select = 2)
#' mgcv::plot.gam(b, scheme = 2, select = 2)
#' mgcv::plot.gam(b, scheme = 3, select = 2, se = TRUE)
#' mgcv::plot.gam(b, scheme = 3, select = 2, se = FALSE)
#' plot(b, scheme = 4, select = 2)
#' sm <- getViz(b)(2)
#' plot(sm, rug = TRUE, se = FALSE, residuals = TRUE, scheme = 0)
#' plot(sm, rug = TRUE, se = TRUE, residuals = TRUE, scheme = 0)
#' plot(sm, rug = TRUE, se = TRUE, residuals = TRUE, scheme = 1)
#' plot(sm, rug = TRUE, residuals = TRUE, scheme = 2)
#' plot(sm, rug = TRUE, residuals = TRUE, scheme = 3)
#' @rdname plot.mgcv.smooth.2D
#' @export plot.mgcv.smooth.2D

# 
# ll <- list(o = sm, residuals = FALSE, rug = TRUE, se = TRUE, n = 40,
#            pers = FALSE, theta = 30, phi = 30, xlab = NULL, ylab = NULL, main=NULL,
#            ylim = NULL, xlim = NULL, too.far = 0.1, se.mult = 1, shift = 0, trans = I, seWithMean = FALSE,
#            unconditional = FALSE, by.resids = FALSE, scheme = 0, hcolors = viridis(50, begin=0.2),
#            contour.col = 1, pFun = zto1(0.05, 3, 0.2))
# list2env(ll, .GlobalEnv)
# .createP <- mgcViz:::.createP
# .initializeXXX <- mgcViz:::.initializeXXX
# .plot.mgcv.smooth.2D <- mgcViz:::.plot.mgcv.smooth.2D
# .spContour <- mgcViz:::.spContour

plot.mgcv.smooth.2D <- function(o, residuals = FALSE, rug = TRUE, se = TRUE, n = 40,
                                pers = FALSE, theta = 30, phi = 30, xlab = NULL, ylab = NULL,
                                main = NULL, ylim = NULL, xlim = NULL, too.far = 0.1, se.mult = 1,
                                shift = 0, trans = I, seWithMean = FALSE, 
                                unconditional = FALSE, by.resids = FALSE,
                                scheme = 0, hcolors = viridis(50, begin = 0.2),
                                contour.col = 1, pFun = zto1(0.05, 3, 0.2), ...) {
  if (length(scheme) > 1){ 
    scheme <- scheme[1]
    warning("'scheme' should be a single number")
  }
  if (!(scheme %in% 0:4)){
    stop("'scheme' must be in 0:4")
  }
  o$smooth <- o$gObj$smooth[[o$ism]]
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
  tmp <- .createP(sm = o$smooth, x = o$gObj, partial.resids = partial.resids,
                  rug = rug, se = se, scale = FALSE, n = NULL, n2 = n,
                  pers = pers, theta = theta, phi = phi, jit = NULL,
                  xlab = xlab, ylab = ylab, main = main, label = term.lab,
                  ylim = ylim, xlim = xlim, too.far = too.far, shade = NULL, shade.col = NULL,
                  se1.mult = se.mult, se2.mult = se.mult, shift = shift, trans = trans,
                  by.resids = by.resids, scheme = scheme, seWithMean = seWithMean, fitSmooth = fv.terms,
                  w.resid = w.resid, resDen = resDen)#, ...)
  pd <- tmp[["P"]]
  attr(o$smooth, "coefficients") <- tmp[["coef"]]
  rm(tmp)
  # Plotting
  .ggobj <- .plot.mgcv.smooth.2D(x = o$smooth, P = pd, partial.resids = partial.resids,
                                 rug = rug, se = se, scale = FALSE, n2 = n,
                                 pers = pers, theta = theta, phi = phi, jit = NULL,
                                 main = main, too.far = too.far, 
                                 shift = shift, trans = trans, by.resids = by.resids,
                                 scheme = scheme, hcolors = hcolors,
                                 contour.col = contour.col, pFun = pFun, ...)#, ...)
  if (inherits(.ggobj, "ggplot")) {
    .ggobj <- .ggobj + theme_bw()
    attr(.ggobj, "rawData") <- pd
    return(.ggobj)
  } else {
    return(invisible(.ggobj))
  }
  
}

# ll2 <- list(x = o$smooth, P = pd, partial.resids = partial.resids,
#             rug = rug, se = se, scale = FALSE, n2 = n,
#             pers = pers, theta = theta, phi = phi, jit = NULL,
#             main = main, too.far = too.far, 
#             shift = shift, trans = trans, by.resids = by.resids,
#             scheme = scheme, hcolors = hcolors,
#             contour.col = contour.col, pFun = pFun)
# list2env(ll2, .GlobalEnv)

# Internal function
.plot.mgcv.smooth.2D <- function(x, P = NULL, partial.resids = FALSE, rug = TRUE, se = TRUE,
                                 scale = FALSE, n2 = 40,
                                 pers = FALSE, theta = 30, phi = 30, jit = FALSE,
                                 main = NULL, too.far = 0.1,
                                 shift = 0, trans = I, by.resids = FALSE, scheme = 0,
                                 hcolors = viridis(50, begin = 0.2),
                                 contour.col = 1, pFun = zto1(0.05, 3, 0.2), 
                                 # Useless arguments
                                 data = NA, label = NA, se.mult = NA, xlab = NA, ylab = NA, n = NA,
                                 shade = NA, shade.col = NA, xlim = NA, ylim = NA,
                                 #
                                 ...) {
  # # scheme = 0
  # if (scheme == 0) {
  #   
  # }
  # # scheme = 1
  # if (scheme == 1) {
  #   persp(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), xlab = P$xlab, ylab = P$ylab,
  #         zlab = P$main, ylim = P$ylim, xlim = P$xlim, theta = theta, phi = phi, ...)
  #   persp(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), xlab = P$xlab, ylab = P$ylab,
  #         zlab = P$main, theta = theta, phi = phi, xlim = P$xlim, ylim = P$ylim, ...)
  # }
  # # scheme = 2
  # 
  # # scheme = 3
  force(P)
  if (se) {
    P$fit[P$exclude] <- NA
    if (pers) {
      scheme <- 1
    }
    if (scheme == 1) { ## perspective plot 
      persp(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), xlab = P$xlab, ylab = P$ylab,
            zlab = P$main, ylim = P$ylim, xlim = P$xlim, theta = theta, phi = phi, ...)
    } else if (scheme == 2 || scheme == 3) { ## ggplot image like
      if (scheme == 3) {
        hcolors <- grey(0:50 / 50)
      }
      .pl <- 
        ggplot(data = data.frame("z" = P$fit, "x" = rep(P$x, length(P$fit) / length(P$x)), 
                                 "y" = rep(P$y, each = length(P$fit) / length(P$x)),
                                 p = pFun(1 - pnorm(abs(P$fit) / P$se))), 
               aes(x = x, y = y, z = z)) +
        geom_raster(aes(fill = z, alpha = p)) + 
        geom_contour(color = contour.col, na.rm = TRUE) + 
        scale_fill_gradientn(colours = hcolors, na.value = "grey") +
        scale_alpha_identity() +
        coord_cartesian(xlim = P$xlim, ylim = P$ylim, expand = FALSE) +
        labs(title = P$main, x = P$xlab, y = P$ylab) 
      # Add partial residuals
      if (rug) { 
        .tmpF <- function(..., shape = '.', col = "black") # Alter default shape and col
        {
          geom_point(data = data.frame("resx" = P$raw$x, "resy" = P$raw$y),
                     aes(x = resx, y = resy), 
                     inherit.aes = FALSE, shape = shape, col = col, ...)
        } 
        .pl <- .pl + .tmpF(...)
      }
      
    } else { ## contour plot with error contours
      .spContour(P$x, P$y, matrix(P$fit, n2, n2), matrix(P$se, n2, n2),
                 xlab = P$xlab, ylab = P$ylab, zlab = P$main, titleOnly =! is.null(main),
                 se.mult = 1, trans = trans, shift = shift, ...)
      if (rug) { 
        if (is.null(list(...)[["pch"]])) {
          points(P$raw$x, P$raw$y, pch = ".", ...) 
        } else {
          points(P$raw$x, P$raw$y,...) 
        }
      }
    } ## counter plot done 
  } else {
    P$fit[P$exclude] <- NA
    if (!is.null(main)) {
      P$title <- main
    }
    if (pers) {
      scheme <- 1
    }
    if (scheme == 1) { 
      persp(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), xlab = P$xlab, ylab = P$ylab,
            zlab = P$main, theta = theta, phi = phi, xlim = P$xlim, ylim = P$ylim, ...)
    } else if (scheme == 2 || scheme == 3) {
      if (scheme == 3) {
        hcolors <- grey(0:50 / 50)
      }
      image(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), xlab = P$xlab, ylab = P$ylab,
            main = P$main, xlim = P$xlim, ylim = P$ylim, col = hcolors, ...)
      contour(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), add = TRUE, col = contour.col, ...)
      if (rug) {  
        if (is.null(list(...)[["pch"]])) {
          points(P$raw$x, P$raw$y, pch = ".", ...)
        } else {
          points(P$raw$x, P$raw$y, ...)
        }
      }
    } else { 
      contour(P$x, P$y, matrix(trans(P$fit + shift), n2, n2), xlab = P$xlab, ylab = P$ylab,
              main = P$main, xlim = P$xlim, ylim = P$ylim, ...)
      if (rug) {  
        if (is.null(list(...)[["pch"]])) {
          points(P$raw$x, P$raw$y, pch = ".", ...)
        } else {
          points(P$raw$x, P$raw$y, ...)
        }
      }
    }
  }
  if (scheme > 1) {
    return(.pl)
  } else {
    return(invisible(P))
  }
}
#' Trasparency level as function of p value
#' 
#' @description XXX
#' @name zto1
#' @examples 
#' library(mgcViz)
#' x <- seq(0, 1, by = 0.01)
#' plot(x, zto1(0.05, 2)(x))
#' lines(x, zto1(0.05, 1)(x), col = 2)
#' lines(x, zto1(0.1, 3)(x), col = 3)
#' @rdname zto1
#' @export zto1
zto1 <- function(o, a, m){
  .f <- function(.p){ 
    .p <- pmax(0, .p - o) 
    return(pmax((1 - .p)^a, m)) 
  }
  return(.f)
}




## Local function for producing labels
.subEDF <- function(lab,edf) {
  ## local function to substitute edf into brackets of label
  ## labels are e.g. smooth[[1]]$label
  pos <- regexpr(":", lab)[1]
  if (pos<0) { ## there is no by variable stuff
    pos <- nchar(lab) - 1
    lab <- paste(substr(lab, start=1, stop=pos),", ", round(edf, digits=2),")",sep="")
  } else {
    lab1 <- substr(lab, start=1, stop=pos-2)
    lab2 <- substr(lab, start=pos-1, stop=nchar(lab))
    lab <- paste(lab1, ",", round(edf,digits=2), lab2, sep="")
  }
  lab
} ## end of sub.edf


# Function that calculates empirical quantiles by sorting 
.quBySort <- function(x, p, sortFun){
  x <- sortFun(x)
  n <- length(x)
  np <- n*p
  q <- ( x[floor(np+1)] + x[ceiling(np)] )/2
  q
}

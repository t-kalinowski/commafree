

#' Call a function
#'
#' This allows you to call a function with expressions for arguments. It is
#' especially useful for long, multi-line function calls with many arguments
#' (e.g., a shiny UI definition, an R6 class definition, ...)
#'
#' This (`%(%`) merely performs a syntax transformation, so all the same
#' semantics with regards to lazy argument evaluation apply. For any
#' function call, replace `(` with `%(%` and be free of the need for
#' commas between arguments in that call.
#'
#' ```r
#' fn %(% {
#'   a
#'   b
#'   c
#' }
#' ```
#' Is syntactically equivalent to writing:
#' ```r
#' func(
#'   a,
#'   b,
#'   c
#' )
#' ```
#'
#'
#' @param fn A function
#' @param args A set of expressions grouped by `{ }`
#'
#' @note You can produce a missing argument with the special token `,,`, or
#'   `` foo = `,` `` for a named missing arguments (see examples).
#'
#' @return Whatever `fn()` called with `args` returns.
#'
#' @export
#'
#' @examples
#' mean %(% {
#'   1:3
#'   na.rm = TRUE
#' }
#'
#' writeLines(c %(% {
#'   "Hello"
#'   "Goodbye"
#' })
#'
#' # setup helper demonstrating missing arguments
#' fn <- function(x, y) {
#'   if(missing(y))
#'     print("y was missing")
#'   else
#'     print(y)
#' }
#'
#' # How to add a named missing argument
#' fn %(% {
#'   y = `,`
#' }
#'
#' # How to add a positional missing argument
#' fn %(% {
#'   1
#'   `,,`
#' }
#'
#' fn %(% { 1; `,,` }
#'
#' rm(fn) # cleanup
`%(%` <- function(fn, args) {
  fn <- substitute(fn)
  args <- as.list(substitute(args))
  if(!identical(args[[1]], quote(`{`)))
    stop("right hand side must be an expressionlist starting with a `{`")

  args[[1L]] <- NULL
  nms <- names2(args)
  for(i in seq_along(args)) {
    ar <- args[[i]]
    if(is.call(ar) && identical(ar[[1L]], quote(`=`))) {
      if(!is.symbol(nm <- ar[[2L]])) stop("Left hand side of `=` must be named")
      nms[i] <- as.character(nm)
      args[i] <- ar[3L]
    }

    if((nzchar(nms[i]) && identical(args[[i]], quote(`,`))) ||
       identical(args[[i]], quote(`,,`)))
      args[[i]] <- quote(expr = )
  }
  names(args) <- nms

  if (is.call(fn) && is.symbol(fn[[1L]]) &&
      grepl("^%.+%$", as.character(fn[[1L]]))) {
    # is %>% %<>% or some other special
    fn[[3L]] <- as.call(c(fn[[3L]], args))
    return(eval.parent(fn))
  }

  # else fn is a symbol or a regular thing meant to be called
  eval.parent(as.call(c(fn, args)))
}



names2 <- function(x) {
  nms <- names(x)
  if (is.null(nms))
    return(character(length(x)))

  nms[is.na(nms)] <- ""
  nms
}


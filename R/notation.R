#' Switch notation 
#' 
#' Convert from one notation to another for an isotope data object.
#' 
#' Valid notations depend on the data type: 
#' \itemize{
#'  \item{\code{\link{abundance}}: }{'raw', 'percent'}
#'  \item{\code{\link{delta}}: }{'raw', 'permil', 'ppm'}
#'  \item{\code{\link{fractionation_factor}}: }{'alpha', 'eps', 'permil', 'ppm'}
#' }
#' 
#' @usage switch_notation(iso, to)
#' @param iso isotopic data object (\code{\link{ff}}, \code{\link{abundance}}, \code{\link{delta}})
#' @param to which notation to convert to
#' @return isotope object with converted notation, an error if it is not a valid conversion
#' @family data type attributes
#' @name switch_notation
#' @rdname switch_notation
#' @exportMethod switch_notation
setGeneric("switch_notation", function(iso, to = NULL, from = NULL) standardGeneric("switch_notation"))

#' @rdname switch_notation
#' @aliases ANY-method
setMethod("switch_notation", "ANY", function(iso, to = NULL, from = NULL) stop(sprintf("don't know how to convert notation '%s' to notation '%s'", class(from), class(to)), call. = FALSE))

# what happens mathematically in the conversions
#' @rdname switch_notation
#' @aliases numeric,Notation_raw,Notation_raw-method
setMethod("switch_notation", signature("numeric", to = "Notation_raw", from = "Notation_raw"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_percent,Notation_percent-method
setMethod("switch_notation", signature("numeric", to = "Notation_percent", from = "Notation_percent"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_alpha,Notation_alpha-method
setMethod("switch_notation", signature("numeric", to = "Notation_alpha", from = "Notation_alpha"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_eps,Notation_eps-method
setMethod("switch_notation", signature("numeric", to = "Notation_eps", from = "Notation_eps"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_permil,Notation_permil-method
setMethod("switch_notation", signature("numeric", to = "Notation_permil", from = "Notation_permil"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_ppm,Notation_ppm-method
setMethod("switch_notation", signature("numeric", to = "Notation_ppm", from = "Notation_ppm"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_percent,Notation_raw-method
setMethod("switch_notation", signature("numeric", to = "Notation_percent", from = "Notation_raw"), function(iso, to, from) 100*iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_raw,Notation_percent-method
setMethod("switch_notation", signature("numeric", to = "Notation_raw", from = "Notation_percent"), function(iso, to, from) iso/100)
#' @rdname switch_notation
#' @aliases numeric,Notation_eps,Notation_raw-method
setMethod("switch_notation", signature("numeric", to = "Notation_eps", from = "Notation_raw"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_raw,Notation_eps-method
setMethod("switch_notation", signature("numeric", to = "Notation_raw", from = "Notation_eps"), function(iso, to, from) iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_eps,Notation_alpha-method
setMethod("switch_notation", signature("numeric", to = "Notation_eps", from = "Notation_alpha"), function(iso, to, from) iso - 1)
#' @rdname switch_notation
#' @aliases numeric,Notation_alpha,Notation_eps-method
setMethod("switch_notation", signature("numeric", to = "Notation_alpha", from = "Notation_eps"), function(iso, to, from) iso + 1)
#' @rdname switch_notation
#' @aliases numeric,Notation_alpha,Notation_raw-method
setMethod("switch_notation", signature("numeric", to = "Notation_alpha", from = "Notation_raw"), function(iso, to, from) iso + 1) # maybe clean up some redundancy here? but much faster this way
#' @rdname switch_notation
#' @aliases numeric,Notation_permil,Notation_raw-method
setMethod("switch_notation", signature("numeric", to = "Notation_permil", from = "Notation_raw"), function(iso, to, from) 1000*iso)
#' @rdname switch_notation
#' @aliases numeric,Notation_raw,Notation_permil-method
setMethod("switch_notation", signature("numeric", to = "Notation_raw", from = "Notation_permil"), function(iso, to, from) iso/1000)
#' @rdname switch_notation
#' @aliases numeric,Notation_permil,Notation_eps-method
setMethod("switch_notation", signature("numeric", to = "Notation_permil", from = "Notation_eps"), function(iso, to, from) 1000*iso) # FIXME: too much redundancy!
#' @rdname switch_notation
#' @aliases numeric,Notation_eps,Notation_permil-method
setMethod("switch_notation", signature("numeric", to = "Notation_eps", from = "Notation_permil"), function(iso, to, from) iso/1000)
#' @rdname switch_notation
#' @aliases numeric,Notation_permil,Notation_alpha-method
setMethod("switch_notation", signature("numeric", to = "Notation_permil", from = "Notation_alpha"), function(iso, to, from) 1000*(iso - 1))
#' @rdname switch_notation
#' @aliases numeric,Notation_alpha,Notation_permil-method
setMethod("switch_notation", signature("numeric", to = "Notation_alpha", from = "Notation_permil"), function(iso, to, from) iso/1000 + 1)
#' @rdname switch_notation
#' @aliases numeric,Notation_ppm,ANY-method
setMethod("switch_notation", signature("numeric", to = "Notation_ppm", from = "ANY"), function(iso, to, from) 1000*switch_notation(iso, to = new("Notation_permil"), from))
#' @rdname switch_notation
#' @aliases numeric,Notation_ANY,Notation_ppm-method
setMethod("switch_notation", signature("numeric", to = "ANY", from = "Notation_ppm"), function(iso, to, from) switch_notation(iso/1000, to, from = new("Notation_permil")))

# implement conversion of isovals and what's permitted on the level of the Isoval objects
isoval_switch_notation <- function(iso, to) {
    iso@.Data <- switch_notation(iso@.Data, to = to, from = iso@notation)
    iso@notation <- to 
    iso
}
#' @rdname switch_notation
#' @aliases Isoval,ANY,missing-method
setMethod("switch_notation", signature("Isoval", "ANY", "missing"), function(iso, to, from) {
    if (!is(to, "Notation"))
        stop("not a recognized notation for isotope value objects: ", class(to),
             call. = FALSE)
    stop(sprintf("not permitted to convert an isotope value of type '%s' to unit '%s'", class(iso), sub("Notation_", "", class(to))))
})
#' @rdname switch_notation
#' @aliases Isoval,Notation_raw,missing-method
setMethod("switch_notation", signature("Isoval", to = "Notation_raw", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases Abundance,Notation_percent,missing-method
setMethod("switch_notation", signature("Abundance", to = "Notation_percent", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases Delta,Notation_permil,missing-method
setMethod("switch_notation", signature("Delta", to = "Notation_permil", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases Delta,Notatation_ppm,missing-method
setMethod("switch_notation", signature("Delta", to = "Notation_ppm", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases FractionationFactor,Notation_alpha,missing-method
setMethod("switch_notation", signature("FractionationFactor", to = "Notation_alpha", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases FractionationFactor,Notation_eps,missing-method
setMethod("switch_notation", signature("FractionationFactor", to = "Notation_eps", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases FractionationFactor,Notation_raw,missing-method
setMethod("switch_notation", signature("FractionationFactor", to = "Notation_raw", from = "missing"), function(iso, to = NULL, from = NULL) switch_notation(iso, "eps")) # raw and eps is the same
#' @rdname switch_notation
#' @aliases FractionationFactor,Notation_permil,missing-method
setMethod("switch_notation", signature("FractionationFactor", to = "Notation_permil", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))
#' @rdname switch_notation
#' @aliases FractionationFactor,Notation_ppm,missing-method
setMethod("switch_notation", signature("FractionationFactor", to = "Notation_ppm", from = "missing"), function(iso, to = NULL, from = NULL) isoval_switch_notation(iso, to))

# FIXME isosys cucrrently not supported
# setMethod("switch_notation", signature("Isosys", to = "Notation", from = "missing"), function(iso, to = NULL, from = NULL){
#     for (col in names(iso)[sapply(iso, is.isoval)])
#         iso[[col]] <- switch_notation(iso[[col]], to)
# })

# this is the one the user actually calls
#' @rdname switch_notation
#' @aliases Isoval,character,missing-method
setMethod("switch_notation", signature("Isoval", to = "character", from = "missing"), function(iso, to = NULL, from = NULL) {
    to_class <- paste0("Notation_", to)
    if (!extends(to_class, "Notation"))
        stop("not a recognized notation for isotope value objects: ", to,
             call. = FALSE)
    switch_notation(iso, to = new(to_class))
})

#' @rdname switch_notation
#' @aliases Isosys,character,missing-method
setMethod("switch_notation", signature("Isosys", to = "character", from = "missing"), function(iso, to = NULL, from = NULL) {
    to_class <- paste0("Notation_", to)
    if (!extends(to_class, "Notation"))
        stop("not a recognized notation for isotope value objects: ", to,
             call. = FALSE)
    switch_notation(iso, to = new(to_class))
})    
 
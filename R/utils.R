# Null default
# Analog of || from ruby
#
# @keyword internal
# @name nulldefault-infix
# @author Hadley Wickham
"%||%" <- function(a, b) {
    if (!is.null(a)) a else b
}

# convenience function for dropping a list
# down one dimension if it's only length 1
# (loosing the naming in the process!)
drop_list <- function(l) {
    if (length(l) == 1L) l[[1]]
    else l
}

#' Run a calculation quietly.
#' 
#' This small utility function is just a convenient wrapper for running
#' isotope calculations silently without outputting any of the warnings or
#' messages (it uses \link[base]{suppressMessages} and \link[base]{suppressWarnings}
#' internally) that might occur. Use with care to suppress warnings, you
#' might end up hiding important information.
#' @export
quietly <- function(expr) {
    suppressMessages(suppressWarnings(expr))
}


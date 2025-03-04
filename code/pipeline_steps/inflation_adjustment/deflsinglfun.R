#' Inflation adjustment function
#'
#' Inflation adjustment for just one value
#'
#' @param val value to be converted
#' @param from.year the year that the values should be converted from
#' @param to.year the year that the values should be converted to
#'
#' @return inflation adjusted value
#' @export
#' @importFrom tidyr pivot_longer
#' @importFrom utils data
#' @importFrom dplyr mutate select
#' @importFrom tidyr pivot_wider
#' @importFrom reshape2 melt
#' @examples
#' data(gdp_defl)
#' deflsinglfun(935, 2016, 2017)
#'

# putting these here to keep R CMD check from yelling at me
globalVariables(c('YEAR', 'toyear'))

deflsinglfun <- function(val, from.year, to.year) {

  data(gdp_defl, envir = environment())

  gdpdefllong <- melt(gdp_defl, 'YEAR') %>%
    mutate(toyear = as.numeric(gsub('DEFL', '', variable))) %>%
    select(-variable)

defl <- subset(gdpdefllong, YEAR == from.year & toyear == to.year)$value

finalval <- val/defl*100

return(finalval)

}

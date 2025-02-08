#' Inflation Adjuster function
#'
#' If the required years are not available, follow directions in data(gdp_defl)
#' documentation to update gdp_defl.rda data
#'
#' @param .data Data frame that holds both the column to be adjusted and a year column
#' @param val.col Character string name of the value column
#' @param year.col Character string name of the year column (you do not need to specify if
#'   the column is named 'YEAR'
#' @param to.year Year that the values should be converted to. Defaults to the highest year in the data set.
#'
#' @return Vector of inflation adjusted values
#' @details You have to provide the data.frame name in the function call (doesn't work like a normal %>% function), see example
#' @importFrom dplyr select
#' @export
#' @examples
#'
#' data(dummyEDCdata)
#'
#' require(dplyr)
#' require(magrittr)
#'
#' dat <- mutate(dummyEDCdata,
#'                rD_NUMBER_RESPONSE = deflfun(dummyEDCdata,
#'                val.col = 'D_NUMBER_RESPONSE', year.col = 'SURVEY_YEAR', to.year = 2019))


deflfun <- function(.data,
  val.col,
  year.col = 'YEAR',
  to.year = max(gdp_defl$YEAR)) {

  .data$index <- 1:nrow(.data)

  data(gdp_defl, envir = environment())

    # check that we have the deflators for the requested year

  if (!to.year %in% gdp_defl$YEAR)
    stop(
      paste0(
        'We do not have deflators for ',
        gsub('DEFL', '', to.year),
        ' please set to.year to a value between ',
        min(gsub('DEFL', '', colnames(gdp_defl)[-1])),
        ' and ',
        max(gsub('DEFL', '', colnames(gdp_defl)[-1]))
      )
    )

  # recalc deflators based on chosen "to.year"
  gdp_defl$DEFL = gdp_defl$DEFL/gdp_defl$DEFL[gdp_defl$YEAR == to.year]

  # check that the name of the year is in the data frame
  if (!year.col %in% colnames(.data))
    stop(
      'YEAR does not exist in dataframe, if the column is not named, YEAR, need to specify definition for year.col.'
    )

  # check that all of the years in the YEAR column are also in the gdp_defl table

    if (any(!dplyr::pull(.data, year.col) %in% gdp_defl$YEAR))
      stop(
        paste0(
          'The years provided do not have associated deflators for the following: ',
          toString(unique(.data[, year.col][!.data[, year.col] %in% gdp_defl$YEAR])),
          ". See package documentation for fix."
        )
      )
  # ADD DEFLATORS TO DATAFRAME
  # merge the gdp_defl table onto the provided data table

    if(sapply(.data, class)[year.col] == 'character') {

        gdp_defl$YEAR = as.character(gdp_defl$YEAR)
        dat1 <- merge(.data, gdp_defl, by.x = year.col, by.y = 'YEAR')


    } else {

        dat1 <- merge(.data, gdp_defl, by.x = year.col, by.y = 'YEAR')

    }

  # calculation the inflation adjustment ####

    if(any(class(dat1) == 'data.table')) {

        dat1$deflVAL = dat1[, ..val.col] / dat1$DEFL

        adj_vector <- dat1[order(dat1$index)][[(1:length(names(dat1)))[names(dat1) == 'deflVAL']]]

    } else {

        dat1$deflVAL = dat1[, val.col] / dat1$DEFL

        adj_vector <- dat1[order(dat1$index), 'deflVAL']

    }

  # return the value
  return(adj_vector)

}




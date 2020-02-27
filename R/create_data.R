#' Create data file for fitting time varying run timing distributions with TMB
#'
#' Does minimal processing of data to use as argument to fitting function
#'
#' @param data A data frame
#' @param min_number A minimum threshold to use, defaults to 0
#' @param variable A character string of the name of the variable in 'data' that contains the response (e.g. counts)
#' @param time A character string of the name of the variable in 'data' that contains the time variable (e.g. year)
#' @param date A character string of the name of the variable in 'data' that contains the response (e.g. day of year). The actual
#' column should contain a numeric response -- for example, the result from using lubridate::yday(x)
#' @param asymmetric_model Boolean, whether or not to let model be asymmetric (e.g. run timing before peak has a
#' different shape than run timing after peak)
#' @param family Response for observation model, options are "gaussian", "poisson", "negbin"
#' @export
#' @examples
#' data(fishdist)
#' datalist = create_data(fishdist, min_number = 0, variable = "number", time = "year",
#' date = "doy", asymmetric_model = TRUE, family = "gaussian")
create_data <- function(data, min_number=0, variable = "number", time="year", date = "doy",
                        asymmetric_model = TRUE, family = "gaussian") {

  dist = c("gaussian", "poisson", "negbin")
  fam = match(family, dist)
  if(is.na(fam)) {
    stop("Make sure the entered family is in the list of accepted distributions")
  }

  # check to make sure year and date are numeric
  if(!is.numeric(data[,time])) {
    stop("The time variable in the data frame (e.g. year) needs to be numeric")
  }
  if(is.numeric(data[,date])) {
    if(max(data[,date],na.rm=T) > 365) stop("The date variable in the data frame contains values greater than 365")
    if(min(data[,date],na.rm=T) < 1) stop("The date variable in the data frame contains values less than 1")
  } else {
    stop("The date variable in the data frame (e.g. day_of_year) needs to be numeric")
  }

  # drop rows below threshold or NAs
  drop_rows = which(is.na(data[,variable]) | data[,variable] <= min_number)
  if(length(drop_rows)>0) data = data[-drop_rows,]

  # rescale year variable
  data$year = data[,time] - min(data[,time]) + 1

  data_list = list(y = data[,variable],
                   years = as.numeric(as.factor(data$year)),
                   x = data[,date],
                   year_levels = as.numeric(as.factor(unique(data$year))),
                   unique_years = unique(data$year),
                   nLevels = length(unique(data$year)),
                   asymmetric = as.numeric(asymmetric_model),
                   family = fam)

  return(data_list)
}

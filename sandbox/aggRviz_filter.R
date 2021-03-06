

#' Filter aggregated data to a chosen level
#'
#' The columns to delete are the features that you DO NOT want to stratify by.
#' This function filters out any row, stratified by those columns,
#' and filters out any unstratified rows from the other features.
#'
#'
#' @param data data.frame
#' @param col_2_delete vector
#'
#'
#'
#' @return data.frame
#'
#'
#'
aggRviz_filter <- function(data,col_2_delete){
  if (!is.data.frame(data)){
    stop("Error: data should be a dataframe!")
  }
  if (!is.vector(col_2_delete)){
    stop("Error! col_2_delete needs to be a vector!")
  }


 # if (union(names(data), col_2_delete) != names(dat)){
  #  stop("col_2_delete contains soemthing that is not a column in the data.frame")
#  }

   keepers <- dplyr::setdiff(names(data),col_2_delete)
  #print(keepers)
  dat <- data %>%
    ## all_vars gets rid of all that have at least one, any gets rid of both
    dplyr::filter_at(col_2_delete, dplyr::all_vars(. =="")) %>%
    ### select only the good stuff
    dplyr::select(dplyr::one_of(keepers))
    ### kill all the blanks!!
  dat <- filter_blanks(dat)
  return(dat)
}



c(5,19) %in% c(5,6,7,8)








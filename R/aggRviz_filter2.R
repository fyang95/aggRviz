

#' Filter aggregated data to a chosen level
#'
#' The columns to delete are the features that you DO NOT want to stratify by.
#' This function filters out any row, stratified by those columns,
#' and filters out any unstratified rows from the other features.
#'
#' OPTION:  col_2_keep lets you filter "in"
#'
#' Option:  if it's not a blank for all categories, set all_symbol
#' This could be NA, or " " or "all".
#'
#' Option:  if you set features, it will only delete columns in that set
#'
#' Option:  fix_place allows you to deal with nested places, that is State.or.Province is in Region is in Country.  For now, these are the 3 fixed places:
#' places[1] subset places[2] subset places[3]
#'
#' In future release, this will be a variable number of places!  but for now it only works with 3 (ordered) places
#'
#'
#' @param data data.frame
#' @param col_2_delete vector
#' @param col_2_keep vector
#' @param all_symbol character
#' @param features vector
#' @param fix_place logical
#' @param places vector
#'
#' @return data.frame
#' @export
#'
#' @examples
#' load("../example_data/yummy.Rda")
#' dat_1
#'
#' aggRviz_filter2(data = dat_1,col_2_delete= c("Dessert", "Fruit"))
#'
#'
aggRviz_filter2 <- function(data,col_2_delete = NULL, col_2_keep = NULL, features = NULL, all_symbol = "", fix_place = TRUE, places = c("State.or.Province", "Region", "Country")){
  if (!is.data.frame(data)){
    stop("Error: data should be a dataframe!")
  }

  ##check that exactly one of col_2_keep and col_2_delete is null
  if (is.null(col_2_delete) & is.null(col_2_keep)){
    stop("Error: enter exactly one of col_2_delete and col_2_keep!")
  }

  if (!is.null(col_2_delete) & !is.null(col_2_keep)){
    stop("Error: enter exactly one of col_2_delete and col_2_keep!")
  }

  if (!is.logical(fix_place) ){
    stop("Error: fix_place needs to be TRUE or FALSE")
  }


  ### checks for features:

  ##set col_features to be EVERYTHING
  col_features <- names(data)

  if (!is.null(features)){
    if(!is.vector(features)){
      stop("Error: features needs to be a vector of values")
    }
    col_features <- dplyr::intersect(names(data), features)
  }


  ### if we're looking at deleting columns.
  if (is.null(col_2_keep)){
    if (!is.vector(col_2_delete)){
      stop("Error! col_2_delete needs to be a vector!")
    }

    col_2_delete <- dplyr::intersect(col_2_delete, col_features)
    keepers <- dplyr::setdiff(col_features,col_2_delete)
      }

### if we're looking at keeping columns.
  if (is.null(col_2_delete)){
    if (!is.vector(col_2_keep)){
      stop("Error! col_2_keep needs to be a vector!")
    }

    keepers <- dplyr::intersect(col_2_keep, col_features)
    col_2_delete <- dplyr::setdiff(col_features, keepers)
  }


  dat <- data

  ###############
  ## clean up the places, to the lowest level:

  if (fix_place){

    if (length(places)!=3){
      stop("This works with only 3 names")
    }

    State.or.Province <- places[1]
    Region <- places[2]
    Country <- places[3]

    places <- names(dat) %>%
      #dplyr::intersect(c("State.or.Province", "Region", "Country"))
      dplyr::intersect(places)



    if (State.or.Province %in% keepers){
      if (Region %in% places & Region %in% col_2_delete ){
        dat <- dat %>%
          dplyr::select(-Region)
      }
      if (Country %in% places & Country %in% col_2_delete ){
        dat <- dat %>%
          dplyr::select(-Country)
      }
    } else if (Region %in% keepers){
      if (Country %in% places & "Country" %in% col_2_delete ){
        dat <- dat %>%
          dplyr::select(-Country)
      }
    }

    col_2_delete <- col_2_delete %>%
      dplyr::intersect(names(dat))
  }



  ###########  Filtering out all features!
  if(length(keepers)== 0){
    dat <- data %>%
      dplyr::filter_at(col_features, dplyr::all_vars(. == "")) %>%
      dplyr::select(-dplyr::one_of(col_features)) #%>%
      #na.omit(.)
    return(dat)
  }


  #######################
  ## if there's nothing left to delete:
  if (length(col_2_delete)==0){
    dat <- dat %>%
      filter_blanks(features, all_symbol) %>%
      droplevels()
    return(dat)
  }


  #####################

  dat <- dat %>%
    ## all_vars gets rid of all that have at least one, any gets rid of both
    dplyr::filter_at(col_2_delete, dplyr::all_vars(. == all_symbol)) %>%
    ### select only the good stuff
    dplyr::select(-dplyr::one_of(col_2_delete))
    ### kill all the blanks!!
  dat <- filter_blanks(dat, features, all_symbol)
  dat <- droplevels(dat)


  return(dat)
}



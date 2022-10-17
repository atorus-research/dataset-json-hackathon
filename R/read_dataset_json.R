#' Convert Variable Type Generator
#'
#' Function factory to return the proper function to
#' convert variable types
#'
#' @param x String indicating type in dataset json standard
#' @export
type_converter <- function(x) {
  switch(
    x,
    integer = as.integer,
    stop('unhandled type')
  )
}

#' Set variable label
#'
#' Applies variable label as the proper type for RStudio viewing
#'
#' @param x Variable
#' @param value Label
#' @export
'label<-' <- function(x, value) {
  attr(x, 'label') <- value
  x
}

#' Read a Dataset JSON file into R
#'
#' From within a Dataset JSON file, read the data into session
#'
#' @param json_file Source file location of dataset json file
#'
#' @return A tibble of the Dataset JSON contents
#'
#' @export
#'
#' @examples
#'
#' read_dataset_json(
#'   url("https://raw.githubusercontent.com/lexjansen/sas-papers/master/pharmasug-2022/json/sdtm/dm.json")
#' )
#'
read_dataset_json <- function(json_file) {
  # Read in the data
  src <- fromJSON(
    json_file,
    simplifyVector=TRUE
    )

  # Pull out the dataset metadata
  meta <- src$clinicalData$itemGroupData[[1]]$items

  # Pull out the actual data, and convert the character matrix to a dataframe
  dat <- src$clinicalData$itemGroupData[[1]]$itemData %>%
    as_tibble(.name_repair="minimal")

  # Apply the variable names onto the dataframe
  names(dat) <- meta$name

  # Loop over each variable in the dataframe
  for (i in seq_along(dat)) {
    # Apply a variable label
    label(dat[[i]]) <- meta$label[i]

    # Covert the type if it's not a string
    if (meta$type[i] != "string") {
      dat[i] <- type_converter(meta$type[i])(dat[[i]])
    }
  }

  dat
}

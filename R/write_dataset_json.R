#' Title
#'
#' @param .data
#'
#' @return
#' @export
#'
#' @examples
write_item_data_rows <- function(.data) {
  for (i in 1:nrow(.data)) {
    # Get the row of the dataframe as a character vector. This pulls out the row
    # as a character vector, which is easy to cat out
    rw <- unname(unlist(df2[i, ]))

    # write the row
    cat('[')
    cat(rw, sep=",")
    cat(']')
  }
}

#' Title
#'
#' @param .data
#'
#' @return
#' @export
#'
#' @examples write_item_data(df)
write_item_data <- function(.data) {
  # Quote any character elements. This is necessary because when writing to
  # JSON, the character elements must be quoted while the numeric elements will
  # not be. To make things simple while R is cat-ing out the information, it
  # helps to have these quotes applied in the data itself before the data are
  # atually written, because we can bulk apply the quoting in vectorized form
  cdata <- .data %>%
    mutate(
      across(where(is.character), ~ paste0('"', ., '"'))
    )

  cat('"itemData":[')
  write_item_data_rows(cdata)
  cat(']')
}


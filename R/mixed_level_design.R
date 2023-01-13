#' Generate a matrix containing only basic factors
base_design <- function(runsize = double()) {
  stopifnot(is.double(runsize))
  k <- log2(runsize)

  if (k < 1 || k %% 1 != 0) {
    stop(
      "Runsize must be a power of 2",
      call. = FALSE
    )
  }

  mat <- matrix(nrow = runsize, ncol = k)
  for (i in 1:k) {
    mat[, i] <- rep(
      c(
        rep(-1, 2**(k - i)),
        rep(1, 2**(k - i))
      ),
      2**(i - 1)
    )
  }
  return(mat)
}

#' Decompose a number `x` into powers of 2 and return the powers.
#' If index is set to one, starts then 2^0 has index 1, else it has index 0.
into_power2 <- function(x = double(), index = 1) {
  stopifnot(is.double(x), x > 0)
  powers <- c()
  i <- 1
  while (i <= x) {
    if (bitwAnd(i, x) == i) {
      powers <- append(powers, log2(i) + index)
    }
    i <- bitwShiftL(i, 1)
  }
  return(powers)
}

custom_design <- function(runsize = double(),
                          columns = vector(),
                          base_mat = NULL) {
  mat <- matrix(nrow = runsize, ncol = length(columns))
  if (is.null(base_mat)) {
    base_mat <- base_design(runsize)
  }
  col_index <- 1
  for (i in columns) {
    sub_mat <- base_mat[, into_power2(i, index = 1)]
    if (is.null(dim(sub_mat))) {
      mat[, col_index] <- sub_mat
    } else {
      mat[, col_index] <- apply(sub_mat, 1, prod)
    }
    col_index <- col_index + 1
  }
  return(mat)
}


#' Generate pairs of factors that can be used to create a four-level factor
pseudo_factor_pairs <- function(m = double()) {
  stopifnot(is.double(m) | m < 1)

  pairs_list <- list()
  for (i in seq(0, 2 * (m - 1), 2)) {
    pair <- 2**c(i, (i + 1))
    index <- (i / 2) + 1
    pairs_list[[index]] <- pair
  }

  return(pairs_list)
}

#' Turn a vector of column numbers into their alias strings
column_alias <- function(columns = vector()) {
  names <- c()
  for (i in columns) {
    basis <- into_power2(i) + 96
    name <- paste0(intToUtf8(basis), collapse = "")
    names <- append(names, name)
  }
  return(names)
}

#' Generate a mixed-level design `runsize` runs and `m` four-level factors, given
#' the columns numbers in `columns` (should only contain added factors).
mixed_level_design <- function(runsize = double(),
                               m = double(),
                               columns = vector()) {
  base_mat <- base_design(runsize)

  # Starting with the added factors' column numbers
  full_col_set <- c(columns)

  # Add basic factors to the whole columns set
  bf_columns <- 2**seq(0, log2(runsize) - 1)
  full_col_set <- append(full_col_set, bf_columns)

  # Generate pairs of pseudo-factors for the four-level factors
  pf_pairs <- pseudo_factor_pairs(m)

  # Remove factors used in pseudo-factors from the two-level factors columns list
  used_in_pf <- is.element(full_col_set, unlist(pf_pairs))
  final_col_set <- full_col_set[!used_in_pf]

  # Remove the duplicate column numbers and sort them
  final_col_set <- sort(unique(final_col_set))

  # Generate the two-level part of the design
  tl_design <- custom_design(runsize, final_col_set, base_mat)

  # Generate the four-level factors independently
  fl_design <- matrix(nrow = runsize, ncol = m)
  index <- 1
  for (pair in pf_pairs) {
    sub_mat <- custom_design(runsize, pair, base_mat)
    fl_design[, index] <- (sub_mat[, 1] + 1) + (sub_mat[, 2] + 1) / 2 + 1
    index <- index + 1
  }

  # Assemble into final design matrix
  mat <- cbind(fl_design, tl_design)
  # Rename the columns of the matrix
  colnames(mat) <- c(LETTERS[1:m], column_alias(final_col_set))
  return(mat)
}

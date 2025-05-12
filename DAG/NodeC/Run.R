###### -- Plan jobs -----------------------------------------------------------

suppressMessages(library(SynExtend))

tmp01 <- tempfile()
files01 <- untar("assemblylists.tar.xz", list = TRUE)
# enforce an increasing order regardless of OS file sorting
o1 <- order(as.integer(unlist(regmatches(m = gregexpr(pattern = "[0-9]+",
                                                      text = files01),
                                         x = files01))))
file01 <- files01[o1]
untar("assemblylists.tar.xz", exdir = tmp01)

# set this up to check things later
tmp02 <- tempfile()
files02 <- untar("comparisonlists.tar.xz", list = TRUE)
o2 <- order(as.integer(unlist(regmatches(m = gregexpr(pattern = "[0-9]+",
                                                      text = files02),
                                         x = files02))))
files02 <- files02[o2]
untar("comparisonlists.tar.xz", exdir = tmp02)

current_res <- table_res <- vector(mode = "list",
                                   length = length(files01))
for (m1 in seq_along(current_res)) {
  current_res[[m1]] <- readLines(paste0(tmp01,
                                        "/",
                                        files01[m1]))
}

# if the file of assemblies you're looking at is the last one,
# grab the upper triangle
# if it's not the last one, grab the full x vs y comparison
count <- 0L
l01 <- length(current_res)
for (m1 in seq_along(current_res)) {
  if (m1 == l01) {
    L <- length(current_res[[m1]])
    L2 <- (L * (L - 1L)) / 2L
    mat <- matrix(data = NA_integer_,
                  ncol = 4L,
                  nrow = L2)
    for (m2 in seq_len(L - 1L)) {
      for (m3 in (m2 + 1L):L) {
        count <- count + 1L
        mat[count, ] <- c(m1, m2, m3, count)
      }
    }
  } else {
    L <- length(current_res[[l01]])
    L2 <- length(current_res[[m1]])
    mat <- matrix(data = NA_integer_,
                  ncol = 4L,
                  nrow = L2 * L)
    for (m2 in seq_len(L)) {
      for (m3 in seq_len(L2)) {
        count <- count + 1L
        mat[count, ] <- c(m1, m2, m3, count)
      }
    }
  }
  table_res[[m1]] <- mat
}

mat <- do.call(rbind,
               table_res)

# ask if there were any previously planned jobs
# use the sum as an offset for the jobs about to be planned
# this is unnecessary because these files are never stored by these identifiers
# and should never collide
# priorjobs <- sum(vapply(X = files02,
#                         FUN = function(x) {
#                           y <- readLines(paste0(tmp02,
#                                                 "/",
#                                                 x))
#                           return(length(y))
#                         },
#                         FUN.VALUE = vector(mode = "integer",
#                                            length = 1L)))

# this can go up to 9.99 billion or whatever
PlannedJobs <- paste0("Pairwise",
                      formatC(x = seq_len(nrow(mat)), # + priorjobs,
                              width = 10,
                              flag = 0,
                              format = "d"),
                      ".txt.gz")

print(paste0(nrow(mat),
             " total jobs planned."))

write.table(x = mat,
            file = paste0("v",
                          m1,
                          "_comparisons_planned.txt"),
            quote = FALSE,
            col.names = FALSE,
            row.names = FALSE,
            append = FALSE)
writeLines(text = PlannedJobs,
           con = paste0("v",
                        m1,
                        "_comparisons_expected.txt"))

CompletedJobs <- vector(mode = "character",
                        length = 0L)
writeLines(text = CompletedJobs,
           con = paste0("v",
                        m1,
                        "_comparisons_completed.txt"))

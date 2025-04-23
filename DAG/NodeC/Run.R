###### -- Plan jobs -----------------------------------------------------------

suppressMessages(library(SynExtend))

x <- readLines("AssembliesCompleted.txt")

L <- length(x)
L2 <- (L * (L - 1L)) / 2L
mat <- matrix(data = NA_integer_,
              ncol = 3L,
              nrow = L2)
Count <- 0L
for (m1 in seq_len(L - 1L)) {
  for (m2 in (m1 + 1L):L) {
    Count <- Count + 1L
    mat[Count, ] <- c(m1, m2, Count)
  }
}

PlannedJobs <- paste0("Pairwise",
                      formatC(x = seq_len(L2),
                              width = 9,
                              flag = 0,
                              format = "d"),
                      ".gz")

print(paste0(L2,
             " total jobs planned."))

write.table(x = mat,
            file = "JobMap.txt",
            quote = FALSE,
            col.names = FALSE,
            row.names = FALSE,
            append = FALSE)
writeLines(text = PlannedJobs,
           con = "PlannedJobs.txt")

CompletedJobs <- vector(mode = "character",
                        length = 0L)
writeLines(text = CompletedJobs,
           con = "CompletedJobs.txt")

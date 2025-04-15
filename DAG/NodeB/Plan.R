###### -- plan the current assembly collection batch --------------------------
# build the collection DAG that will eventually run pseudo-cyclically
# the collection dag is the external subdag that is built on the fly


AssembliesCompleted <- readLines("AssembliesCompleted.txt")
AssembliesExpected <- readLines("AssembliesExpected.txt")
AssemblyPlanning <- read.table(file = "AssemblyPlanning.txt")

# Run limits
LIM <- 5000
# Testing limits
# LIM <- 10L

CurrentAssemblies <- which(!(AssembliesExpected %in% AssembliesCompleted))

if (length(CurrentAssemblies) > LIM) {
  CurrentAssemblies <- CurrentAssemblies[1:LIM]
} # else do not truncate the job

L1 <- length(CurrentAssemblies)

JOBS <- paste0(rep("JOB",
                   L1),
               " BC",
               seq_len(L1),
               " CollectAssemblies.sub")

VARS <- paste0(rep("VARS",
                   L1),
               " BC",
               seq_len(L1),
               ' Address="',
               AssemblyPlanning[CurrentAssemblies, 1L],
               '"',
               ' PersistentID="',
               AssemblyPlanning[CurrentAssemblies, 2L],
               '"',
               ' PFAM="',
               AssemblyPlanning[CurrentAssemblies, 3L],
               '"')

SUBDAG <- vector(mode = "character",
                 length = L1 * 2L)
SUBDAG[c(T,F)] <- JOBS
SUBDAG[c(F,T)] <- VARS

writeLines(SUBDAG,
           "Collection.dag")

print(paste0(length(SUBDAG),
             " line DAG written out as Collection.dag with ",
             L1,
             " total jobs."))




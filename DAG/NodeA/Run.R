###### -- F0 Node begin the DAG based on 'Target' -----------------------------
# genome set within a kingdom

###### -- Arguments -----------------------------------------------------------

TIMESTART <- Sys.time()
Target <- "Prokaryotes"
# we expect the directory of pressed models to be named the same as tar ball
# we set this because we need to append it to lines
PFAM <- "PFAM.tar.gz"
version_tracking <- readLines("VersionStart.txt")

###### -- code body -----------------------------------------------------------

# ("Bacteria"[Organism] OR "Archaea"[Organism]) AND ("latest refseq"[filter] AND "complete genome"[filter] AND "reference genome"[filter] AND all[filter] NOT anomalous[filter] AND "refseq has annotation"[Properties] AND "taxonomy check ok"[filter])

EntrezQuery <- paste0("esearch -db assembly ",
                     "-query '",
                     Target,
                     "[organism] ", # target organism can be changed here
                     'AND "complete genome"[filter] ', # only complete genomes
                     'AND "refseq has annotation"[properties] ', # only genomes with annotations
                     'AND "latest refseq"[filter] ', # only latest
                     'AND "taxonomy check ok"[filter] ',
                     'AND "reference genome"[filter] ',
                     "NOT anomalous[filter]' ",
                     '| ',
                     'esummary ',
                     '| ',
                     'xtract -pattern DocumentSummary -element FtpPath_RefSeq')

FTPs <- system(command = EntrezQuery,
               intern = TRUE,
               timeout = 1000L)

# either set a limit for testing or just shuffle the ftp addresses
# LIM <- 15L
# LIM <- length(FTPs)

# this is a relic of the testing and should have been caught a long time ago...
# I'm no longer limiting this variable during testing, and i haven't been for a long time
# FTPs <- FTPs[sample(x = length(FTPs),
#                     size = LIM,
#                     replace = FALSE)]

# set file names after current version
# assemblies completed
# assemblies expected
# assemblies planned
PrePend <- strsplit(x = version_tracking,
                    split = " ",
                    fixed = TRUE)
# the first element in the last row is the current version number
PrePend <- PrePend[[length(PrePend)]][1]
PrePend <- paste0("v",
                 PrePend,
                 "_assemblies_")

Key <- readLines("FTP_Key.txt")
if (length(Key) == 0) {
  # Key is empty, data set is being generated for the first time
  # JobMapB.txt
  m <- cbind("Adds" = FTPs,
             "PersistentID" = seq(length(FTPs)),
             "PFAM" = rep(x = PFAM,
                          times = length(FTPs)))
  
  write.table(x = m,
              file = paste0(PrePend,
                            "planned.txt"),
              quote = FALSE,
              append = FALSE,
              row.names = FALSE,
              col.names = FALSE)
  write.table(x = m[, c(1, 2)],
              file = "FTP_Key.txt",
              quote = FALSE,
              append = FALSE,
              row.names = FALSE,
              col.names = FALSE)
  
  AssembliesExpected <- paste0("Assembly",
                               formatC(x = seq(length(FTPs)),
                                       width = 9L,
                                       flag = 0,
                                       format = "d"),
                               ".RData")
  writeLines(text = AssembliesExpected,
             con = paste0(PrePend,
                          "expected.txt"))
} else {
  # Key is not empty, data set is being regenerated
  Key <- read.table("FTP_Key.txt")
  NewFTPs <- FTPs[!(FTPs %in% Key[, 1L])]
  
  m <- cbind("Adds" = NewFTPs,
             "PersistentID" = seq(from = max(Key[, 2L]) + 1L,
                                  by = 1,
                                  length.out = length(NewFTPs)),
             "PFAM" = rep(x = PFAM,
                          times = length(NewFTPs)))
  
  write.table(x = m,
              file = paste0(PrePend,
                            "planned.txt"),
              quote = FALSE,
              append = FALSE,
              row.names = FALSE,
              col.names = FALSE)
  
  AssembliesExpected <- paste0("Assembly",
                               formatC(x = seq(from = max(Key[, 2L]) + 1L,
                                               by = 1,
                                               length.out = length(NewFTPs)),
                                       width = 7L,
                                       flag = 0,
                                       format = "d"),
                               ".RData")
  writeLines(text = AssembliesExpected,
             con = paste0(PrePend,
                          "expected.txt"))
  
  Key <- rbind(Key,
               m[, c(1, 2)])
  
  write.table(x = Key[, c(1, 2)],
              file = "FTP_Key.txt",
              col.names = FALSE,
              row.names = FALSE,
              quote = FALSE,
              append = FALSE)
}

AssembliesCompleted <- vector(mode = "character",
                              length = 0L)
writeLines(text = AssembliesCompleted,
           con = paste0(PrePend,
                        "completed.txt"))

TIMEEND <- Sys.time()
print(TIMEEND - TIMESTART)






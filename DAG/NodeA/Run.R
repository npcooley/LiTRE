###### -- F0 Node begin the DAG based on 'Target' -----------------------------
# genome set within a kingdom

###### -- Arguments -----------------------------------------------------------

TIMESTART <- Sys.time()
Target <- "Prokaryotes"
# we expect the directory of pressed models to be named the same as tar ball
# we set this because we need to append it to lines
PFAM <- "PFAM.tar.gz"

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
LIM <- length(FTPs)

FTPs <- FTPs[sample(x = length(FTPs),
                    size = LIM,
                    replace = TRUE)]

Key <- readLines("FTP_Key.txt")
if (length(Key) == 0) {
  # Key is empty, data set is being generated for the first time
  # JobMapB.txt
  m <- cbind("Adds" = FTPs,
             "PersistentID" = seq(length(FTPs)),
             "PFAM" = rep(x = PFAM,
                          times = length(FTPs)))
  
  write.table(x = m,
              file = "AssemblyPlanning.txt",
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
             con = "AssembliesExpected.txt")
} else {
  # Key is not empty, data set is being regenerated
  Key <- read.table(Key)
  NewFTPs <- FTPs[!(FTPs %in% Key[, 1L])]
  
  m <- cbind("Adds" = NewFTPs,
             "PersistentID" = seq(from = max(Key[, 2L]) + 1L,
                                  by = 1,
                                  length.out = length(NewFTPs)),
             "PFAM" = rep(x = PFAM,
                          times = length(NewFTPs)))
  
  write.table(x = m,
              file = "AssemblyPlanning.txt",
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
             con = "AssembliesExpected.txt")
  
  Key <- rbind(Key,
               m)
  
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
           con = "AssembliesCompleted.txt")

TIMEEND <- Sys.time()
print(TIMEEND - TIMESTART)






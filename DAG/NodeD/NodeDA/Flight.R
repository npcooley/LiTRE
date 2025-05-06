###### -- run a single pairwise comparison between two assemblies -------------
# save off a text file (or two)


suppressMessages(library(SynExtend))
suppressMessages(library(RSQLite))

ARGS <- commandArgs(trailingOnly = TRUE)

DataFiles <- ARGS[1:2]
OutID <- ARGS[3]

###### -- code body -----------------------------------------------------------

SeqList <- GCList <- ProtList <- NucList <- vector(mode = "list",
                                                   length = 2L)
IDs <- vector(mode = "character",
              length = 2L)

for (m1 in 1:2) {
  load(file = DataFiles[m1],
       verbose = TRUE)
  
  IDs[m1] <- PersistentID
  SeqList[[m1]] <- Assembly
  GCList[[m1]] <- PGAPGCs
  ProtList[[m1]] <- Prots
}

names(SeqList) <- names(GCList) <- IDs

DBPATH <- tempfile()
Conn01 <- dbConnect(SQLite(), DBPATH)

for (m1  in seq_along(SeqList)) {
  Seqs2DB(seqs = SeqList[[m1]],
          dbFile = DBPATH,
          identifier = IDs[m1],
          verbose = TRUE,
          type = "XStringSet")
}

Syn <- FindSynteny(dbFile = DBPATH,
                   verbose = TRUE)
if (nrow(Syn[[2, 1]]) > 0) {
  L01 <- NucleotideOverlap(SyntenyObject = Syn,
                           GeneCalls = GCList,
                           Verbose = TRUE)
  PrepareSeqs(SynExtendObject = L01,
              DataBase01 = DBPATH)
  # the default args here need to be fixed
  P01 <- SummarizePairs(SynExtendObject = L01,
                        DataBase01 = Conn01,
                        RejectBy = "direct",
                        Verbose = TRUE)
  # these should be the default args and correct
  P02 <- WithinSetCompetition(SynExtendObject = P01,
                              AllowCrossContigConflicts = TRUE,
                              CompeteBy = "Delta_Background",
                              PollContext = FALSE,
                              Verbose = TRUE)
  P02 <- P02[P02$Approx_Global_Score >= 1e-5, ]
  P03 <- SummarizePairs(SynExtendObject = L01,
                        DataBase01 = Conn01,
                        SearchScheme = "standard",
                        RejectBy = "kmeans",
                        Verbose = TRUE)
  P04 <- WithinSetCompetition(SynExtendObject = P03,
                              AllowCrossContigConflicts = TRUE,
                              Verbose = TRUE)
  P04 <- P04[P04$Approx_Global_Score >= 1e-5, ]
  i1 <- paste(P02$p1,
              P02$p2,
              sep = "_")
  i2 <- paste(P04$p1,
              P04$p2,
              sep = "_")
  mat1 <- intersect(i1, i2)
  
  # 1 == in erik's method alone
  # 2 == in both methods
  # 3 == in nick's method alone
  r1 <- !(i1 %in% mat1)
  r2 <- i1 %in% mat1
  r3 <- i2 %in% mat1
  r4 <- !(i2 %in% mat1)
  tab1 <- do.call(rbind,
                  list(data.frame("p1" = P02$p1[r1],
                                  "p2" = P02$p2[r1],
                                  "score" = P02$Approx_Global_Score[r1],
                                  "key" = rep(1, sum(r1))),
                       data.frame("p1" = P02$p1[r2],
                                  "p2" = P02$p2[r2],
                                  "score" = P02$Approx_Global_Score[r2],
                                  "key" = rep(2, sum(r2))),
                       data.frame("p1" = P04$p1[r3],
                                  "p2" = P04$p2[r3],
                                  "score" = P04$Approx_Global_Score[r3],
                                  "key" = rep(2, sum(r3))),
                       data.frame("p1" = P04$p1[r4],
                                  "p2" = P04$p2[r4],
                                  "score" = P04$Approx_Global_Score[r4],
                                  "key" = rep(3, sum(r4)))))
  # either R or Rstudio is truncating the score column when printing internally,
  # so to actually trim to digits of precision we just pass the score through
  # format c
  # sub("^0", "", formatC(pi, digits=5, format="fg", width=1))
  tab1$score <- sub(pattern = "^0",
                    replacement = "",
                    x = formatC(x = tab1$score,
                                digits = 5,
                                format = "fg",
                                width = 1))
  gz1 <- gzfile(paste0("Pairwise",
                       formatC(x = as.integer(OutID),
                               flag = 0,
                               width = 10,
                               format = "d"),
                       ".txt.gz"), 
                "w")
  write.table(x = tab1,
              file = gz1,
              quote = FALSE,
              append = FALSE,
              row.names = FALSE,
              col.names = FALSE,
              sep = "\t")
  close(gz1)
} else {
  gz1 <- gzfile(paste0("Pairwise",
                       formatC(x = as.integer(OutID),
                               flag = 0,
                               width = 10,
                               format = "d"),
                       ".txt.gz"), 
                "w")
  write.table(x = data.frame("p1" = character(),
                             "p2" = character(),
                             "score" = character(),
                             "key" = integer()),
              file = gz1,
              quote = FALSE,
              append = FALSE,
              row.names = FALSE,
              col.names = FALSE,
              sep = "\t")
  close(gz1)
}

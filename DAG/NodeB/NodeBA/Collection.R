###### -- Collect an assembly, call the domains with PFAM ---------------------

###### -- Libraries -----------------------------------------------------------

suppressMessages(library(SynExtend))

###### -- ad hoc functions ----------------------------------------------------

# assumes hmmer is present and in the path
# if a directory is specified without the associated database files
# use hmmpress to create them
# if they are present don't re-run hmmpress
FindModels <- function(Seqs,
                       ModelDir,
                       PerSequence = TRUE,
                       PerDomain = TRUE,
                       ARGS = list("--noali" = NULL)) {
  
  if (missing(Seqs)) {
    stop ("Seqs must be specified and must be an object of class 'AAStringSet'.")
  }
  if (missing(ModelDir)) {
    stop ("A directory containing at least a single '.hmm' file must be supplied.")
  }
  if (!is(object = Seqs,
          class2 = "AAStringSet")) {
    stop ("Seqs must be an object of class 'AAStringSet'.")
  }
  if (!PerSequence & !PerDomain) {
    stop ("At least one output must be specified.")
  }
  
  ModFiles <- list.files(path = ModelDir)
  # hmmpress creates:
  # x.h3f
  # x.h3i
  # x.h3m
  # x.h3p
  # check for all of them
  
  if (any(grepl(pattern = "h3f$",
                x = ModFiles)) &
      any(grepl(pattern = "h3i$",
                x = ModFiles)) &
      any(grepl(pattern = "h3m$",
                x = ModFiles)) &
      any(grepl(pattern = "h3p$",
                x = ModFiles)) &
      any(grepl(pattern = "hmm$",
                x = ModFiles))) {
    cat("\nExpected files present.\n")
    
    # take the first if multiple are present
    TargetModel <- ModFiles[grepl(pattern = "hmm$",
                                  x = ModFiles)][1L]
    
  } else {
    if (any(grepl(pattern = "hmm$",
                  x = ModFiles))) {
      cat("\nHMM database found, but at least some associated files are not present. Calling hmmpress.\n")
      
      # take the first if multiple are present
      TargetModel <- ModFiles[grepl(pattern = "hmm$",
                                    x = ModFiles)][1L]
      
      HMMPRESS <- paste("hmmpress",
                        paste0(ModelDir,
                               "/",
                               TargetModel))
      cat(paste("\nRunning hmmpress command:\n",
                HMMPRESS,
                "\n"))
      system(command = HMMPRESS)
    } else {
      stop ("No HMM database found.")
    }
  }
  
  tmp1 <- tempfile()
  tmp1ext <- paste0(tmp1,
                    ".faa")
  tmp2 <- tempfile()
  tmp3 <- tempfile()
  writeXStringSet(x = Seqs,
                  filepath = tmp1ext)
  
  w1 <- unname(sapply(X = ARGS,
                      FUN = function(x) {
                        is.null(x)
                      },
                      USE.NAMES = FALSE))
  
  if (PerSequence & PerDomain) {
    HMMSCAN <- paste("hmmscan",
                     paste(names(ARGS)[w1],
                           collapse = " "),
                     paste(names(ARGS)[!w1],
                           unlist(ARGS[!w1]),
                           collapse = " "),
                     "--tblout",
                     tmp2,
                     "--domtblout",
                     tmp3,
                     paste0(ModelDir,
                            "/",
                            TargetModel),
                     tmp1ext)
  } else if (PerSequence & !PerDomain) {
    HMMSCAN <- paste("hmmscan",
                     paste(names(ARGS)[w1],
                           collapse = " "),
                     paste(names(ARGS)[!w1],
                           unlist(ARGS[!w1]),
                           collapse = " "),
                     "--tblout",
                     tmp2,
                     paste0(ModelDir,
                            "/",
                            TargetModel),
                     tmp1ext)
  } else if (!PerSequence & PerDomain) {
    HMMSCAN <- paste("hmmscan",
                     paste(names(ARGS)[w1],
                           collapse = " "),
                     paste(names(ARGS)[!w1],
                           unlist(ARGS[!w1]),
                           collapse = " "),
                     "--domtblout",
                     tmp3,
                     paste0(ModelDir,
                            "/",
                            TargetModel),
                     tmp1ext)
  }
  cat(paste0("\nRunning hmmscan command:\n",
             HMMSCAN,
             "\n"))
  t1 <- Sys.time()
  x <- system(command = HMMSCAN,
              intern = TRUE)
  t2 <- Sys.time()
  cat("\nhmmscan completed in:\n")
  print(t2 - t1)
  
  if (PerSequence & PerDomain) {
    z1 <- readLines(tmp2)
    z2 <- z1[-grep(pattern = "^#",
                   x = z1)]
    z3 <- strsplit(x = z2,
                   split = "[ ]+")
    z4 <- sapply(X = z3,
                 FUN = function(x) {
                   c(x[1:18], paste0(x[19:length(x)],
                                     collapse = " "))
                 },
                 simplify = FALSE,
                 USE.NAMES = FALSE)
    
    z4 <- do.call(rbind,
                  z4)
    
    SeqTable <- data.frame("target_name" = z4[, 1L],
                           "target_accession" = z4[, 2L],
                           "query_name" = z4[, 3L],
                           "query_accession" = z4[, 4L],
                           "FULL_E_value" = as.numeric(z4[, 5L]),
                           "FULL_score" = as.numeric(z4[, 6L]),
                           "FULL_bias" = as.numeric(z4[, 7L]),
                           "BEST_DOMAIN_E_value" = as.numeric(z4[, 8]),
                           "BEST_DOMAIN_score" = as.numeric(z4[, 9]),
                           "BEST_DOMAIN_bias" = as.numeric(z4[, 10]),
                           "Domain_Num_Est_exp" = as.numeric(z4[, 11]),
                           "Domain_Num_Est_reg" = as.integer(z4[, 12]),
                           "Domain_Num_Est_clu" = as.integer(z4[, 13]),
                           "Domain_Num_Est_ov" = as.integer(z4[, 14]),
                           "Domain_Num_Est_env" = as.integer(z4[, 15]),
                           "Domain_Num_Est_dom" = as.integer(z4[, 16]),
                           "Domain_Num_Est_rep" = as.integer(z4[, 17]),
                           "Domain_Num_Est_inc" = as.integer(z4[, 18]),
                           "desc_of_target" = z4[, 19],
                           stringsAsFactors = FALSE)
    # domain table
    k2 <- readLines(tmp3)
    k3 <- k2[-grep(pattern = "^#",
                   x = k2)]
    
    k3 <- strsplit(x = k3,
                   split = "[ ]+")
    k4 <- sapply(k3,
                 function(x) {
                   c(x[1:22], paste0(x[23:length(x)],
                                     collapse = " "))
                 },
                 simplify = FALSE,
                 USE.NAMES = FALSE)
    
    k4 <- do.call(rbind,
                  k4)
    DomainTable <- data.frame("target_name" = k4[, 1L],
                              "target_accession" = k4[, 2L],
                              "tlen" = as.integer(k4[, 3L]),
                              "query_name" = k4[, 4L],
                              "query_accession" = k4[, 5L],
                              "qlen" = as.integer(k4[, 6L]),
                              "FULL_E_value" = as.numeric(k4[, 7L]),
                              "FULL_score" = as.numeric(k4[, 8L]),
                              "FULL_bias" = as.numeric(k4[, 9L]),
                              "Percent" = as.integer(k4[, 10L]),
                              "of" = as.integer(k4[, 11L]),
                              "THISDOMAIN_c_Evalue" = as.numeric(k4[, 12]),
                              "THISDOMAIN_i_Evalue" = as.numeric(k4[, 13]),
                              "THISDOMAIN_score" = as.numeric(k4[, 14]),
                              "THISDOMAIN_bias" = as.numeric(k4[, 15]),
                              "HMM_from" = as.integer(k4[, 16]),
                              "HMM_to" = as.integer(k4[, 17]),
                              "ALI_from" = as.integer(k4[, 18]),
                              "ALI_to" = as.integer(k4[, 19]),
                              "ENV_from" = as.integer(k4[, 20]),
                              "ENV_to" = as.integer(k4[, 21]),
                              "acc" = k4[, 22],
                              "desc" = k4[, 23],
                              stringsAsFactors = FALSE)
    
    res <- list("SeqTable" = SeqTable,
                "DomainTable" = DomainTable)
  } else if (PerSequence & !PerDomain) {
    z1 <- readLines(tmp2)
    z2 <- z1[-grep(pattern = "^#",
                   x = z1)]
    z3 <- strsplit(x = z2,
                   split = "[ ]+")
    z4 <- sapply(X = z3,
                 FUN = function(x) {
                   c(x[1:18], paste0(x[19:length(x)],
                                     collapse = " "))
                 },
                 simplify = FALSE,
                 USE.NAMES = FALSE)
    
    z4 <- do.call(rbind,
                  z4)
    
    SeqTable <- data.frame("target_name" = z4[, 1L],
                           "target_accession" = z4[, 2L],
                           "query_name" = z4[, 3L],
                           "query_accession" = z4[, 4L],
                           "FULL_E_value" = as.numeric(z4[, 5L]),
                           "FULL_score" = as.numeric(z4[, 6L]),
                           "FULL_bias" = as.numeric(z4[, 7L]),
                           "BEST_DOMAIN_E_value" = as.numeric(z4[, 8]),
                           "BEST_DOMAIN_score" = as.numeric(z4[, 9]),
                           "BEST_DOMAIN_bias" = as.numeric(z4[, 10]),
                           "Domain_Num_Est_exp" = as.numeric(z4[, 11]),
                           "Domain_Num_Est_reg" = as.integer(z4[, 12]),
                           "Domain_Num_Est_clu" = as.integer(z4[, 13]),
                           "Domain_Num_Est_ov" = as.integer(z4[, 14]),
                           "Domain_Num_Est_env" = as.integer(z4[, 15]),
                           "Domain_Num_Est_dom" = as.integer(z4[, 16]),
                           "Domain_Num_Est_rep" = as.integer(z4[, 17]),
                           "Domain_Num_Est_inc" = as.integer(z4[, 18]),
                           "desc_of_target" = z4[, 19],
                           stringsAsFactors = FALSE)
    
    res <- list("SeqTable" = SeqTable)
  } else if (!PerSequence & PerDomain) {
    
    # domain table
    k2 <- readLines(tmp3)
    k3 <- k2[-grep(pattern = "^#",
                   x = k2)]
    
    k3 <- strsplit(x = k3,
                   split = "[ ]+")
    k4 <- sapply(k3,
                 function(x) {
                   c(x[1:22], paste0(x[23:length(x)],
                                     collapse = " "))
                 },
                 simplify = FALSE,
                 USE.NAMES = FALSE)
    
    k4 <- do.call(rbind,
                  k4)
    DomainTable <- data.frame("target_name" = k4[, 1L],
                              "target_accession" = k4[, 2L],
                              "tlen" = as.integer(k4[, 3L]),
                              "query_name" = k4[, 4L],
                              "query_accession" = k4[, 5L],
                              "qlen" = as.integer(k4[, 6L]),
                              "FULL_E_value" = as.numeric(k4[, 7L]),
                              "FULL_score" = as.numeric(k4[, 8L]),
                              "FULL_bias" = as.numeric(k4[, 9L]),
                              "Percent" = as.integer(k4[, 10L]),
                              "of" = as.integer(k4[, 11L]),
                              "THISDOMAIN_c_Evalue" = as.numeric(k4[, 12]),
                              "THISDOMAIN_i_Evalue" = as.numeric(k4[, 13]),
                              "THISDOMAIN_score" = as.numeric(k4[, 14]),
                              "THISDOMAIN_bias" = as.numeric(k4[, 15]),
                              "HMM_from" = as.integer(k4[, 16]),
                              "HMM_to" = as.integer(k4[, 17]),
                              "ALI_from" = as.integer(k4[, 18]),
                              "ALI_to" = as.integer(k4[, 19]),
                              "ENV_from" = as.integer(k4[, 20]),
                              "ENV_to" = as.integer(k4[, 21]),
                              "acc" = k4[, 22],
                              "desc" = k4[, 23],
                              stringsAsFactors = FALSE)
    
    res <- list("DomainTable" = DomainTable)
  }
  return(res)
}

###### -- start script time ---------------------------------------------------

SCRIPTSTART <- Sys.time()

###### -- arguments -----------------------------------------------------------

system(command = "ls -lh")
# Args key:
# 1 == Address
# 2 == PersistentID
# 3 == PFAM tarball -- contains a directory with the pressed complete PFAM-A hmm set

Args <- commandArgs(trailingOnly = TRUE)
print(Args)

Ftp_Add <- Args[1L]
PersistentID <- Args[2L] # sometimes needs to be int, sometimes char
PFAM <- Args[3L]
PFAMDir <- gsub(pattern = "\\.tar\\.gz",
                replacement = "",
                x = PFAM)

###### -- Extract seqs --------------------------------------------------------

# wait a random number of seconds to try and keep the FTP server from getting
# big mad at locations that have pulled down a lot of jobs
set.seed(as.integer(PersistentID))
SLEEP <- sample(x = seq(50),
                size = 1,
                prob = rep(x = 0.02,
                           times = 50))
Sys.sleep(SLEEP)

FTP_ADDRESS <- paste(Args[1L],
                     "/",
                     strsplit(Args[1L],
                              split = "/",
                              fixed = TRUE)[[1]][10],
                     "_genomic.fna.gz",
                     sep = "")
GFF_ADDRESS <- paste(Args[1L],
                     "/",
                     strsplit(Args[1L],
                              split = "/",
                              fixed = TRUE)[[1]][10],
                     "_genomic.gff.gz",
                     sep = "")
CHECK_ADDRESS <- paste(Args[1L],
                       "/",
                       strsplit(Args[1L],
                                split = "/",
                                fixed = TRUE)[[1]][10],
                       "_assembly_report.txt",
                       sep = "")

# temp01 <- tempfile()
# Assembly <- try(Seqs2DB(seqs = FTP_ADDRESS,
#                         type = "FASTA",
#                         dbFile = temp01,
#                         identifier = PersistentID,
#                         verbose = TRUE),
#                 silent = TRUE)
Assembly <- try(readDNAStringSet(filepath = FTP_ADDRESS),
                silent = TRUE)
z1 <- readLines(CHECK_ADDRESS)
z2 <- strsplit(x = z1,
               split = "\t",
               fixed = TRUE)
# is the table always 10 wide?
w1 <- which(lengths(z2) == 10)
z3 <- z2[w1]
z4 <- do.call(rbind,
              z3)
z5 <- as.integer(z4[2:nrow(z4), 9L])
z6 <- width(Assembly)
if (all(z5 %in% z6)) {
  # do nothing
} else {
  class(Assembly) <- "try-error"
}


if (is(object = Assembly,
       class2 = "try-error")) {
  RETRY <- 5L
  COUNT <- 1L
  while (COUNT <= RETRY & is(object = Assembly,
                             class2 = "try-error")) {
    # unlink(temp01)
    # temp01 <- tempfile()
    SLEEP <- sample(x = seq(10),
                    size = 1,
                    prob = rep(x = 0.1,
                               times = 10))
    Sys.sleep(SLEEP)
    cat(paste0("\nFTP Address Rejected, retry attempt ",
               COUNT,
               "\n"))
    Assembly <- try(readDNAStringSet(filepath = FTP_ADDRESS),
                    silent = TRUE)
    z1 <- readLines(CHECK_ADDRESS)
    z2 <- strsplit(x = z1,
                   split = "\t",
                   fixed = TRUE)
    # is the table always 10 wide?
    w1 <- which(lengths(z2) == 10)
    z3 <- z2[w1]
    z4 <- do.call(rbind,
                  z3)
    z5 <- as.integer(z4[2:nrow(z4), 9L])
    z6 <- width(Assembly)
    if (all(z5 %in% z6)) {
      # do nothing
    } else {
      class(Assembly) <- "try-error"
    }
    # Assembly <- try(Seqs2DB(seqs = FTP_ADDRESS,
    #                         type = "FASTA",
    #                         dbFile = temp01,
    #                         identifier = PersistentID,
    #                         verbose = TRUE),
    #                 silent = TRUE)
    COUNT <- COUNT + 1L
  }
  if (COUNT > !RETRY & is(object = Assembly,
                          class2 = "try-error")) {
    stop ("Check FTP Address? Check node's ability to talk to FTP Site?")
  }
}
# Assembly <- SearchDB(dbFile = temp01,
#                      identifier = PersistentID,
#                      type = "DNAStringSet",
#                      nameBy = "description")

PGAPGCs <- try(gffToDataFrame(GFF = GFF_ADDRESS,
                              Verbose = TRUE),
               silent = TRUE)
if (is(object = PGAPGCs,
       class2 = "try-error")) {
  RETRY <- 5L
  COUNT <- 1L
  while (COUNT <= RETRY & is(object = PGAPGCs,
                             class2 = "try-error")) {
    SLEEP <- sample(x = seq(10),
                    size = 1,
                    prob = rep(x = 0.1,
                               times = 10))
    Sys.sleep(SLEEP)
    cat(paste0("\nFTP Address Rejected, retry attempt ",
               COUNT,
               "\n"))
    PGAPGCs <- try(gffToDataFrame(GFF = GFF_ADDRESS,
                                  Verbose = TRUE),
                   silent = TRUE)
    COUNT <- COUNT + 1L
  }
  if (COUNT > !RETRY & is(object = PGAPGCs,
                          class2 = "try-error")) {
    stop ("Check FTP Address? Check node's ability to talk to FTP Site?")
  }
}

# capture any non whitespace 1 or more times
# capture a whitespace
# capture any non whitespace 1 ore more times then a white space then any non whitespace
# one or more time
# then outside the capture group capture the rest of the string
spp <- gsub(pattern = "^[^ ]+ ([^ ]+ [^ ]+).*",
            replacement = "\\1",
            x = names(Assembly)[1L])

seqs01 <- ExtractBy(x = PGAPGCs,
                    y = Assembly,
                    Verbose = FALSE)
z1 <- sapply(X = PGAPGCs$Range,
             FUN = function(x) {
               sum(x@width)
             },
             simplify = TRUE)
# frameshifted domain searches will be uninformative
Prots <- translate(seqs01[PGAPGCs$Coding & z1 %% 3 == 0],
                   if.fuzzy.codon = "solve")

system(command = paste("tar -xzvf",
                       PFAM))

HMMTimeStart <- Sys.time()
Domains <- FindModels(Seqs = Prots,
                      ModelDir = PFAMDir,
                      PerSequence = FALSE)
HMMTimeEnd <- Sys.time()
HMMTimeTotal <- HMMTimeEnd - HMMTimeStart

system(command = "ls -lha")

###### -- get total time and save data off ------------------------------------

SCRIPTEND <- Sys.time()
SCRIPTTOTAL <- SCRIPTEND - SCRIPTSTART
print(SCRIPTTOTAL)
save(spp,
     Args,
     PersistentID,
     Domains,
     Prots,
     Assembly,
     PGAPGCs,
     SCRIPTTOTAL,
     HMMTimeTotal,
     file = paste0("Assembly",
                   formatC(x = as.integer(PersistentID),
                           width = 9L,
                           format = "d",
                           flag = 0),
                   ".RData"),
     compress = "xz")


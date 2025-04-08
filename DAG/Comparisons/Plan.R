###### -- plan the current set of <= 50k pairwise comparisons -----------------

suppressMessages(library(SynExtend))

AssembliesCollected <- readLines("AssembliesCompleted.txt")
PlannedJobs <- readLines("PlannedJobs.txt")
JobMap <- read.table("JobMap.txt")
CompletedJobs <- readLines("CompletedJobs.txt")
# this line can be edited with the 'var_change.sh' script in the misc_scripts directory
LIM <- 50000

CHRONOS <- c("ENV GET PYTHONPATH",
             "",
             "SUBMIT-DESCRIPTION CHRONOS {",
             "	executable = ./watch.py",
             '	arguments  = "$(Cluster) 18000"',
             "  output     = job.out",
             "	error      = job.err",
             "	log        = time.log",
             "	universe   = local",
             "	getenv     = PYTHONPATH,CONDOR_CONFIG",
             "}",
             "",
             "SERVICE WATCHER CHRONOS",
             "")

ABORTSTATEMENT <- c("",
                    "ABORT-DAG-ON WATCHER 2 RETURN 1")

CurrentJobs <- which(!(PlannedJobs %in% CompletedJobs))

if (length(CurrentJobs) > LIM) {
  CurrentJobs <- CurrentJobs[1:LIM]
} # else do not truncate current jobs

L1 <- length(CurrentJobs)

Partner1 <- AssembliesCollected[JobMap[CurrentJobs, 1L]]
Partner2 <- AssembliesCollected[JobMap[CurrentJobs, 2L]]

# construct the form that allows the DAG to submit the E jobs
JOBS <- paste0(rep("JOB",
                   L1),
               " E",
               seq_len(L1),
               " Run.sub")
VARS <- paste0(rep("VARS",
                   L1),
               " E",
               seq_len(L1),
               ' Partner1="',
               Partner1,
               '"',
               ' Partner2="',
               Partner2,
               '"',
               ' ID="',
               CurrentJobs,
	       '"')

SUBDAG <- vector(mode = "character",
                 length = L1 * 2L)
SUBDAG[c(T,F)] <- JOBS
SUBDAG[c(F,T)] <- VARS

# print(SUBDAG)

COMPLETESUBDAG <- c(CHRONOS,
                    SUBDAG,
                    ABORTSTATEMENT)

writeLines(text = COMPLETESUBDAG,
           con = "Run.dag")

print(paste0((length(COMPLETESUBDAG)),
             " line DAG written out as Run.dag with ",
             L1,
             " total jobs."))


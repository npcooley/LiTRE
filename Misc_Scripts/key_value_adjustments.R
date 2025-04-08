###### -- json file generation ------------------------------------------------

# build some json files that can be used to rapidly and accurately change
# variable names across files

suppressMessages(library(jsonlite))

test_vals <- list("Manager.dag" = list("RETRY B" = 3,
                                       "RETRY D" = 3),
                  "DataCollection/Plan.R" = list("LIM" = 10L),
                  "Comparisons/Plan.R" = list("LIM" = 50))

writeLines(prettify(toJSON(test_vals)),
           "DAG/testvals.json")

prod_vals <- list("Manager.dag" = list("RETRY B" = 10,
                                       "RETRY D" = 250),
                  "DataCollection/Plan.R" = list("LIM" = 5000L),
                  "Comparisons/Plan.R" = list("LIM" = 500000))

writeLines(prettify(toJSON(prod_vals)),
           "DAG/prodvals.json")



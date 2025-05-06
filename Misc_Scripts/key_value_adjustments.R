###### -- json file generation ------------------------------------------------

# build some json files that can be used to rapidly and accurately change
# variable names across files

suppressMessages(library(jsonlite))

test_vals <- list("Manager.dag" = list("RETRY B" = 3,
                                       "RETRY D" = 5),
                  "NodeB/PreCollectionBA.sh" = list("LIM" = 10),
                  "CollectionRetry.sh" = list("LIM" = 3),
                  "NodeD/PreFlightDA.sh" = list("LIM" = 100),
                  "ManagerEnd.sh" = list("LIM" = 5))

writeLines(prettify(toJSON(test_vals)),
           "DAG/testvals.json")

prod_vals <- list("Manager.dag" = list("RETRY B" = 10,
                                       "RETRY D" = 300),
                  "NodeB/PreCollectionBA.sh" = list("LIM" = 10000),
                  "CollectionRetry.sh" = list("LIM" = 10),
                  "NodeD/PreFlightDA.sh" = list("LIM" = 50000),
                  "ManagerEnd.sh" = list("LIM" = 300))

writeLines(prettify(toJSON(prod_vals)),
           "DAG/prodvals.json")



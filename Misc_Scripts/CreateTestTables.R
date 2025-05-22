###### -- create some simple text files ---------------------------------------
# run this from the terminal in LiTRE directory, it will put it's result's into
# <wherever>/LiTRE/Testing/
# i.e. $Rscript <thisscript.R>

df1 <- data.frame("c1" = c("cat",
                           "dog",
                           "ferret",
                           "weasel",
                           "fox",
                           "parrot",
                           "armadillo",
                           "finch",
                           "wolf",
                           "rabbit"),
                  "c2" = 1:10,
                  "c3" = rep("attr", 10))

df2 <- data.frame("c1" = paste0("description",
                                formatC(x = 1:10,
                                        format = "d",
                                        width = 4,
                                        flag = "0"),
                                ".ext1.ext2"))

df3 <- data.frame("c1" = paste0("description",
                                formatC(x = sort(sample(x = 1:10,
                                                        size = 8,
                                                        replace = FALSE)),
                                        format = "d",
                                        width = 4,
                                        flag = "0"),
                                ".ext1.ext2"))

write.table(x = df1,
            file = "Testing/a.txt",
            row.names = FALSE,
            col.names = FALSE,
            append = FALSE,
            quote = FALSE)

write.table(x = df2,
            file = "Testing/b.txt",
            row.names = FALSE,
            col.names = FALSE,
            append = FALSE,
            quote = FALSE)

write.table(x = df3,
            file = "Testing/c.txt",
            row.names = FALSE,
            col.names = FALSE,
            append = FALSE,
            quote = FALSE)

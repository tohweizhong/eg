
library(sparklyr)
library(data.table)

Sys.setenv(SPARK_HOME = "C:/stack/spark-1.6.2-bin-hadoop2.6") # <--- change this to connect to server
.libPaths(c(file.path(Sys.getenv("SPARK_HOME", "R", "lib")), .libPaths()))

sc <- spark_connect(master = "local")

df <- fread("data/adult.csv", data.table = FALSE)

sdf <- sdf_copy_to(sc, mtcars)

sdf %>% group_by(cyl) %>% mean(mpg)



library(dplyr)
iris_tbl <- copy_to(sc, iris)

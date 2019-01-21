# set system environments

Sys.setenv(SPARK_HOME = "C:/stack/spark-1.6.2-bin-hadoop2.6") # <--- change this to connect to server
.libPaths(c(file.path(Sys.getenv("SPARK_HOME", "R", "lib")), .libPaths()))

#if (!require('devtools')) install.packages('devtools')
#devtools::install_github('apache/spark@v1.6.2', subdir='R/pkg')

library(SparkR)

sc <- sparkR.init(master = "local")
sqlContext <- sparkRSQL.init(sc)

#create a sparkR DataFrame
DF <- createDataFrame(sqlContext, faithful)
head(DF)

# Create a simple local data.frame
localDF <- data.frame(name=c("John", "Smith", "Sarah"), age=c(19, 23, 18))

# Convert local data frame to a SparkR DataFrame
df <- createDataFrame(sqlContext, localDF)

# Print its schema
printSchema(df)
# root
#  |-- name: string (nullable = true)
#  |-- age: double (nullable = true)

# Create a DataFrame from a JSON file
path <- file.path(Sys.getenv("SPARK_HOME"), "people.json")
peopleDF <- jsonFile(sqlContext, path)
printSchema(peopleDF)

# Register this DataFrame as a table.
registerTempTable(peopleDF, "people")

# SQL statements can be run by using the sql methods provided by sqlContext
teenagers <- sql(sqlContext, "SELECT name FROM people WHERE age >= 13 AND age <= 19")

# Call collect to get a local data.frame
teenagersLocalDF <- collect(teenagers)

# Print the teenagers in our dataset 
print(teenagersLocalDF)

# # Stop the SparkContext now
# sparkR.stop()

# -----------

textFile <- SparkR:::textFile(sc, "C:/stack/spark-1.6.2-bin-hadoop2.6/CHANGES.txt")
count(textFile)
take(textFile, 1)

linesWithSpark <- SparkR:::filterRDD(textFile, function(line){ grepl("Spark", line)})

count(SparkR:::filterRDD(textFile, function(line){ grepl("Spark", line)})) # How many lines contain "Spark"?

#SparkR:::reduce( lapply( textFile, function(line) { length(strsplit(unlist(line), " ")[[1]])}), function(a, b) { if (a > b) { a } else { b }})

max <- function(a, b) {if (a > b) { a } else { b }}
reduce(map(textFile, function(line) { length(strsplit(unlist(line), " ")[[1]])}), max)

words <- flatMap(textFile,
                 function(line) {
                   strsplit(line, " ")[[1]]
                 })

wordCount <- lapply(words, function(word){ list(word, 1L) })
counts <- reduceByKey(wordCount, "+", 2L)

output <- collect(counts)

for (wordcount in output) {
  cat(wordcount[[1]], ": ", wordcount[[2]], "\n")
}

cache(linesWithSpark)
system.time(count(linesWithSpark))

system.time(count(linesWithSpark))

# library(SparkR)
# 
# sc <- sparkR.init(master="local")
# 
# logFile <- "/home/cloudera/SparkR-pkg/README.md"
# 
# logData <- cache(textFile(sc, logFile))
# 
# numAs <- count(filterRDD(logData, function(s) { grepl("a", s) }))
# numBs <- count(filterRDD(logData, function(s) { grepl("b", s) }))
# 
# paste("Lines with a: ", numAs, ", Lines with b: ", numBs, sep="")
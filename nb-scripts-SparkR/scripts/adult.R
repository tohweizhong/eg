
# demonstration of sparkR
# what's here:
# @ Setting up (setting SPARK_HOME etc.)
# @ Initiation of local cluster (find out exactly what's happening under the hood)
# @ import a dataset, minor manipulation
# @ run both OLS, logistic regression
# @ (kmeans and NBC only available on spark 2.0 onwards)

# will copy this to notebook later for demos.

# envt setup
Sys.setenv(SPARK_HOME = "C:/stack/spark-1.6.2-bin-hadoop2.6") # <--- change this to connect to server
.libPaths(c(file.path(Sys.getenv("SPARK_HOME", "R", "lib")), .libPaths()))

library(SparkR)
library(caret)
library(magrittr)

# initialize local spark cluster and SQL context
sc <- sparkR.init(master = "local")
sqlContext <- sparkRSQL.init(sc)

# read local file
adult <- read.csv("data/adult.csv")

# create an ID column to create training/testing sets later
adult$id <- seq(1, nrow(adult))

# create a data frame in sparkR
DF <- createDataFrame(sqlContext, adult)
head(DF)
str(DF)
printSchema(DF)

# some minor manipulation
#DF$income <- as.factor(DF$income) # <- is this necessary? No

# Doesnt work:
#idx <- which(DF$education == " Bachelors")
#idx <- which(DF[,"education"] == " Bachelors")
#idx <- which(DF[,4] == " Bachelors")

# This doesnt works:
#DF2 <- subset(DF, DF$education == " Bachelors")
#dim(DF2) # takes awhile

# Doesnt work
#DF$income %>% as.character
#unclass(DF$age) %>% head

# Cross validation
# Need to create an ID column and do matching
trainDF <- SparkR::sample(DF, FALSE, 0.7)
trainID <- SparkR::collect(select(trainDF, "id"))$id
testID <- setdiff(1:nrow(DF), trainID)
registerTempTable(DF, "DF")
query <- paste("SELECT * FROM DF WHERE id in (",
               paste(shQuote(testID, type = "sh"), collapse = ', '), ")")
testDF <- sql(sqlContext, query)

# Run the following algorithms
# @ OLS
# @ logistic regression

# ====

ols0 <- SparkR::glm(data = trainDF, age ~ income + education_num,
                    family = "gaussian")
summary(ols0)

ols0_pred <- SparkR::predict(ols0, testDF)
ols0_pred <- select(ols0_pred, "prediction") %>% collect

Metrics::rmse(predicted = ols0_pred[,1],
              actual = (select(testDF, "age") %>% collect)[,1])

# ===

lg0 <- SparkR::glm(data = trainDF, income ~ age + education,
                   family = "binomial")
summary(lg0)

lg0_pred_prob <- SparkR::predict(lg0, testDF)
lg0_pred_prob %>% select(., "prediction") %>% collect %>% head
lg0_pred_prob <- lg0_pred_prob %>% select(., "prediction") %>% collect

#confusionMatrix(lg0_pred_prob, select(testDF, "income") %>% collect)
# will need to change the target variable in the original dataset to {0,1}

# ===

sparkR.stop()

# END


library(yaml)
library(magrittr)
library(rlist)

source("etl_functions.R")

# load yaml file
yml <- yaml.load_file("yaml/adult_etl.yaml")

# read data
df <- yml$arguments[[1]]$value %>% read.csv(., stringsAsFactors = FALSE)

# get required transformations
required_transformations <- lapply(yml$transformations, FUN = function(ele){
  
  hasIdx <- ele %>% unlist %>% length %>% `>`(., 1) %>% isTRUE
  ifelse(hasIdx, return(ele), return())
  
}) %>% list.clean(., fun = is.null)

# do the transformations
lapply(required_transformations, FUN = function(ele){
  
  df <<- ele$name %>% call(., df, ele$index) %>% eval
  return(".")
  
})

# --------------------------------------------------------------------- #
# Transformations that cannot be supported by the ETL process goes here #




# --------------------------------------------------------------------- #

# output
write.table(x = df, file = yml$arguments[[3]]$value, row.names = FALSE)

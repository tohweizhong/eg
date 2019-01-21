# etl_functions.R

# every function has only two arguments: df and idx

# function to drop column
drop_column <- function(df, idx){
  df %>% subset(., select = -idx) %>% return
}

# use data.table syntax?
take_log <- function(df, idx){
  df[,idx] <- log10(df[,idx])
  return(df)
}


# functions:
# scaling
# changing datatype
# category reordering for categorical variables
# imputations
# feature engineering

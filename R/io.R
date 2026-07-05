library(data.table)

read_labchart_txt <- function(file){
  
  df <- fread(
    file,
    skip = 6,
    header = FALSE
  )
  
  colnames(df) <- c(
    "Time",
    "Unit",
    "MT",
    "TTL"
  )
  
  return(df)
}
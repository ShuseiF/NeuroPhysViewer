# io.R
# Functions for reading LabChart-exported text files.
# Returns a data frame with columns:
# Time, Unit, MT, TTL

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
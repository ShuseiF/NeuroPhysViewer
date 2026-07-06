#=========================================================
# io.R
# Read LabChart exported TXT files
#=========================================================

read_labchart_txt <- function(file){
  
  lines <- readLines(file, encoding = "unknown")
  
  metadata <- lines[1:6]
  dat_lines <- lines[-(1:6)]
  
  n <- length(dat_lines)
  
  Time <- numeric(n)
  Unit <- numeric(n)
  MT   <- numeric(n)
  TTL  <- numeric(n)
  
  labels <- vector("list", 100)
  
  j <- 1
  k <- 1
  
  for(i in seq_along(dat_lines)){
    
    x <- strsplit(dat_lines[i], "\t")[[1]]
    
    if(length(x) < 4)
      next
    
    Time[j] <- as.numeric(x[1])
    Unit[j] <- as.numeric(x[2])
    MT[j]   <- as.numeric(x[3])
    TTL[j]  <- as.numeric(x[4])
    
    if(length(x) >= 5){
      
      labels[[k]] <- data.frame(
        Time = Time[j],
        Label = paste(x[5:length(x)], collapse = " "),
        stringsAsFactors = FALSE
      )
      
      k <- k + 1
    }
    
    j <- j + 1
  }
  
  waveform <- data.frame(
    Time = Time[1:(j-1)],
    Unit = Unit[1:(j-1)],
    MT   = MT[1:(j-1)],
    TTL  = TTL[1:(j-1)]
  )
  
  labels <- labels[1:(k-1)]
  
  if(length(labels) > 0){
    labels <- do.call(rbind, labels)
  } else {
    labels <- data.frame(
      Time = numeric(0),
      Label = character(0)
    )
  }
  
  list(
    metadata = metadata,
    waveform = waveform,
    labels = labels
  )
}

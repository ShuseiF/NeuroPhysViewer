#=========================================================
# io.R
# Read LabChart exported TXT files
#=========================================================

read_labchart_txt <- function(file){
  
  lines <- readLines(file, encoding = "unknown")
  
  ## -----------------------------
  ## Metadata (最初の6行)
  ## -----------------------------
  
  metadata <- lines[1:6]
  
  ## -----------------------------
  ## Data
  ## -----------------------------
  
  dat_lines <- lines[-(1:6)]
  
  waveform <- vector("list", length(dat_lines))
  labels <- list()
  
  j <- 1
  
  for(i in seq_along(dat_lines)){
    
    x <- strsplit(dat_lines[i], "\t")[[1]]
    
    if(length(x) < 4)
      next
    
    waveform[[j]] <- data.frame(
      
      Time = as.numeric(x[1]),
      Unit = as.numeric(x[2]),
      MT   = as.numeric(x[3]),
      TTL  = as.numeric(x[4]),
      
      stringsAsFactors = FALSE
      
    )
    
    if(length(x) >= 5){
      
      labels[[length(labels)+1]] <- data.frame(
        
        Time = as.numeric(x[1]),
        Label = paste(x[5:length(x)], collapse=" "),
        
        stringsAsFactors = FALSE
        
      )
      
    }
    
    j <- j + 1
    
  }
  
  waveform <- do.call(rbind, waveform)
  
  if(length(labels)>0){
    
    labels <- do.call(rbind, labels)
    
  }else{
    
    labels <- data.frame(
      Time=numeric(0),
      Label=character(0)
    )
    
  }
  
  list(
    
    metadata = metadata,
    
    waveform = waveform,
    
    labels = labels
    
  )
  
}
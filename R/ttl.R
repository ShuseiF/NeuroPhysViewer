detect_ttl <- function(time,
                       ttl,
                       threshold = NULL){
  
  if(is.null(threshold)){
    
    threshold <- (max(ttl, na.rm=TRUE)+
                    min(ttl, na.rm=TRUE))/2
    
  }
  
  state <- ttl > threshold
  
  onset <- which(diff(state)==1)+1
  offset <- which(diff(state)==-1)+1
  
  if(length(offset)>0 &&
     length(onset)>0){
    
    if(offset[1] < onset[1])
      offset <- offset[-1]
    
    if(length(onset) > length(offset))
      onset <- onset[-length(onset)]
    
  }
  
  data.frame(
    
    Stim = seq_along(onset),
    
    Onset = time[onset],
    
    Offset = time[offset],
    
    Width_ms =
      (time[offset]-time[onset])*1000,
    
    OnsetIndex = onset,
    
    OffsetIndex = offset
    
  )
  
}


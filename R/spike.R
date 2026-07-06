detect_spikes <- function(time,
                          signal,
                          threshold,
                          polarity = "negative"){
  
  if(polarity == "negative"){
    state <- signal < threshold
  } else {
    state <- signal > threshold
  }
  
  idx <- which(diff(state) == 1) + 1
  
  data.frame(
    SpikeTime = time[idx],
    SpikeIndex = idx
  )
}

make_raster_data <- function(spikes,
                             ttl,
                             window_start = -0.05,
                             window_end = 0.20){
  
  out <- list()
  
  for(i in seq_len(nrow(ttl))){
    
    t0 <- ttl$Onset[i]
    
    s <- spikes$SpikeTime - t0
    
    s <- s[s >= window_start & s <= window_end]
    
    if(length(s) > 0){
      out[[i]] <- data.frame(
        Stim = i,
        Time = s
      )
    }
  }
  
  if(length(out) == 0){
    return(data.frame(Stim = numeric(), Time = numeric()))
  }
  
  do.call(rbind, out)
}
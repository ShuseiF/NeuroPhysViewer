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

make_psth_data <- function(raster_df,
                           window_start = -0.05,
                           window_end = 0.20,
                           bin_width = 0.005,
                           n_stim = NULL){
  
  if(is.null(n_stim)){
    n_stim <- length(unique(raster_df$Stim))
  }
  
  breaks <- seq(window_start, window_end, by = bin_width)
  
  if(tail(breaks, 1) < window_end){
    breaks <- c(breaks, window_end)
  }
  
  counts <- hist(
    raster_df$Time,
    breaks = breaks,
    plot = FALSE
  )$counts
  
  data.frame(
    Time = head(breaks, -1) + diff(breaks) / 2,
    Count = counts,
    FiringRate = counts / n_stim / bin_width
  )
}
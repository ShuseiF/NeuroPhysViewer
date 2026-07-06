detect_spikes <- function(time,
                          signal,
                          threshold,
                          polarity = "negative",
                          refractory_ms = 1.0,
                          peak_window_ms = 1.5){
  
  dt <- median(diff(time), na.rm = TRUE)
  refractory_n <- max(1, round((refractory_ms / 1000) / dt))
  peak_window_n <- max(1, round((peak_window_ms / 1000) / dt))
  
  if(polarity == "negative"){
    state <- signal < threshold
  } else {
    state <- signal > threshold
  }
  
  crossings <- which(diff(state) == 1) + 1
  
  if(length(crossings) == 0){
    return(data.frame(
      SpikeTime = numeric(),
      SpikeIndex = integer(),
      SpikeValue = numeric()
    ))
  }
  
  keep <- c(TRUE, diff(crossings) > refractory_n)
  crossings <- crossings[keep]
  
  peak_idx <- sapply(crossings, function(i){
    
    i1 <- max(1, i - peak_window_n)
    i2 <- min(length(signal), i + peak_window_n)
    
    if(polarity == "negative"){
      i1 + which.min(signal[i1:i2]) - 1
    } else {
      i1 + which.max(signal[i1:i2]) - 1
    }
  })
  
  peak_idx <- unique(peak_idx)
  
  data.frame(
    SpikeTime = time[peak_idx],
    SpikeIndex = peak_idx,
    SpikeValue = signal[peak_idx]
  )
}

make_spike_waveforms <- function(time,
                                 signal,
                                 spikes,
                                 pre_ms = 2,
                                 post_ms = 3,
                                 max_spikes = 300){
  
  if(is.null(spikes) || nrow(spikes) == 0){
    return(data.frame())
  }
  
  if(nrow(spikes) > max_spikes){
    idx_use <- round(seq(1, nrow(spikes), length.out = max_spikes))
    spikes <- spikes[idx_use, , drop = FALSE]
  }
  
  dt <- median(diff(time), na.rm = TRUE)
  pre_n <- round((pre_ms / 1000) / dt)
  post_n <- round((post_ms / 1000) / dt)
  
  rel_time <- (-pre_n:post_n) * dt * 1000
  
  out <- list()
  
  for(i in seq_len(nrow(spikes))){
    
    idx <- spikes$SpikeIndex[i]
    i1 <- idx - pre_n
    i2 <- idx + post_n
    
    if(i1 < 1 || i2 > length(signal)){
      next
    }
    
    out[[length(out) + 1]] <- data.frame(
      SpikeID = i,
      Time_ms = rel_time,
      Voltage = signal[i1:i2]
    )
  }
  
  if(length(out) == 0){
    return(data.frame())
  }
  
  do.call(rbind, out)
}

make_mean_waveform <- function(waveforms){
  
  if(is.null(waveforms) || nrow(waveforms) == 0){
    return(data.frame())
  }
  
  aggregate(
    Voltage ~ Time_ms,
    data = waveforms,
    FUN = mean
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
  
  if(is.null(n_stim)) n_stim <- length(unique(raster_df$Stim))
  
  breaks <- seq(window_start, window_end, by = bin_width)
  if(tail(breaks, 1) < window_end) breaks <- c(breaks, window_end)
  
  counts <- hist(raster_df$Time, breaks = breaks, plot = FALSE)$counts
  
  data.frame(
    Time = head(breaks, -1) + diff(breaks) / 2,
    Count = counts,
    FiringRate = counts / n_stim / bin_width
  )
}

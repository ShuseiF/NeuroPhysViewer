library(plotly)

downsample_df <- function(df, max_points = 5000){
  n <- nrow(df)
  if(n <= max_points) return(df)
  idx <- unique(round(seq(1, n, length.out = max_points)))
  df[idx, ]
}

add_ttl_lines <- function(p, ttl, y_min, y_max){
  if(is.null(ttl) || nrow(ttl) == 0) return(p)
  
  add_segments(
    p,
    data = ttl,
    x = ~Onset,
    xend = ~Onset,
    y = y_min,
    yend = y_max,
    inherit = FALSE,
    line = list(color = "red", width = 1),
    showlegend = FALSE
  )
}

plot_waveform <- function(df,
                          ttl = NULL,
                          spikes = NULL,
                          show_ttl = TRUE,
                          show_spikes = TRUE){
  
  df_plot <- downsample_df(df, max_points = 5000)
  
  p_unit <- plot_ly(
    df_plot,
    x = ~Time,
    y = ~Unit,
    type = "scattergl",
    mode = "lines",
    name = "Unit",
    line = list(width = 1)
  )
  
  if(show_spikes && !is.null(spikes) && nrow(spikes) > 0){
    p_unit <- p_unit |>
      add_markers(
        data = spikes,
        x = ~SpikeTime,
        y = ~SpikeValue,
        marker = list(size = 6, symbol = "triangle-up"),
        name = "Detected spikes",
        inherit = FALSE
      )
  }
  
  p_mt <- plot_ly(
    df_plot,
    x = ~Time,
    y = ~MT,
    type = "scattergl",
    mode = "lines",
    name = "MT",
    line = list(width = 1)
  )
  
  p_ttl <- plot_ly(
    df_plot,
    x = ~Time,
    y = ~TTL,
    type = "scattergl",
    mode = "lines",
    name = "TTL",
    line = list(width = 1)
  )
  
  if(show_ttl){
    p_unit <- add_ttl_lines(p_unit, ttl, min(df_plot$Unit, na.rm = TRUE), max(df_plot$Unit, na.rm = TRUE))
    p_mt   <- add_ttl_lines(p_mt, ttl, min(df_plot$MT, na.rm = TRUE), max(df_plot$MT, na.rm = TRUE))
    p_ttl  <- add_ttl_lines(p_ttl, ttl, min(df_plot$TTL, na.rm = TRUE), max(df_plot$TTL, na.rm = TRUE))
  }
  
  subplot(
    p_unit,
    p_mt,
    p_ttl,
    nrows = 3,
    shareX = TRUE,
    titleY = TRUE
  ) |>
    layout(
      showlegend = FALSE,
      xaxis3 = list(title = "Time (s)")
    )
}

plot_review_window <- function(df,
                               ttl = NULL,
                               spikes = NULL,
                               threshold = NULL,
                               review_start = 1.0,
                               review_width_ms = 30,
                               show_ttl = TRUE,
                               show_spikes = TRUE){
  
  review_end <- review_start + review_width_ms / 1000
  idx <- which(df$Time >= review_start & df$Time <= review_end)
  
  if(length(idx) == 0){
    return(
      plot_ly() |>
        layout(
          title = paste0(
            "No waveform data. Data range = ",
            round(min(df$Time, na.rm = TRUE), 4),
            " - ",
            round(max(df$Time, na.rm = TRUE), 4),
            " s / Review = ",
            round(review_start, 4),
            " - ",
            round(review_end, 4),
            " s"
          ),
          xaxis = list(title = "Time (s)", range = c(review_start, review_end)),
          yaxis = list(title = "Unit")
        )
    )
  }
  
  df_review <- df[idx, , drop = FALSE]
  
  spikes_review <- data.frame()
  if(!is.null(spikes) && nrow(spikes) > 0){
    sidx <- which(spikes$SpikeTime >= review_start & spikes$SpikeTime <= review_end)
    if(length(sidx) > 0){
      spikes_review <- spikes[sidx, , drop = FALSE]
    }
  }
  
  ttl_review <- data.frame()
  if(!is.null(ttl) && nrow(ttl) > 0){
    tidx <- which(ttl$Onset >= review_start & ttl$Onset <= review_end)
    if(length(tidx) > 0){
      ttl_review <- ttl[tidx, , drop = FALSE]
    }
  }
  
  y_values <- df_review$Unit
  
  if(!is.null(threshold)){
    y_values <- c(y_values, threshold)
  }
  
  if(nrow(spikes_review) > 0){
    y_values <- c(y_values, spikes_review$SpikeValue)
  }
  
  y_min <- min(y_values, na.rm = TRUE)
  y_max <- max(y_values, na.rm = TRUE)
  y_pad <- (y_max - y_min) * 0.2
  
  if(!is.finite(y_pad) || y_pad == 0){
    y_pad <- 1
  }
  
  p <- plot_ly(
    data = df_review,
    x = ~Time,
    y = ~Unit,
    type = "scatter",
    mode = "lines",
    line = list(width = 1),
    showlegend = FALSE
  )
  
  p <- p |>
    add_segments(
      x = review_start,
      xend = review_end,
      y = threshold,
      yend = threshold,
      inherit = FALSE,
      line = list(color = "orange", width = 1, dash = "dash"),
      showlegend = FALSE
    )
  
  if(show_ttl && nrow(ttl_review) > 0){
    p <- p |>
      add_segments(
        data = ttl_review,
        x = ~Onset,
        xend = ~Onset,
        y = y_min - y_pad,
        yend = y_max + y_pad,
        inherit = FALSE,
        line = list(color = "red", width = 1),
        showlegend = FALSE
      )
  }
  
  if(show_spikes && nrow(spikes_review) > 0){
    p <- p |>
      add_markers(
        data = spikes_review,
        x = ~SpikeTime,
        y = ~SpikeValue,
        inherit = FALSE,
        marker = list(size = 9, symbol = "triangle-up"),
        showlegend = FALSE
      )
  }
  
  p |>
    layout(
      title = paste0(
        "Review Window: ",
        round(review_start, 4),
        " - ",
        round(review_end, 4),
        " s"
      ),
      showlegend = FALSE,
      xaxis = list(
        title = "Time (s)",
        range = c(review_start, review_end)
      ),
      yaxis = list(
        title = "Unit",
        range = c(y_min - y_pad, y_max + y_pad)
      )
    )
}

plot_spike_overlay <- function(waveforms,
                               mean_waveform){
  
  if(is.null(waveforms) || nrow(waveforms) == 0){
    return(
      plot_ly() |>
        layout(
          title = "No spike waveforms",
          xaxis = list(title = "Time from spike peak (ms)"),
          yaxis = list(title = "Voltage")
        )
    )
  }
  
  waveform_lines <- data.frame(
    Time_ms = c(),
    Voltage = c()
  )
  
  ids <- unique(waveforms$SpikeID)
  
  for(id in ids){
    w <- waveforms[waveforms$SpikeID == id, , drop = FALSE]
    
    waveform_lines <- rbind(
      waveform_lines,
      data.frame(
        Time_ms = c(w$Time_ms, NA),
        Voltage = c(w$Voltage, NA)
      )
    )
  }
  
  p <- plot_ly(
    waveform_lines,
    x = ~Time_ms,
    y = ~Voltage,
    type = "scatter",
    mode = "lines",
    line = list(width = 0.5),
    opacity = 0.25,
    hoverinfo = "none",
    showlegend = FALSE
  )
  
  if(!is.null(mean_waveform) && nrow(mean_waveform) > 0){
    p <- p |>
      add_lines(
        data = mean_waveform,
        x = ~Time_ms,
        y = ~Voltage,
        inherit = FALSE,
        line = list(width = 3),
        showlegend = FALSE
      )
  }
  
  p |>
    add_segments(
      x = 0,
      xend = 0,
      y = min(waveforms$Voltage, na.rm = TRUE),
      yend = max(waveforms$Voltage, na.rm = TRUE),
      inherit = FALSE,
      line = list(color = "red", width = 1, dash = "dot"),
      showlegend = FALSE
    ) |>
    layout(
      showlegend = FALSE,
      xaxis = list(title = "Time from spike peak (ms)"),
      yaxis = list(title = "Voltage")
    )
}

plot_raster <- function(raster_df,
                        window_start = -0.05,
                        window_end = 0.20){
  
  if(is.null(raster_df) || nrow(raster_df) == 0){
    return(plot_ly() |>
             layout(title = "No spikes detected in raster window",
                    xaxis = list(title = "Time from TTL onset (s)"),
                    yaxis = list(title = "Stimulus #")))
  }
  
  raster_lines <- data.frame(
    x = rep(raster_df$Time, each = 3),
    y = as.vector(rbind(raster_df$Stim - 0.35,
                        raster_df$Stim + 0.35,
                        NA))
  )
  
  plot_ly(raster_lines, x = ~x, y = ~y,
          type = "scatter", mode = "lines",
          line = list(width = 1),
          hoverinfo = "none",
          showlegend = FALSE) |>
    add_segments(x = 0, xend = 0,
                 y = 0,
                 yend = max(raster_df$Stim, na.rm = TRUE) + 1,
                 inherit = FALSE,
                 line = list(color = "red", width = 1),
                 showlegend = FALSE) |>
    layout(
      showlegend = FALSE,
      xaxis = list(title = "Time from TTL onset (s)",
                   range = c(window_start, window_end)),
      yaxis = list(title = "Stimulus #",
                   autorange = "reversed")
    )
}

plot_psth <- function(psth_df,
                      window_start = -0.05,
                      window_end = 0.20){
  
  if(is.null(psth_df) || nrow(psth_df) == 0){
    return(plot_ly() |>
             layout(title = "No PSTH data",
                    xaxis = list(title = "Time from TTL onset (s)"),
                    yaxis = list(title = "Firing rate (Hz)")))
  }
  
  plot_ly(
    psth_df,
    x = ~Time,
    y = ~FiringRate,
    type = "bar",
    marker = list(line = list(width = 0))
  ) |>
    add_segments(
      x = 0,
      xend = 0,
      y = 0,
      yend = max(psth_df$FiringRate, na.rm = TRUE),
      inherit = FALSE,
      line = list(color = "red", width = 1),
      showlegend = FALSE
    ) |>
    layout(
      showlegend = FALSE,
      bargap = 0,
      xaxis = list(title = "Time from TTL onset (s)",
                   range = c(window_start, window_end)),
      yaxis = list(title = "Firing rate (Hz)")
    )
}

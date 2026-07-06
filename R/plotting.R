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

plot_waveform <- function(df, ttl = NULL, show_ttl = TRUE){
  
  df_plot <- downsample_df(df, max_points = 5000)
  
  p_unit <- plot_ly(df_plot, x = ~Time, y = ~Unit,
                    type = "scattergl", mode = "lines",
                    name = "Unit", line = list(width = 1))
  
  p_mt <- plot_ly(df_plot, x = ~Time, y = ~MT,
                  type = "scattergl", mode = "lines",
                  name = "MT", line = list(width = 1))
  
  p_ttl <- plot_ly(df_plot, x = ~Time, y = ~TTL,
                   type = "scattergl", mode = "lines",
                   name = "TTL", line = list(width = 1))
  
  if(show_ttl){
    p_unit <- add_ttl_lines(p_unit, ttl, min(df_plot$Unit, na.rm = TRUE), max(df_plot$Unit, na.rm = TRUE))
    p_mt   <- add_ttl_lines(p_mt, ttl, min(df_plot$MT, na.rm = TRUE), max(df_plot$MT, na.rm = TRUE))
    p_ttl  <- add_ttl_lines(p_ttl, ttl, min(df_plot$TTL, na.rm = TRUE), max(df_plot$TTL, na.rm = TRUE))
  }
  
  subplot(p_unit, p_mt, p_ttl, nrows = 3, shareX = TRUE, titleY = TRUE) |>
    layout(showlegend = FALSE, xaxis3 = list(title = "Time (s)"))
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
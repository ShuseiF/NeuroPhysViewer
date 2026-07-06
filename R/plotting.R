library(plotly)

downsample_df <- function(df, max_points = 5000){
  
  n <- nrow(df)
  
  if(n <= max_points){
    return(df)
  }
  
  idx <- unique(round(seq(1, n, length.out = max_points)))
  
  df[idx, ]
}

add_ttl_lines <- function(p, ttl, y_min, y_max){
  
  if(is.null(ttl) || nrow(ttl) == 0){
    return(p)
  }
  
  add_segments(
    p,
    data = ttl,
    x = ~Onset,
    xend = ~Onset,
    y = y_min,
    yend = y_max,
    inherit = FALSE,
    line = list(
      color = "red",
      width = 1
    ),
    showlegend = FALSE
  )
}

plot_waveform <- function(df,
                          ttl = NULL,
                          show_ttl = TRUE){
  
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
    
    p_unit <- add_ttl_lines(
      p_unit,
      ttl,
      y_min = min(df_plot$Unit, na.rm = TRUE),
      y_max = max(df_plot$Unit, na.rm = TRUE)
    )
    
    p_mt <- add_ttl_lines(
      p_mt,
      ttl,
      y_min = min(df_plot$MT, na.rm = TRUE),
      y_max = max(df_plot$MT, na.rm = TRUE)
    )
    
    p_ttl <- add_ttl_lines(
      p_ttl,
      ttl,
      y_min = min(df_plot$TTL, na.rm = TRUE),
      y_max = max(df_plot$TTL, na.rm = TRUE)
    )
  }
  
  p <- subplot(
    p_unit,
    p_mt,
    p_ttl,
    nrows = 3,
    shareX = TRUE,
    titleY = TRUE
  )
  
  layout(
    p,
    showlegend = FALSE,
    xaxis3 = list(title = "Time (s)")
  )
}
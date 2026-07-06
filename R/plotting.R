library(plotly)

downsample_df <- function(df, max_points = 5000){
  
  n <- nrow(df)
  
  if(n <= max_points){
    return(df)
  }
  
  idx <- unique(round(seq(1, n, length.out = max_points)))
  
  df[idx, ]
}

plot_waveform <- function(df){
  
  df_plot <- downsample_df(df, max_points = 5000)
  
  p <- subplot(
    
    plot_ly(
      df_plot,
      x = ~Time,
      y = ~Unit,
      type = "scattergl",
      mode = "lines",
      name = "Unit",
      line = list(width = 1)
    ),
    
    plot_ly(
      df_plot,
      x = ~Time,
      y = ~MT,
      type = "scattergl",
      mode = "lines",
      name = "MT",
      line = list(width = 1)
    ),
    
    plot_ly(
      df_plot,
      x = ~Time,
      y = ~TTL,
      type = "scattergl",
      mode = "lines",
      name = "TTL",
      line = list(width = 1)
    ),
    
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
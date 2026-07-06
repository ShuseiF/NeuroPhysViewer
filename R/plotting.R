library(plotly)

plot_waveform <- function(df){
  
  p <- subplot(
    
    plot_ly(
      df,
      x = ~Time,
      y = ~Unit,
      type = "scattergl",
      mode = "lines",
      name = "Unit",
      line = list(width = 1)
    ),
    
    plot_ly(
      df,
      x = ~Time,
      y = ~MT,
      type = "scattergl",
      mode = "lines",
      name = "MT",
      line = list(width = 1)
    ),
    
    plot_ly(
      df,
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
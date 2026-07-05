library(plotly)

plot_waveform <- function(df){
  
  plot_ly(
    data = df,
    x = ~Time,
    y = ~Unit,
    type = "scatter",
    mode = "lines",
    line = list(width = 1)
  ) |>
    layout(
      xaxis = list(title = "Time (s)"),
      yaxis = list(title = "Voltage (V)")
    )
  
}
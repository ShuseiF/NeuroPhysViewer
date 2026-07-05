library(shiny)
library(plotly)

server <- function(input, output, session){
  
  # データの読み込み
  waveform <- reactive({
    
    req(input$file)
    
    read.table(
      input$file$datapath,
      header = FALSE,
      sep = "",
      stringsAsFactors = FALSE
    )
    
  })
  
  # 波形表示
  output$wavePlot <- renderPlotly({
    
    req(waveform())
    
    df <- waveform()
    
    colnames(df) <- c("Time", "Unit")
    
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
        yaxis = list(title = "Voltage")
      )
    
  })
  
}
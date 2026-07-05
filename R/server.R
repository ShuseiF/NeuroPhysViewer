library(shiny)
library(plotly)

server <- function(input, output, session){
  
  output$wavePlot <- renderPlotly({
    
    plot_ly(
      x = c(0,1),
      y = c(0,0),
      type = "scatter",
      mode = "lines"
    )
    
  })
  
}
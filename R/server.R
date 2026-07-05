library(shiny)

server <- function(input, output, session){
  
  waveform <- reactive({
    
    req(input$file)
    
    read_labchart_txt(input$file$datapath)
    
  })
  
  output$wavePlot <- renderPlotly({
    
    req(waveform())
    
    plot_waveform(waveform())
    
  })
  
}
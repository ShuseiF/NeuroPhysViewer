server <- function(input, output, session){
  
  raw_data <- reactive({
    
    req(input$file)
    
    x <- read_labchart_txt(input$file$datapath)
    
    dat <- x$waveform
    
    dat
  })
  
  ttl_data <- reactive({
    
    dat <- raw_data()
    
    detect_ttl(
      time = dat$Time,
      ttl  = dat$MT
    )
  })
  
  ttl_table_display <- reactive({
    
    ttl <- ttl_data()
    
    ttl <- ttl[, c("Stim", "Onset", "Offset", "Width_ms")]
    
    ttl$Onset <- round(ttl$Onset, 4)
    ttl$Offset <- round(ttl$Offset, 4)
    ttl$Width_ms <- round(ttl$Width_ms, 3)
    
    head(ttl, 30)
  })
  
  output$plot <- plotly::renderPlotly({
    
    dat <- raw_data()
    
    plot_waveform(dat)
  })
  
  output$ttl_table <- renderTable({
    
    ttl_table_display()
    
  })
  
}
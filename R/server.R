server <- function(input, output, session){
  
  file_data <- reactive({
    
    req(input$file)
    
    x <- read_labchart_txt(input$file$datapath)
    
    dat <- x$waveform
    
    ttl <- detect_ttl(
      time = dat$Time,
      ttl  = dat$MT
    )
    
    ttl_display <- ttl[, c("Stim", "Onset", "Offset", "Width_ms")]
    
    ttl_display$Onset <- round(ttl_display$Onset, 4)
    ttl_display$Offset <- round(ttl_display$Offset, 4)
    ttl_display$Width_ms <- round(ttl_display$Width_ms, 3)
    
    list(
      waveform = dat,
      ttl = ttl,
      ttl_display = ttl_display
    )
  })
  
  output$plot <- plotly::renderPlotly({
    
    x <- file_data()
    
    plot_waveform(
      df = x$waveform,
      ttl = x$ttl,
      show_ttl = input$show_ttl
    )
  })
  
  output$ttl_table <- DT::renderDataTable({
    
    x <- file_data()
    
    DT::datatable(
      x$ttl_display,
      options = list(
        pageLength = 20,
        lengthMenu = c(10, 20, 50, 100),
        searching = FALSE
      ),
      rownames = FALSE
    )
  })
}
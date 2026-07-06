server <- function(input, output, session){
  
  file_data <- reactive({
    req(input$file)
    
    x <- read_labchart_txt(input$file$datapath)
    dat <- x$waveform
    
    ttl <- detect_ttl(time = dat$Time, ttl = dat$MT)
    
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
  
  spike_data <- reactive({
    x <- file_data()
    
    detect_spikes(
      time = x$waveform$Time,
      signal = x$waveform$Unit,
      threshold = input$spike_threshold,
      polarity = input$spike_polarity
    )
  })
  
  raster_data <- reactive({
    x <- file_data()
    spikes <- spike_data()
    
    make_raster_data(
      spikes = spikes,
      ttl = x$ttl,
      window_start = input$raster_start,
      window_end = input$raster_end
    )
  })
  
  psth_data <- reactive({
    x <- file_data()
    raster <- raster_data()
    
    make_psth_data(
      raster_df = raster,
      window_start = input$raster_start,
      window_end = input$raster_end,
      bin_width = input$psth_bin,
      n_stim = nrow(x$ttl)
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
  
  output$raster_plot <- plotly::renderPlotly({
    plot_raster(
      raster_df = raster_data(),
      window_start = input$raster_start,
      window_end = input$raster_end
    )
  })
  
  output$psth_plot <- plotly::renderPlotly({
    plot_psth(
      psth_df = psth_data(),
      window_start = input$raster_start,
      window_end = input$raster_end
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
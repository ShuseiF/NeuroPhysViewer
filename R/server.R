server <- function(input, output, session){
  
  observeEvent(input$review_prev, {
    new_start <- max(0, input$review_start - input$review_width / 1000)
    updateNumericInput(session, "review_start", value = new_start)
  })
  
  observeEvent(input$review_next, {
    new_start <- input$review_start + input$review_width / 1000
    updateNumericInput(session, "review_start", value = new_start)
  })
  
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
  
  observeEvent(file_data(), {
    
    x <- file_data()
    
    if(nrow(x$ttl) > 0){
      start_time <- x$ttl$Onset[1] - input$review_width / 2000
    } else {
      start_time <- min(x$waveform$Time, na.rm = TRUE)
    }
    
    start_time <- max(min(x$waveform$Time, na.rm = TRUE), start_time)
    
    updateNumericInput(
      session,
      "review_start",
      value = round(start_time, 4)
    )
  }, once = TRUE)
  
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
    spikes <- spike_data()
    
    plot_waveform(
      df = x$waveform,
      ttl = x$ttl,
      spikes = spikes,
      show_ttl = input$show_ttl,
      show_spikes = input$show_spikes
    )
  })
  
  output$review_plot <- plotly::renderPlotly({
    x <- file_data()
    spikes <- spike_data()
    
    plot_review_window(
      df = x$waveform,
      ttl = x$ttl,
      spikes = spikes,
      threshold = input$spike_threshold,
      review_start = input$review_start,
      review_width_ms = input$review_width,
      show_ttl = input$show_ttl,
      show_spikes = input$show_spikes
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
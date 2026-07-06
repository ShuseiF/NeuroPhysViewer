ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer v0.6.7"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput("file", "LabChart TXT file", accept = c(".txt")),
      
      checkboxInput("show_ttl", "Show TTL", value = TRUE),
      
      hr(),
      h4("Spike Detection"),
      
      checkboxInput("show_spikes", "Show detected spikes", value = TRUE),
      
      numericInput("spike_threshold", "Spike threshold",
                   value = -0.50, min = -100, max = 100, step = 0.01),
      
      selectInput("spike_polarity", "Spike polarity",
                  choices = c("negative", "positive"),
                  selected = "negative"),
      
      hr(),
      h4("Review Window"),
      
      numericInput("review_start", "Review start (s)",
                   value = 1.000, min = 0, step = 0.001),
      
      numericInput("review_width", "Review width (ms)",
                   value = 30, min = 5, max = 500, step = 1),
      
      actionButton("review_prev", "← Previous"),
      actionButton("review_next", "Next →"),
      
      hr(),
      h4("Spike Overlay"),
      
      numericInput("spike_pre_ms", "Pre spike window (ms)",
                   value = 2, min = 0.5, max = 10, step = 0.5),
      
      numericInput("spike_post_ms", "Post spike window (ms)",
                   value = 3, min = 0.5, max = 10, step = 0.5),
      
      numericInput("overlay_max_spikes", "Max overlay spikes",
                   value = 300, min = 20, max = 2000, step = 20),
      
      hr(),
      h4("Analysis Window"),
      
      numericInput("raster_start", "Start time (s)", value = -0.05, step = 0.01),
      numericInput("raster_end", "End time (s)", value = 0.20, step = 0.01),
      numericInput("psth_bin", "PSTH bin width (s)",
                   value = 0.005, min = 0.001, max = 0.1, step = 0.001)
    ),
    
    mainPanel(
      
      h3("Whole Recording"),
      plotly::plotlyOutput("plot", height = "420px"),
      
      h3("Review Window"),
      plotly::plotlyOutput("review_plot", height = "300px"),
      
      h3("Spike Waveform Overlay"),
      plotly::plotlyOutput("spike_overlay_plot", height = "300px"),
      
      h3("Raster Plot"),
      plotly::plotlyOutput("raster_plot", height = "300px"),
      
      h3("PSTH"),
      plotly::plotlyOutput("psth_plot", height = "250px"),
      
      h3("TTL Detection"),
      DT::dataTableOutput("ttl_table")
    )
  )
)

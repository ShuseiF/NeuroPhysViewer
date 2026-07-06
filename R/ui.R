ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer v0.6"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput(
        inputId = "file",
        label = "LabChart TXT file",
        accept = c(".txt")
      ),
      
      checkboxInput(
        inputId = "show_ttl",
        label = "Show TTL",
        value = TRUE
      ),
      
      hr(),
      
      h4("Spike Detection"),
      
      numericInput(
        inputId = "spike_threshold",
        label = "Spike threshold",
        value = -0.50,
        min = -100,
        max = 100,
        step = 0.01
      ),
      
      selectInput(
        inputId = "spike_polarity",
        label = "Spike polarity",
        choices = c("negative", "positive"),
        selected = "negative"
      ),
      
      hr(),
      
      h4("Analysis Window"),
      
      numericInput(
        inputId = "raster_start",
        label = "Start time (s)",
        value = -0.05,
        step = 0.01
      ),
      
      numericInput(
        inputId = "raster_end",
        label = "End time (s)",
        value = 0.20,
        step = 0.01
      ),
      
      numericInput(
        inputId = "psth_bin",
        label = "PSTH bin width (s)",
        value = 0.005,
        min = 0.001,
        max = 0.1,
        step = 0.001
      )
    ),
    
    mainPanel(
      
      plotly::plotlyOutput("plot", height = "600px"),
      
      h3("Raster Plot"),
      plotly::plotlyOutput("raster_plot", height = "350px"),
      
      h3("PSTH"),
      plotly::plotlyOutput("psth_plot", height = "300px"),
      
      h3("TTL Detection"),
      DT::dataTableOutput("ttl_table")
    )
  )
)
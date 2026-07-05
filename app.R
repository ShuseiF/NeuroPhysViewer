library(shiny)
library(plotly)

ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer v0.1"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput(
        "file",
        "Load CSV/TXT file",
        accept = c(".csv", ".txt")
      ),
      
      sliderInput(
        "window",
        "Time window (s)",
        min = 0,
        max = 1,
        value = c(0, 1),
        step = 0.01
      )
      
    ),
    
    mainPanel(
      
      plotlyOutput("wavePlot", height = "700px")
      
    )
  )
)

server <- function(input, output, session){
  
  df <- reactive({
    
    req(input$file)
    
    read.table(
      input$file$datapath,
      header = FALSE,
      sep = "",
      col.names = c("Time", "Unit")
    )
  })
  
  observe({
    
    d <- df()
    
    updateSliderInput(
      session,
      "window",
      min = min(d$Time),
      max = max(d$Time),
      value = c(min(d$Time), min(d$Time) + 0.5)
    )
  })
  
  output$wavePlot <- renderPlotly({
    
    d <- df()
    
    d2 <- d[d$Time >= input$window[1] &
              d$Time <= input$window[2], ]
    
    plot_ly(
      d2,
      x = ~Time,
      y = ~Unit,
      type = "scattergl",
      mode = "lines",
      line = list(width = 1)
    ) |>
      layout(
        xaxis = list(title = "Time (s)"),
        yaxis = list(title = "Voltage")
      )
  })
}

shinyApp(ui, server)
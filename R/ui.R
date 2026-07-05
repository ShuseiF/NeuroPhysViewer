library(shiny)
library(plotly)

ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput(
        "file",
        "Load txt file",
        accept = c(".txt", ".csv")
      )
      
    ),
    
    mainPanel(
      
      plotlyOutput("wavePlot", height = "700px")
      
    )
    
  )
  
)
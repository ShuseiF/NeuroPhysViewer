ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput(
        inputId = "file",
        label = "LabChart TXT file",
        accept = c(".txt")
      )
      
    ),
    
    mainPanel(
      
      plotly::plotlyOutput(
        outputId = "plot",
        height = "700px"
      ),
      
      h3("TTL Detection"),
      
      tableOutput("ttl_table")
      
    )
  )
)
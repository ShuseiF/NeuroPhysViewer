ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer v0.3"),
  
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
      
      DT::dataTableOutput("ttl_table")
      
    )
  )
)
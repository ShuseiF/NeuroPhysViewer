ui <- fluidPage(
  
  titlePanel("NeuroPhysViewer v0.4"),
  
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
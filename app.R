library(shiny)

options(shiny.maxRequestSize = 500 * 1024^2)

source("R/io.R")
source("R/ui.R")
source("R/server.R")

shinyApp(ui = ui, server = server)

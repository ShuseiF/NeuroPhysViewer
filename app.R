install.packages(c(
  "shiny",
  "plotly",
  "data.table",
  "dplyr"
))
library(shiny)
library(plotly)
library(data.table)
library(dplyr)

library(shiny)

source("R/ui.R")
source("R/server.R")

shinyApp(ui = ui, server = server)
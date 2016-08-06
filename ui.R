
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  # Uses a javascript to show the units in the input box.
  tags$head(tags$script(src="front.js")),
  
  # Application title
  titlePanel("Old car stop distance"),
  
  p("This application will estimate an old car stop distance from its speed. The model was built from a 1920's speed x stop distance dataset, from the R datasets' library."),
  p("The model is more or less accurate until 25 mph."),
  p("To use the application, select the units you want to use and type the speed in the text input box. The result will appear at the right panel with a plot pointing the result in relation to the cars in the dataset."),
  
  # Sidebar to choose the units and the speed
  sidebarLayout(
    sidebarPanel(
      radioButtons("units", label = h3("Units"),
                   choices = list("metric" = 1, "imperial" = 2), 
                   selected = 2),
      numericInput("speed", label = h3("Speed (", span(id="unitsTxt", "mph"), ")"), value = 1, min = 1)
    ),

    # Show the estimated stop distance
    mainPanel(
      htmlOutput("result"),
      plotOutput("plot")
    )
  )
))

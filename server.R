
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(caret)
library(datasets)

#' Converts km/h to mph.
#' 
#' @param kmh the speed in km/h
#' @return the speed in mph
toMph <- function(kmh) {
  kmh / 1.609344
}

#' Converts ft to meters.
#' 
#' @param ft the distance in ft
#' @return the distance in meters
toMeters <- function(ft) {
  ft * 0.3048
}

# Creates the prediction model globally.
# As the prediction data will always be the same, it does not need be 
# created in each access.
#
# Using the distance in natural log because the data is not very linear.
set.seed(123)
modelFit <- train(log(dist) ~ speed, data=cars, method="glm")

#' Runs the shiny server
shinyServer(function(input, output) {

  # Gets the input speed in mph.
  getSpeed <- reactive({
    validate(
      need(input$speed > 0, "The speed needs to be higher than 0"),
      need(input$units == 1 || input$units == 2, "The units is invalid")
    )
    
    
    if(input$units == 1) {
      toMph(input$speed)
    } else {
      input$speed
    }
  })
  
  # Predicts the stop distance, in feet.
  # Doing an exponential because the training had the distance in natural log.
  getStopDist <- reactive({
    prediction.ft <- exp(predict(modelFit, data.frame(speed=getSpeed())));
    if(input$units == 1) {
      toMeters(prediction.ft)
    } else {
      prediction.ft
    }   
  })
  
  # Creates the HTML output, in the desired units.
  output$result <- renderText({
    if(input$units == 1) {
      speedUnit = "km/h"
      distUnit = "m"
    } else {
      speedUnit = "mph"
      distUnit = "ft"
    }
    
    paste('And old car at <span style="font-weight: bold;">', 
          input$speed, 
          '</span> ', 
          speedUnit, 
          ' will stop in <h3 style="display: inline-block;">', 
          round(getStopDist(), 2), 
          '</h3> ', 
          distUnit)  
  })
})

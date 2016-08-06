
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(caret)
library(datasets)

# Units
units = data.frame(speed=c("km/h", "mph"), dist=c("m", "ft"))

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
modelFit <- train(sqrt(dist) ~ speed, data=cars, method="glm")

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
    prediction.ft <- predict(modelFit, data.frame(speed=getSpeed()))^2;
    if(input$units == 1) {
      toMeters(prediction.ft)
    } else {
      prediction.ft
    }   
  })
  
  # Creates the HTML output, in the desired units.
  output$result <- renderText({

    paste('And old car at <span style="font-weight: bold;">',
          input$speed,
          '</span> ',
          units[input$units, 'speed'],
          ' will stop in <h3 style="display: inline-block;">',
          round(getStopDist(), 2),
          '</h3> ',
          units[input$units, 'dist'])
  })
  
  # Creates the plot
  output$plot <- renderPlot({
    # Calculate the x and y values to show at the plot as the selected units
    if(input$units == 1) {
      x = cars$speed * 1.609344
      y = cars$dist * 0.3048
    } else {
      x = cars$speed
      y = cars$dist
    }
    
    # Defines the limits of the plot
    lim.x = max(x, input$speed)
    lim.y = max(y, getStopDist())
    
    # Plots the cars dataset
    plot(x, y, 
      xlab=paste0("speed (", units[input$units, "speed"], ")"), 
      ylab=paste0("distance (", units[input$units, "dist"],")"),
      xlim=c(0, lim.x),
      ylim=c(0, lim.y)
    )
    
    # Plots the calculated speed x distance
    lines(c(input$speed, input$speed, -10), c(-10, getStopDist(), getStopDist()), col="red")
    points(input$speed, getStopDist(), pch=19, col="red", lwd=2)
  })
})

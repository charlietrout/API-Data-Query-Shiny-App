library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(DT) # For interactive tables

source("API_Query_Funcs.R")

# Define server function
function(input, output, session) {
  
  # Reactive value to store queried data
  player_data_by_team <- reactive({
    get_player_data_by_team("LAL")  # Default to LAL, change as needed
  })
  
  # Render query results table
  output$queryTable <- renderDT({
    datatable(player_data_by_team(), options = list(lengthMenu = c(10, 20, 30), pageLength = 10))
  })
  
  # Subset data based on user input
  observeEvent(input$subsetBtn, {
    subset_data <- player_data_by_team()  # Example: You can subset based on input variables
    output$subsetTable <- renderDT({
      datatable(subset_data, options = list(lengthMenu = c(10, 20, 30), pageLength = 10))
    })
  })
  
  # Download subsetted data as CSV
  output$downloadData <- downloadHandler(
    filename = function() { paste("subset_data", ".csv", sep = "") },
    content = function(file) {
      write.csv(player_data_by_team(), file, row.names = FALSE)
    }
  )
  
  # Plotting based on user input
  output$dataPlot <- renderPlot({
    req(input$xVar, input$plotType)
    
    ggplot(player_data_by_team(), aes_string(x = input$xVar, y = input$yVar)) +
      geom_bar(stat = "identity") +
      facet_wrap(~input$facetVar) +
      labs(x = input$xVar, y = "Count", title = "Player Data Visualization") +
      theme_minimal()
  })
  
}
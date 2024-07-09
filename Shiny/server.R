library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(DT) # For interactive tables

get_player_data_advanced_query <- function(playerName, season, team) {
  base_url <- "http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/query"
  
  query_params <- list(
    playerName = playerName,
    season = season,
    team = team
  )
  
  # Construct the query URL with parameters
  query_url <- modify_url(base_url, query = query_params)
  
  # Make the GET request
  response <- httr::GET(url = query_url)
  stop_for_status(response)
  
  # Parse the JSON content
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}


get_player_data_advancedplayoffs_query <- function(playerName, season, team) {
  base_url <- "http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/query"
  
  query_params <- list(
    playerName = playerName,
    season = season,
    team = team
  )
  
  # Construct the query URL with parameters
  query_url <- modify_url(base_url, query = query_params)
  
  # Make the GET request
  response <- httr::GET(url = query_url)
  stop_for_status(response)
  
  # Parse the JSON content
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}



# Define server function
shinyServer(function(input, output, session) {
  
  # Reactive value to store queried data
  player_data <- reactiveVal(NULL)  # Initialize as NULL
  
  observeEvent(input$getDataBtn, {
    season_type <- ifelse(input$seasonType == "Regular Season", "regular", "playoffs")
    
    # Call your appropriate API function based on user selection
    if (season_type == "regular") {
      player_data(get_player_data_advanced_query(input$playerName, input$season, input$teamName))
    } else {
      player_data(get_player_data_advancedplayoffs_query(input$playerName, input$season, input$teamName))
    } 
  })
  
  # Render query results table
  output$queryTable <- renderDT({
    req(player_data())  # Require player_data to be available
    datatable(player_data(), options = list(lengthMenu = c(10, 20, 30, 50, 100, 250, 500, 1000), pageLength = 10))
  })
  
  # Subset data based on user input
  observeEvent(input$subsetBtn, {
    subset_data <- player_data()  # Example: You can subset based on input variables
    output$subsetTable <- renderDT({
      datatable(subset_data, options = list(lengthMenu = c(10, 20, 30, 50, 100, 250, 500, 1000), pageLength = 10))
    })
  })
  
  # Download subsetted data as CSV
  output$downloadData <- downloadHandler(
    filename = function() { paste("subset_data", ".csv", sep = "") },
    content = function(file) {
      write.csv(player_data(), file, row.names = FALSE)
    }
  )
  
  # Plotting based on user input
  output$dataPlot <- renderPlot({
    req(input$xVar, input$plotType)
    
    ggplot(player_data(), aes_string(x = input$xVar, y = input$yVar)) +
      geom_bar(stat = "identity") +
      facet_wrap(~input$facetVar) +
      labs(x = input$xVar, y = "Count", title = "Player Data Visualization") +
      theme_minimal()
  })
  
})
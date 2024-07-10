library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(DT) # For interactive tables

get_player_data_advanced_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

get_player_data_advancedplayoff_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Define server function
shinyServer(function(input, output, session) {
  
  # Reactive value to store queried data
  player_data <- reactiveVal(NULL)  # Initialize as NULL
  
  observeEvent(input$getDataBtn, {
    season <- input$season
    season_type <- ifelse(input$seasonType == "Regular Season", "regular", "playoffs")
    team <- input$teamName
    player <- input$playerName
    
    # Call your appropriate API function based on user selection
    if (season_type == "regular") {
      player_data_raw <- get_player_data_advanced_by_season(season)
    } else {
      player_data_raw <- get_player_data_advancedplayoff_by_season(season)
    }
    
    # Filter data based on selected team name and player name
    if (!is.null(team) && team != "") {
      player_data_filtered <- player_data_raw[player_data_raw$team == team, ]
    } else {
      player_data_filtered <- player_data_raw
    }
    
    if (!is.null(player) && player != "") {
      player_data_filtered <- player_data_filtered[grep(player, player_data_filtered$playerName, ignore.case = TRUE), ]
    }
    
    player_data(player_data_filtered)
    
    
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
    
    ggplot(player_data_all_seasons, aes_string(x = input$xVar, y = input$yVar)) +
      geom_bar(stat = input$plotType) +
      facet_wrap(~input$facetVar) +
      labs(x = input$xVar, y = "Count", title = "Player Data Visualization") +
      theme_minimal()
  })
  
})
